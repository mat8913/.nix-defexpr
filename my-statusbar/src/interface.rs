use serde::{Deserialize, Serialize};
use serde_with::skip_serializing_none;

#[derive(Deserialize, Debug)]
pub struct ClickEvent {
    pub name: Option<String>,
    pub instance: Option<String>,
}

#[skip_serializing_none]
#[derive(Serialize, Debug, Default)]
pub struct Block {
    pub full_text: String,
    pub name: Option<String>,
    pub background: Option<String>,
}

pub trait Module {
    fn handle_tick(&mut self) -> Vec<Block>;
    fn handle_click(&mut self, event: &ClickEvent);
}
