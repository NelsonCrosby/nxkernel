#pragma once
#include <stdarg.h>
#include <kernel/platform.h>

#include "format.h"


#define LOG_FORMAT_SIMPLE   "[$c] $s $l: $m"
#define LOG_FORMAT_FUNC     "[$c] {$s/$f} $l: $m"
#define LOG_FORMAT_TRACE    "[$c] {$s/$f|$F:$L} $l: $m"
#define LOG_DEFAULT_FORMAT  LOG_FORMAT_FUNC

#ifndef LOG_SYSTEM
#define LOG_SYSTEM  ""
#endif


/** Logging levels */
typedef enum {
    LOG_TRACE   = 10,
    LOG_DEBUG   = 20,
    LOG_INFO    = 30,
    LOG_WARNING = 40,
    LOG_ERROR   = 50,
} log_level_t;


/** Set the default log output, returns the previous value */
fmt_writer_t *log_set_writer(fmt_writer_t *writer);
/** Get the current default log output */
fmt_writer_t *log_get_writer();

/** Set the default minimum log level, returns the previous value */
log_level_t log_set_level(log_level_t level);
/** Get the current default minimum log level */
log_level_t log_get_level();

/** Set the default log format, returns the previous value */
const char *log_set_format(const char *format);
/** Get the current default log format */
const char *log_get_format();


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
);


/**
 * Calls log_write(), with
 * current system,
 * current func,
 * current file,
 * and current line.
 */
#define LOG_HERE(writer, format, clock, level, msg, ...) \
    log_write( \
        writer, \
        format, clock, level, \
        LOG_SYSTEM, __func__, __FILE__, __LINE__, \
        msg, ##__VA_ARGS__ \
    )

/**
 * Calls LOG_HERE(), with
 * the default writer,
 * the default format,
 * and the result of platform_clock_now(),
 * only if level is greater or equal to the default log level.
 */
#define LOG(level, msg, ...) \
    level < log_get_level() ? 0 : \
    LOG_HERE( \
        log_get_writer(), \
        log_get_format(), platform_clock_now(), level, \
        msg, ##__VA_ARGS__ \
    )

#define TRACE(msg, ...)     LOG(LOG_TRACE, msg, ##__VA_ARGS__)
#define DEBUG(msg, ...)     LOG(LOG_DEBUG, msg, ##__VA_ARGS__)
#define INFO(msg, ...)      LOG(LOG_INFO, msg, ##__VA_ARGS__)
#define WARN(msg, ...)      LOG(LOG_WARNING, msg, ##__VA_ARGS__)
#define ERROR(msg, ...)     LOG(LOG_ERROR, msg, ##__VA_ARGS__)
