#include "string.h"
#include "format.h"


/**
 * The in-kernel alternative to fprintf.
 * The format spec should match that of
 * POSIX printf, where possible.
 *
 * Notable deviations from printf:
 * - %b will write the contents of a length-string (buffer).
 *    It consumes one size_t followed by one const char *.
 */
void fmt_write(fmt_writer_t *writer, const char *msg_fmt, ...)
{
    va_list ap;
    va_start(ap, msg_fmt);
    fmt_writev(writer, msg_fmt, ap);
}


/**
 * Variant of fmt_write() that takes its
 * format arguments in a va_list rather
 * than as variadic arguments.
 */
void fmt_writev(fmt_writer_t *writer, const char *msg_fmt, va_list args)
{

    /* The general idea here is as thus -
     * loop through each character in msg_fmt,
     * queue up normal characters and write them all at once,
     * when % is seen do some printf shit */
    size_t point = 0;
    size_t i;
    for (i = 0; msg_fmt[i] != '\0'; i += 1) {
        if (msg_fmt[i] == '%') {
            // Dump queued part
            fmt_write_b(writer, i - point, msg_fmt + point);

            // Parse format part
            for (int terminal = 0; !terminal;) {
                i += 1;
                switch (msg_fmt[i]) {
                // %% => %
                case '%':
                    fmt_write_hhc(writer, '%');
                    terminal = 1;
                    break;
                // %u => unsigned decimal
                case 'u':
                    fmt_write_u(writer, va_arg(args, unsigned));
                    terminal = 1;
                    break;
                // %d => signed decimal
                case 'd':
                    fmt_write_d(writer, va_arg(args, int), 0);
                    terminal = 1;
                    break;
                // %s => null-terminated string
                case 's':
                    fmt_write_s(writer, va_arg(args, const char *));
                    terminal = 1;
                    break;
                // %b => length-string
                case 'b':
                    {
                        size_t len = va_arg(args, size_t);
                        fmt_write_b(writer, len, va_arg(args, const char *));
                    }
                    terminal = 1;
                    break;
                }
            }

            // Reset queue to after %format
            point = i + 1;
        }
    }

    // If there's more queued, dump it
    if (i - point) {
        fmt_write_b(writer, i - point, msg_fmt + point);
    }
}


/**
 * Format an integer into a stream.
 * Handle the sign yourself.
 */
static void _fmt_write_uint(
    fmt_writer_t *writer, unsigned n,
    int base, const char *alphabet
)
{
    char s[24];
    size_t i = 0;

    do {
        s[i++] = alphabet[n % base];
    } while ((n /= base) > 0);

    s[i] = '\0';
    lstr_rev(s, i);

    fmt_write_b(writer, i, s);
}

/**
 * Write the decimal representation of
 * an unsigned integer to the given writer.
 */
void fmt_write_u(fmt_writer_t *writer, unsigned u)
{
    _fmt_write_uint(writer, u, 10, "012456789");
}

/**
 * Write the decimal representation of
 * a signed integer to the given writer.
 */
void fmt_write_d(fmt_writer_t *writer, int u, int plus)
{
    if (plus && u >= 0) {
        fmt_write_hhc(writer, '+');
    } else if (u < 0) {
        fmt_write_hhc(writer, '-');
    }
    fmt_write_u(writer, u < 0 ? -u : u);
}

/**
 * Write a single character to the given writer.
 */
void fmt_write_hhc(fmt_writer_t *writer, char c)
{
    fmt_write_b(writer, 1, &c);
}

/**
 * Write a null-terminated string to the given writer.
 */
void fmt_write_s(fmt_writer_t *writer, const char *s)
{
    fmt_write_b(writer, str_len(s), s);
}

/**
 * Write a length-string to the given writer.
 */
void fmt_write_b(fmt_writer_t *writer, size_t len, const char *s)
{
    writer->write(writer->ud, len, s);
}


struct _fmt_buf {
    size_t len;
    char *data;
};
/** lstr_copy's text into buffer */
static void _fmt_writestr(struct _fmt_buf *buf, size_t len, const char *text)
{
    lstr_copy(text, len, buf->data, buf->len);
}


/**
 * Format some data into a string buffer.
 * This is the same as fmt_write(), using
 * the equivalent of strncpy as the writer.
 */
void fmt(size_t outlen, char *out, const char *msg_fmt, ...)
{
    va_list ap;
    va_start(ap, msg_fmt);
    fmtv(outlen, out, msg_fmt, ap);
}


/**
 * Format some data into a string buffer.
 * This is the same as fmt_writev(), using
 * the equivalent of strncpy as the writer.
 */
void fmtv(size_t outlen, char *out, const char *msg_fmt, va_list args)
{
    struct _fmt_buf buf = { outlen, out };
    fmt_writer_t writer = FMT_WRITER(&buf, _fmt_writestr);
    fmt_writev(&writer, msg_fmt, args);
}
