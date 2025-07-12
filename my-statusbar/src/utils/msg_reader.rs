use anyhow::{Context, Result, anyhow};
use byteorder::NativeEndian;
use byteorder::ReadBytesExt;
use std::io::Cursor;

const ENABLE_DEBUG_LOGGING: bool = false;

pub struct MsgReader<'a> {
    inner: Cursor<&'a [u8]>,
}

impl<'a> Clone for MsgReader<'a> {
    fn clone(&self) -> Self {
        let buffer: &'a [u8] = self.inner.get_ref();
        let mut cursor = Cursor::new(buffer);
        cursor.set_position(self.inner.position());
        MsgReader { inner: cursor }
    }
}

impl<'a> MsgReader<'a> {
    pub fn new(inner: &'a [u8]) -> MsgReader<'a> {
        MsgReader {
            inner: Cursor::new(inner),
        }
    }

    pub fn read_u8(&mut self, field_name: &str) -> Result<u8> {
        let ret = self
            .inner
            .read_u8()
            .with_context(|| format!("read_u8 {}", field_name))?;

        if ENABLE_DEBUG_LOGGING {
            eprintln!("read_u8 {}: {}", field_name, ret);
        }

        Ok(ret)
    }

    pub fn read_u16(&mut self, field_name: &str) -> Result<u16> {
        let ret = self
            .inner
            .read_u16::<NativeEndian>()
            .with_context(|| format!("read_u16 {}", field_name))?;

        if ENABLE_DEBUG_LOGGING {
            eprintln!("read_u16 {}: {}", field_name, ret);
        }

        Ok(ret)
    }

    pub fn read_u32(&mut self, field_name: &str) -> Result<u32> {
        let ret = self
            .inner
            .read_u32::<NativeEndian>()
            .with_context(|| format!("read_u32 {}", field_name))?;

        if ENABLE_DEBUG_LOGGING {
            eprintln!("read_u32 {}: {}", field_name, ret);
        }

        Ok(ret)
    }

    pub fn read_bytes(&mut self, num_bytes: usize, field_name: &str) -> Result<&'a [u8]> {
        let buffer: &'a [u8] = self.inner.get_ref();
        let start = self.inner.position() as usize;
        let end = start + num_bytes;
        let end64 = end
            .try_into()
            .with_context(|| format!("read_bytes {} {}", num_bytes, field_name))?;
        let len = buffer.len();

        if end > len {
            return Err(anyhow!(
                "range end index {} out of range for slice of length {}",
                end,
                len
            ))
            .with_context(|| format!("read_bytes {} {}", num_bytes, field_name));
        }

        let ret = &buffer[start..end];

        self.inner.set_position(end64);

        if ENABLE_DEBUG_LOGGING {
            eprintln!("read_bytes {} {}: {:?}", num_bytes, field_name, ret);
        }

        return Ok(ret);
    }

    pub fn has_more(&self) -> bool {
        (self.inner.position() as usize) < self.inner.get_ref().len()
    }
}
