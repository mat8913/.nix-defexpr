use crate::interface::{Block, ClickEvent, Module};
use chrono::prelude::Local;

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
            full_text: formatted,
            ..Default::default()
        }]
    }

    fn handle_click(&mut self, _event: &ClickEvent) {}
}
