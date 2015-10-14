pub use prelude::*;
use core::fmt;
use super::io::{inb, outb};

static VIDEO_ADDRESS: u32 = 0xB8000;
static MAX_ROWS: u8 = 25;
static MAX_COLS: u8 = 80;
static WHITE_ON_BLACK: u8 = 0x0F;

static REG_SCREEN_CTRL: u16 = 0x3D4;
static REG_SCREEN_DATA: u16 = 0x3D5;

#[allow(improper_ctypes)]
extern {
    fn memcpy(dest: *mut u8, src: *const u8, n: usize) -> *mut u8;
    fn memset(s: *mut u8, c: i32, n: usize) -> *mut u8;
}

unsafe fn print_char(c: u8, attr: Option<u8>, pos: Option<(u8,u8)>) {
    let vidmem = VIDEO_ADDRESS as *mut u8;
    let attr = attr.unwrap_or(WHITE_ON_BLACK);

    let mut offset: isize = pos.map_or_else(wrap_get_cursor, get_screen_offset);

    if c == '\n' as u8 {
        offset = get_screen_offset((
            MAX_COLS - 1,
            (offset / ((MAX_COLS as isize) * 2)) as u8
        ));
    } else {
        *vidmem.offset(offset)     = c;
        *vidmem.offset(offset + 1) = attr;
    }

    offset += 2;

    handle_scrolling(&mut offset);

    set_cursor(offset);
}

fn get_screen_offset(pos: (u8,u8)) -> isize {
    ((pos.1 as isize) * (MAX_COLS as isize) + (pos.0 as isize)) * 2
}

fn wrap_get_cursor() -> isize {
    unsafe{
        get_cursor()
    }
}

unsafe fn get_cursor() -> isize {
    outb(REG_SCREEN_CTRL, 0x0E);
    let mut offset: isize = (inb(REG_SCREEN_DATA) as isize) << 8;
    outb(REG_SCREEN_CTRL, 0x0F);
    offset += inb(REG_SCREEN_DATA) as isize;
    offset * 2
}

unsafe fn set_cursor(offset: isize) {
    let offset = offset / 2;
    outb(REG_SCREEN_CTRL, 0x0E);
    outb(REG_SCREEN_DATA, (offset >> 8) as u8);
    outb(REG_SCREEN_CTRL, 0x0F);
    outb(REG_SCREEN_DATA, offset as u8)
}

unsafe fn handle_scrolling(cursor_offset: &mut isize) {
    if *cursor_offset >= (MAX_ROWS as isize) * (MAX_COLS as isize) * 2 {
        let vidmem = VIDEO_ADDRESS as *mut u8;
        for i in 1..MAX_ROWS {
            memcpy(
                vidmem.offset(get_screen_offset((0,i-1))),
                vidmem.offset(get_screen_offset((0,i))),
                (MAX_COLS as usize) * 2
            );
        }
        memset(
            vidmem.offset(get_screen_offset((0, MAX_ROWS - 1))),
            0,
            (MAX_COLS as usize) * 2
        );
        *cursor_offset -= (MAX_COLS as isize) * 2;
    }
}

pub fn print_at(s: &str, pos: Option<(u8,u8)>) {
    unsafe {
        pos.map(|pos| set_cursor(get_screen_offset(pos)));
        for b in s.as_bytes() {
            print_char(*b, None, pos);
        }
    }
}

pub fn print(s: &str) {
    print_at(s, None);
}

pub fn clear() {
    unsafe{
        let vidmem = VIDEO_ADDRESS as *mut u8;
        memset(
            vidmem,
            0,
            (MAX_COLS as usize) * (MAX_ROWS as usize) * 2
        );
        set_cursor(get_screen_offset((0,0)));
    }
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
        print(s);
        Ok(())
    }
}
