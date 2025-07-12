use crate::utils::{MsgReader, MsgWriter};
use anyhow::Result;
use libc::{
    AF_INET, IFLA_IFNAME, NLM_F_REQUEST, RTA_DST, RTA_OIF, RTM_F_LOOKUP_TABLE, RTM_GETLINK,
    RTM_GETROUTE, RTM_NEWLINK,
};
use netlink_sys::{Socket, protocols::NETLINK_ROUTE};

pub struct RouteHandle {
    socket: Socket,
}

impl RouteHandle {
    pub fn new() -> Result<Self> {
        let mut socket = Socket::new(NETLINK_ROUTE)?;
        let _ = socket.bind_auto()?;
        socket.set_non_blocking(true)?;

        let ret = RouteHandle { socket };
        Ok(ret)
    }

    pub fn get_default_route_iface_ipv4(&mut self) -> Result<String> {
        let oif = get_default_route_oif_ipv4(&mut self.socket)?;
        let ifname = get_link_name_from_idx(&mut self.socket, oif)?;
        Ok(ifname)
    }
}

fn get_default_route_oif_ipv4(socket: &mut Socket) -> Result<u32> {
    let mut msg = MsgWriter::new();
    let expected_len = 36;
    msg.write_u32("nlmsg_len", expected_len)?;
    msg.write_u16("nlmsg_type", RTM_GETROUTE)?;
    msg.write_u16("nlmsg_flags", NLM_F_REQUEST as u16)?;
    msg.write_u32("nlmsg_seq", 0)?;
    msg.write_u32("nlmsg_pid", 0)?;
    msg.write_u8("rtm_family", AF_INET as u8)?;
    msg.write_u8("rtm_dst_len", 32)?;
    msg.write_u8("rtm_src_len", 0)?;
    msg.write_u8("rtm_tos", 0)?;
    msg.write_u8("rtm_table", 0)?;
    msg.write_u8("rtm_protocol", 0)?;
    msg.write_u8("rtm_scope", 0)?;
    msg.write_u8("rtm_type", 0)?;
    msg.write_u32("rtm_flags", RTM_F_LOOKUP_TABLE)?;
    msg.write_u16("rta_len", 8)?;
    msg.write_u16("rta_type", RTA_DST)?;
    msg.write_bytes("rta", &[1, 1, 1, 1])?;

    let msg = msg.into_vec();
    assert_eq!(msg.len(), expected_len as usize);

    let n_sent = socket.send(&msg, 0)?;
    assert_eq!(n_sent, msg.len());

    let (reply_buf, _) = socket.recv_from_full()?;
    let reply_len = reply_buf.len();
    let mut reply = MsgReader::new(&reply_buf);
    let nlmsg_len = reply.read_u32("nlmsg_len")?;
    assert_eq!(reply_len, (nlmsg_len as usize));
    reply.read_u16("nlmsg_type")?;
    reply.read_u16("nlmsg_flags")?;
    reply.read_u32("nlmsg_seq")?;
    reply.read_u32("nlmsg_pid")?;
    reply.read_u8("rtm_family")?;
    reply.read_u8("rtm_dst_len")?;
    reply.read_u8("rtm_src_len")?;
    reply.read_u8("rtm_tos")?;
    reply.read_u8("rtm_table")?;
    reply.read_u8("rtm_protocol")?;
    reply.read_u8("rtm_scope")?;
    reply.read_u8("rtm_type")?;
    reply.read_u32("rtm_flags")?;

    loop {
        let rta = read_rta(&mut reply)?;

        if rta.rta_type == RTA_OIF {
            let mut rta_reader = MsgReader::new(rta.rta);
            let oif = rta_reader.read_u32("RTA_OIF")?;
            return Ok(oif);
        }
    }
}

fn get_link_name_from_idx(socket: &mut Socket, idx: u32) -> Result<String> {
    let mut msg = MsgWriter::new();
    let expected_len = 32;
    msg.write_u32("nlmsg_len", expected_len)?;
    msg.write_u16("nlmsg_type", RTM_GETLINK)?;
    msg.write_u16("nlmsg_flags", NLM_F_REQUEST as u16)?;
    msg.write_u32("nlmsg_seq", 0)?;
    msg.write_u32("nlmsg_pid", 0)?;
    msg.write_u8("ifi_family", 0)?;
    msg.write_u8("padding", 0)?;
    msg.write_u16("ifi_type", 0)?;
    msg.write_u32("ifi_index", idx)?;
    msg.write_u32("ifi_flags", 0)?;
    msg.write_u32("ifi_change", 0xFFFFFFFF)?;

    let msg = msg.into_vec();
    assert_eq!(msg.len(), expected_len as usize);

    let n_sent = socket.send(&msg, 0)?;
    assert_eq!(n_sent, msg.len());

    let (reply_buf, _) = socket.recv_from_full()?;
    let reply_len = reply_buf.len();
    let mut reply = MsgReader::new(&reply_buf);
    let nlmsg_len = reply.read_u32("nlmsg_len")?;
    assert_eq!(reply_len, (nlmsg_len as usize));
    let nlmsg_type = reply.read_u16("nlmsg_type")?;
    assert_eq!(nlmsg_type, RTM_NEWLINK);
    reply.read_u16("nlmsg_flags")?;
    reply.read_u32("nlmsg_seq")?;
    reply.read_u32("nlmsg_pid")?;
    reply.read_u8("ifi_family")?;
    reply.read_u8("padding")?;
    reply.read_u16("ifi_type")?;
    reply.read_u32("ifi_index")?;
    reply.read_u32("ifi_flags")?;
    reply.read_u32("ifi_change")?;

    loop {
        let rta = read_rta(&mut reply)?;

        if rta.rta_type == IFLA_IFNAME {
            let ifname = bytes_to_str(rta.rta)?;
            return Ok(ifname);
        }
    }
}

struct Rta<'a> {
    #[allow(dead_code)]
    rta_len: u16,
    rta_type: u16,
    rta: &'a [u8],
}

fn read_rta<'a>(reader: &mut MsgReader<'a>) -> Result<Rta<'a>> {
    let rta_len = reader.read_u16("rta_len")?;
    let rta_type = reader.read_u16("rta_type")?;
    let remaining_sz = (rta_len - 4) as usize;
    let remaining_sz_aligned = rta_align(remaining_sz);
    let rta = reader.read_bytes(remaining_sz_aligned, "rta")?;
    let rta = &rta[0..remaining_sz];

    let ret = Rta {
        rta_len,
        rta_type,
        rta,
    };
    Ok(ret)
}

fn rta_align(len: usize) -> usize {
    let rta_alignto: usize = 4;
    (len + rta_alignto - 1) & !(rta_alignto - 1)
}

fn bytes_to_str<'a>(bytes: &'a [u8]) -> Result<String> {
    let mut i = 0;
    while i < bytes.len() {
        if bytes[i] == 0 {
            break;
        }
        i = i + 1;
    }

    let ret = String::from_utf8((&bytes[0..i]).to_vec())?;

    Ok(ret)
}
