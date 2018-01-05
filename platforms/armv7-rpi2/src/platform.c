#define LOG_SYSTEM  "platform"
#include <util/log.h>

#include "_.h"


static void uart_write(void *_, size_t len, const char *text)
{
    _uart_write_lstr(len, text);
}


void platform_main()
{
    _uart_init();

    fmt_writer_t uart_writer = FMT_WRITER(NULL, uart_write);
    log_set_writer(&uart_writer);
    log_set_level(LOG_TRACE);
    log_set_format(LOG_DEFAULT_FORMAT "\r\n");

    INFO("Greetings.");

    _intr_init();
    TRACE("Interrupts enabled.");
}


unsigned long long platform_clock_now()
{
    return _timer_clock_now();
}
