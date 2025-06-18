use crate::interface::{Block, ClickEvent, Module};
use psutil::{cpu, disk, memory};

pub struct PsutilModule {
    cpu_percent_collector: cpu::CpuPercentCollector,
}

impl PsutilModule {
    pub fn new() -> Box<dyn Module> {
        Box::new(PsutilModule {
            cpu_percent_collector: cpu::CpuPercentCollector::new().unwrap(),
        })
    }
}

impl Module for PsutilModule {
    fn handle_tick(&mut self) -> Vec<Block> {
        let cpu_percent = self.cpu_percent_collector.cpu_percent().unwrap();
        let mem_percent = memory::virtual_memory().unwrap().percent();
        let disk_percent = disk::disk_usage("/").unwrap().percent();

        vec![
            Block {
                full_text: format!("CPU: {:.1}%", cpu_percent),
                ..Default::default()
            },
            Block {
                full_text: format!("Mem: {:.1}%", mem_percent),
                ..Default::default()
            },
            Block {
                full_text: format!("Disk: {:.1}%", disk_percent),
                ..Default::default()
            },
        ]
    }

    fn handle_click(&mut self, _event: &ClickEvent) {}
}
