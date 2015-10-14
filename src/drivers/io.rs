/// Write a byte to the specified port
#[allow(dead_code)]
pub unsafe fn outb(port: u16, val: u8)
{
	asm!("out %al, %dx" : : "{dx}"(port), "{al}"(val) : "volatile");
}

/// Read a single byte from the specified port
#[allow(dead_code)]
pub unsafe fn inb(port: u16) -> u8
{
	let ret : u8;
	asm!("in %dx, %al" : "={al}"(ret) : "{dx}"(port) : "volatile");
	return ret;
}
