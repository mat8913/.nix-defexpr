use crate::interface::{Block, ClickEvent, Module};
use crate::utils::RouteHandle;

const EXPECTED_IFACE: &str = "wg0";

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

        let iface = self.route_handle.get_default_route_iface_ipv4().unwrap();

        if iface != EXPECTED_IFACE {
            alerts.push(format!("ipv4 route: {}", iface));
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
