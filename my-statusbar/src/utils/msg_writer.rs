use anyhow::{Context, Result};
use byteorder::NativeEndian;
use byteorder::WriteBytesExt;
use std::io::Write;

const ENABLE_DEBUG_LOGGING: bool = false;

pub struct MsgWriter {
    inner: Vec<u8>,
}

impl MsgWriter {
    pub fn new() -> Self {
        MsgWriter { inner: Vec::new() }
    }

    pub fn write_u8(&mut self, field_name: &str, value: u8) -> Result<()> {
        if ENABLE_DEBUG_LOGGING {
            eprintln!("write_u8 {} {}", field_name, value);
        }

        self.inner
            .write_u8(value)
            .with_context(|| format!("write_u8 {} {}", field_name, value))
    }

    pub fn write_u16(&mut self, field_name: &str, value: u16) -> Result<()> {
        if ENABLE_DEBUG_LOGGING {
            eprintln!("write_u16 {} {}", field_name, value);
        }

        self.inner
            .write_u16::<NativeEndian>(value)
            .with_context(|| format!("write_u16 {} {}", field_name, value))
    }

    pub fn write_u32(&mut self, field_name: &str, value: u32) -> Result<()> {
        if ENABLE_DEBUG_LOGGING {
            eprintln!("write_u32 {} {}", field_name, value);
        }

        self.inner
            .write_u32::<NativeEndian>(value)
            .with_context(|| format!("write_u32 {} {}", field_name, value))
    }

    pub fn write_bytes(&mut self, field_name: &str, value: &[u8]) -> Result<()> {
        if ENABLE_DEBUG_LOGGING {
            eprintln!("write_bytes {} {:?}", field_name, value);
        }

        self.inner
            .write_all(value)
            .with_context(|| format!("write_bytes {} {:?}", field_name, value))
    }

    pub fn into_vec(self) -> Vec<u8> {
        self.inner
    }
}
