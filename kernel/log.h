#pragma once
#include "format.h"
#include "platform.h"


/* TODO: Make this changeable at runtime */
#define LOG_FORMAT  "[$c] $l: $m\n"


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
);


/**
 * Calls log_write(), with
 * the default writer,
 * the default format,
 * and the result of platform_clock_now().
 */
#define LOG(level, msg, ...) \
    log_write( \
        log_get_writer(), \
        LOG_FORMAT, platform_clock_now(), level, \
        msg, ##__VA_ARGS__ \
    )

#define TRACE(msg, ...)     LOG(LOG_TRACE, msg, ##__VA_ARGS__)
#define DEBUG(msg, ...)     LOG(LOG_DEBUG, msg, ##__VA_ARGS__)
#define INFO(msg, ...)      LOG(LOG_INFO, msg, ##__VA_ARGS__)
#define WARN(msg, ...)      LOG(LOG_WARNING, msg, ##__VA_ARGS__)
#define ERROR(msg, ...)     LOG(LOG_ERROR, msg, ##__VA_ARGS__)
