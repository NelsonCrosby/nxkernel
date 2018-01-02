#include "_.h"


void platform_main()
{
    _uart_init();
    _uart_write_cstr("Greetings from kernel-space!\r\n");
}
