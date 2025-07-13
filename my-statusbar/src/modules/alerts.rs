use crate::interface::{Block, ClickEvent, Module};
use crate::utils::RouteHandle;

const EXTERNAL_IFACE: &str = "wg0";
const EXTERNAL_IPV4: [u8; 4] = [1, 1, 1, 1];
const EXTERNAL_IPV6: [u8; 16] = [
    0x26, 0x06, 0x47, 0x00, 0x47, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x11,
];

const LOOPBACK_IFACE: &str = "lo";
const LOOPBACK_IPV4: [u8; 4] = [127, 0, 0, 1];
const LOOPBACK_IPV6: [u8; 16] = [
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
];

pub struct AlertsModule {
    route_handle: RouteHandle,
}

impl AlertsModule {
    pub fn new() -> Box<dyn Module> {
        let route_handle = RouteHandle::new().unwrap();
        Box::new(AlertsModule { route_handle })
    }
}

impl Module for AlertsModule {
    fn handle_tick(&mut self) -> Vec<Block> {
        let mut alerts: Vec<String> = Vec::new();

        // Sanity check
        let iface = self
            .route_handle
            .get_route_iface_ipv4(&LOOPBACK_IPV4)
            .unwrap();
        assert_eq!(iface, LOOPBACK_IFACE);

        let iface = self
            .route_handle
            .get_route_iface_ipv4(&EXTERNAL_IPV4)
            .unwrap();
        if iface != EXTERNAL_IFACE {
            alerts.push(format!("ipv4 route: {}", iface));
        }

        // Sanity check
        let iface = self
            .route_handle
            .get_route_iface_ipv6(&LOOPBACK_IPV6)
            .unwrap();
        assert_eq!(iface, LOOPBACK_IFACE);

        let iface = self
            .route_handle
            .get_route_iface_ipv6(&EXTERNAL_IPV6)
            .unwrap();
        if iface != EXTERNAL_IFACE {
            alerts.push(format!("ipv6 route: {}", iface));
        }

        alerts
            .into_iter()
            .map(|alert| Block {
                name: Some("alerts".to_string()),
                full_text: alert,
                background: Some("#FF0000".to_string()),
                ..Default::default()
            })
            .collect()
    }

    fn handle_click(&mut self, _event: &ClickEvent) {}
}
