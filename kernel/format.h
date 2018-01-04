#pragma once
#include <stddef.h>
#include <stdarg.h>


/** Type of the fmt_write_t.write field */
typedef void (*_fmt_write_cb_t)(void *ud, size_t len, const char *text);
/** Type representing a write destination */
typedef struct {
    void *ud;
    _fmt_write_cb_t write;
} fmt_writer_t;


/**
 * Simple replacement for { ud, write },
 * except that it also performs casts.
 * This allows your function signature
 * to use a specific type for *ud.
 */
#define FMT_WRITER(ud, write)   { (void *) ud, (_fmt_write_cb_t) write }


/**
 * The in-kernel alternative to fprintf.
 * The format spec should match that of
 * POSIX printf, where possible.
 */
void fmt_write(fmt_writer_t *writer, const char *msg_fmt, ...);

/**
 * Variant of fmt_write() that takes its
 * format arguments in a va_list rather
 * than as variadic arguments.
 */
void fmt_writev(fmt_writer_t *writer, const char *msg_fmt, va_list args);


/**
 * Write the decimal representation of
 * an unsigned integer to the given writer.
 */
void fmt_write_u(fmt_writer_t *writer, unsigned u);
/**
 * Write the decimal representation of
 * a signed integer to the given writer.
 */
void fmt_write_d(fmt_writer_t *writer, int d, int plus);
/**
 * Write a single character to the given writer.
 */
void fmt_write_hhc(fmt_writer_t *writer, char c);
/**
 * Write a null-terminated string to the given writer.
 */
void fmt_write_s(fmt_writer_t *writer, const char *s);
/**
 * Write a length-string to the given writer.
 */
void fmt_write_ns(fmt_writer_t *writer, size_t len, const char *s);


/**
 * Format some data into a string buffer.
 * This is the same as fmt_write(), using
 * the equivalent of strncpy as the writer.
 */
void fmt(size_t outlen, char *out, const char *msg_fmt, ...);

/**
 * Format some data into a string buffer.
 * This is the same as fmt_writev(), using
 * the equivalent of strncpy as the writer.
 */
void fmtv(size_t outlen, char *out, const char *msg_fmt, va_list args);
