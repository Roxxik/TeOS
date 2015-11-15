pub use prelude::*;
use core::fmt;
use super::io::{inb, outb};

/// Write a string to the output channel.
pub unsafe fn puts(s: &str) {
    for b in s.bytes() {
        // TODO: hard-coded serial line 0.
        putb(0x3f8, b);
    }
}

/// Write a single byte to the output channel.
pub unsafe fn putb(port: u16, b: u8) {
    // Wait for the serial FIFO to be ready
    while (inb(port + 5) & 0x20) == 0 {}
    outb(port, b);
}

pub struct Terminal;

impl Terminal {
    /// Obtain a logger for the specified module.
    pub fn get(module: &str) -> Terminal {
        use core::fmt::Write;
        let mut ret = Terminal;
        let _ = write!(&mut ret, "[{}] ", module);
        ret
    }
}

impl ::core::ops::Drop for Terminal {
    /// Release the logger.
    fn drop(&mut self) {
        use core::fmt::Write;
        let _ = write!(self, "\n");
    }
}

impl fmt::Write for Terminal {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        unsafe {
            puts(s);
        }
        Ok(())
    }
}
