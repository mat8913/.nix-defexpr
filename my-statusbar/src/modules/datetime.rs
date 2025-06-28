use crate::interface::{Block, ClickEvent, Module};
use chrono::prelude::Local;
use std::process::Command;

pub struct DateTimeModule {}

impl DateTimeModule {
    pub fn new() -> Box<dyn Module> {
        Box::new(DateTimeModule {})
    }
}

impl Module for DateTimeModule {
    fn handle_tick(&mut self) -> Vec<Block> {
        let datetime = Local::now();
        let formatted = datetime.format("%a %b %_d %Y %I:%M:%S%p").to_string();

        vec![Block {
            name: Some("datetime".to_string()),
            full_text: formatted,
            ..Default::default()
        }]
    }

    fn handle_click(&mut self, event: &ClickEvent) {
        let name: Option<&str> = event.name.as_ref().map(|x| x.as_str());
        if name != Some("datetime") {
            return;
        }

        Command::new("swaync-client")
            .args(["-t", "-sw"])
            .status();
    }
}
