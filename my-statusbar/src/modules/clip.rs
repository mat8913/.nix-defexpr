use crate::interface::{Block, ClickEvent, Module};
use wl_clipboard_rs::copy;
use wl_clipboard_rs::paste;

pub struct ClipModule {}

impl ClipModule {
    pub fn new() -> Box<dyn Module> {
        Box::new(ClipModule {})
    }
}

impl Module for ClipModule {
    fn handle_tick(&mut self) -> Vec<Block> {
        if is_clip_empty() {
            vec![]
        } else {
            vec![Block {
                name: Some("clip".to_string()),
                full_text: "[Clip]".to_string(),
                ..Default::default()
            }]
        }
    }

    fn handle_click(&mut self, event: &ClickEvent) {
        let name: Option<&str> = event.name.as_ref().map(|x| x.as_str());
        if name != Some("clip") {
            return;
        }

        clear_clip();
    }
}

fn is_clip_empty() -> bool {
    let clp = paste::get_mime_types(paste::ClipboardType::Regular, paste::Seat::Unspecified);
    match clp {
        Err(paste::Error::ClipboardEmpty) => true,
        _ => false,
    }
}

fn clear_clip() {
    let _ = copy::clear(copy::ClipboardType::Both, copy::Seat::All);
}
