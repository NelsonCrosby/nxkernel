#include <stdarg.h>

#include "log.h"


static fmt_writer_t *static_writer = NULL;

/** Set the default log output, returns the previous output */
fmt_writer_t *log_set_writer(fmt_writer_t *writer)
{
    fmt_writer_t *old = static_writer;
    static_writer = writer;
    return old;
}

/** Get the current default log output */
fmt_writer_t *log_get_writer()
{
    return static_writer;
}


/**
 * Write a log line.
 * You probably should prefer the LOG() macro,
 * which gets the default values for you,
 * and the TRACE(), DEBUG(), INFO(), ... macros
 * which make the call slightly less verbose.
 */
void log_write(
    fmt_writer_t *writer,
    const char *log_fmt, unsigned clock, log_level_t level,
    const char *msg_fmt, ...
)
{
    va_list ap;
    va_start(ap, msg_fmt);

    /* The general idea here is as thus -
     * loop through each character in log_fmt,
     * queue up normal characters and write them all at once,
     * when $x is seen write something special
     * ($$ => $, $c => clock, $l => level, $m => formatted message). */
    size_t point = 0;
    size_t i;
    for (i = 0; log_fmt[i] != '\0'; i += 1) {
        if (log_fmt[i] == '$') {
            // Dump queued part
            fmt_write_ns(writer, i - point, log_fmt + point);

            // Check next character for action
            i += 1;
            switch (log_fmt[i]) {
            // $$ => $
            case '$':
                fmt_write_hhc(writer, '$');
                break;
            // $c => clock
            case 'c':
                fmt_write_u(writer, clock);
                break;
            // $l => string level
            case 'l':
                switch (level) {
                    #define _(val, s) \
                        case LOG_ ## val: \
                            fmt_write(writer, s); \
                            break;
                    #define __(val) _(val, #val)
                    __(TRACE)
                    __(DEBUG)
                    __(INFO)
                    _(WARNING, "WARN")
                    __(ERROR)
                    #undef _
                    #undef __
                default:
                    fmt_write(writer, "(%d)", level);
                    break;
                }
                break;
            // $m => formatted message
            case 'm':
                fmt_writev(writer, msg_fmt, ap);
                break;
            }

            // Reset queue to after $x
            point = i + 1;
        }
    }

    // If there's more queued, dump it
    if (i - point) {
        fmt_write_ns(writer, i - point, log_fmt + point);
    }
}
