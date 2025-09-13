{ writeScript
, writeShellScript
, writeShellScriptBin
, python3
, slirp4netns
}:

let

  wgconf = writeScript "wgconf" ''
    #!${python3}/bin/python3

    import sys
    import subprocess
    from configparser import ConfigParser
    from tempfile import NamedTemporaryFile


    def main(config_file, interface):
        c = ConfigParser()
        c.read(config_file)

        dns = strip_split(c['Interface']['DNS'])
        address = strip_split(c['Interface']['Address'])

        del c['Interface']['DNS']
        del c['Interface']['Address']

        with NamedTemporaryFile(mode='w') as f:
            c.write(f)
            f.flush()
            subprocess.run(['wg', 'setconf', interface, f.name], check=True)

        subprocess.run(['ip', 'link', 'set', 'dev', interface, 'up'], check=True)
        for x in address:
            subprocess.run(['ip', 'addr', 'add', 'dev', interface, x], check=True)
        subprocess.run(['ip', 'route', 'add', 'default', 'dev', interface], check=True)
        subprocess.run(['ip', '-6', 'route', 'add', 'default', 'dev', interface], check=True)

        with NamedTemporaryFile(mode='w') as f:
            for x in dns:
                print('nameserver', x, file=f)
            subprocess.run(['mount', '--bind', '-o', 'ro', f.name, '/etc/resolv.conf'], check=True)


    def strip_split(s):
        return [x.strip() for x in s.split(',')]

    if __name__ == "__main__":
        if len(sys.argv) != 3:
            print(f"Usage: {sys.argv[0]} <config_file> <interface>")
            sys.exit(1)

        config_file = sys.argv[1]
        interface = sys.argv[2]
        main(config_file, interface)
  '';

  stage2 = writeShellScript "stage2" ''
    mount -t tmpfs tmpfs /var/run/netns || exit 1
    "${wgconf}" "$1" wg0 || exit 1

    shift

    exec setpriv --inh-caps -all --ambient-caps -all --bounding-set -all --no-new-privs "$@"
  '';

  stage1 = writeShellScript "stage1" ''
    mount -t tmpfs tmpfs /var/run/netns || exit 1
    ip netns add slirp
    test -f /var/run/netns/slirp || exit 1
    ip netns add vpn
    test -f /var/run/netns/vpn || exit 1
    ip -n slirp link set lo up || exit 1
    ip -n vpn link set lo up || exit 1

    (
    cd /
    setsid -f "${slirp4netns}/bin/slirp4netns" --disable-host-loopback --configure --netns-type=path /var/run/netns/slirp tap0 0<&- &>/dev/null
    ) &

    ip -n slirp link add dev wg0 type wireguard || exit 1
    ip -n slirp link set wg0 netns vpn || exit 1

    exec ip netns exec vpn unshare --mount -- "${stage2}" "$@"
  '';

in

writeShellScriptBin "userwgns" ''
  exec systemd-run --user --pty --same-dir --wait --collect --service-type=exec -p PrivateTmp=yes -- unshare --user --mount --keep-caps -c -- "${stage1}" "$@"
''
