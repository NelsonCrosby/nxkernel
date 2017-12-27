
#![feature(lang_items)]
#![no_std]

extern crate rlibc;


#[no_mangle]
pub extern fn main() {
    log_init();
    log("enter platform_main()\n");
}


extern {
    fn _uart_init();
    fn _uart_write_lstr(len: usize, data: *const u8);
    fn _stop();
}

fn log_init() {
    unsafe {
        _uart_init();
    }
}

fn log(message: &str) {
    unsafe {
        _uart_write_lstr(message.len(), message.as_ptr());
    }
}


#[lang = "eh_personality"]
extern fn eh_personality() {}

#[lang = "panic_fmt"]
#[no_mangle]
pub extern fn panic_fmt() -> ! {loop{}}
