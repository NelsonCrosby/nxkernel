#include <stdarg.h>

#include "log.h"


static fmt_writer_t *default_writer = NULL;

/** Set the default log output, returns the previous output */
fmt_writer_t *log_set_writer(fmt_writer_t *writer)
{
    fmt_writer_t *old = default_writer;
    default_writer = writer;
    return old;
}

/** Get the current default log output */
fmt_writer_t *log_get_writer()
{
    return default_writer;
}


static log_level_t default_level;

/** Set the default minimum log level, returns the previous value */
log_level_t log_set_level(log_level_t level)
{
    log_level_t old = default_level;
    default_level = level;
    return old;
}

/** Get the current default minimum log level */
log_level_t log_get_level()
{
    return default_level;
}


static const char *default_format;

/** Set the default log format, returns the previous value */
const char *log_set_format(const char *format)
{
    const char *old = default_format;
    default_format = format;
    return old;
}

/** Get the current default log format */
const char *log_get_format()
{
    return default_format;
}


/**
 * Write a log line.
 * You probably should prefer the LOG() macro,
 * which gets the default values for you,
 * and the TRACE(), DEBUG(), INFO(), ... macros
 * which make the call slightly less verbose.
 *
 * This function always returns zero;
 * the return type is to allow the LOG() macro
 * to do filtering.
 */
int log_write(
    fmt_writer_t *writer,
    const char *log_fmt, unsigned long long clock, log_level_t level,
    const char *system, const char *func,
    const char *file, unsigned line,
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
            fmt_write_b(writer, i - point, log_fmt + point);

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
                            fmt_write_s(writer, s); \
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
            // $s => system
            case 's':
                fmt_write_s(writer, system);
                break;
            // $f => func
            case 'f':
                fmt_write_s(writer, func);
                break;
            // $F => file
            case 'F':
                fmt_write_s(writer, file);
                break;
            // $L => line
            case 'L':
                fmt_write_u(writer, line);
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
        fmt_write_b(writer, i - point, log_fmt + point);
    }

    return 0;
}
