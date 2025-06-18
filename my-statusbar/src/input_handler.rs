use crate::interface::ClickEvent;
use serde::Deserializer;
use std::fmt;
use std::thread::{self, JoinHandle};

pub fn start_input_handler<F: Fn(ClickEvent) + Send + 'static>(event_handler: F) -> JoinHandle<()> {
    thread::spawn(move || {
        let stdin = std::io::stdin();
        let mut des = serde_json::Deserializer::from_reader(stdin);
        des.deserialize_seq(ClickEventArrayVisitor {
            event_handler: event_handler,
        })
        .unwrap();
    })
}

struct ClickEventArrayVisitor<F> {
    event_handler: F,
}

impl<'de, F: Fn(ClickEvent)> serde::de::Visitor<'de> for ClickEventArrayVisitor<F> {
    type Value = ();

    fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        formatter.write_str("array of ClickEvent")
    }

    fn visit_seq<A>(self, mut seq: A) -> Result<Self::Value, A::Error>
    where
        A: serde::de::SeqAccess<'de>,
    {
        while let Some(val) = seq.next_element::<ClickEvent>()? {
            (self.event_handler)(val);
        }
        Ok(())
    }
}
