// taken from https://github.com/thepowersgang/rust-barebones-kernel

macro_rules! log{
	( $($arg:tt)* ) => ({
		// Import the Writer trait (required by write!)
		use core::fmt::Write;
		let _ = write!(&mut ::drivers::serial::Terminal::get(module_path!()), $($arg)*);
	})
}

macro_rules! log_serial{
	( $($arg:tt)* ) => ({
		// Import the Writer trait (required by write!)
		use core::fmt::Write;
		let _ = write!(&mut ::drivers::serial::Terminal::get(module_path!()), $($arg)*);
	})
}
