macro_rules! log{
	( $($arg:tt)* ) => ({
		// Import the Writer trait (required by write!)
		use core::fmt::Write;
		let _ = write!(&mut ::screen::Terminal::get(module_path!()), $($arg)*);
	})
}
