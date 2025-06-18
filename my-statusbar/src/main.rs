use std::io::Write;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

use crate::input_handler::start_input_handler;
use crate::interface::{Block, ClickEvent, Module};
use crate::modules::*;

pub mod input_handler;
pub mod interface;
pub mod modules;

#[derive(Debug)]
enum Event {
    Timer,
    ClickEvent(ClickEvent),
}

fn main() {
    let mut modules: Vec<Box<dyn Module>> = vec![
        ClipModule::new(),
        PsutilModule::new(),
        DateTimeModule::new(),
    ];

    let (send1, recv) = mpsc::sync_channel(0);
    let send2 = send1.clone();

    thread::spawn(move || {
        loop {
            send1.send(Event::Timer).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    start_input_handler(move |x| {
        send2.send(Event::ClickEvent(x)).unwrap();
    });

    let stdout = std::io::stdout();

    (&stdout)
        .write_all(b"{\"version\": 1, \"click_events\": true}\n[")
        .unwrap();

    let mut blocks: Vec<Block> = Vec::new();
    loop {
        let evt = recv.recv().unwrap();
        match evt {
            Event::Timer => {
                blocks.clear();
                for module in &mut modules {
                    blocks.append(&mut module.handle_tick());
                }
                serde_json::to_writer(&stdout, &blocks).unwrap();
                (&stdout).write_all(b",\n").unwrap();
                (&stdout).flush().unwrap();
            }
            Event::ClickEvent(cevt) => {
                for module in &mut modules {
                    module.handle_click(&cevt);
                }
            }
        }
    }
}
