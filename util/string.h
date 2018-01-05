#pragma once
#include <stddef.h>


/**
 * Much like strncpy(3), except using a length-string source.
 * Returns the size of the copied string.
 */
size_t lstr_copy(const char *src, size_t ssz, char *dest, size_t dsz);


/**
 * Reverses the given length-string in-place.
 */
void lstr_rev(char *str, size_t sz);


/**
 * Much like strncpy(3).
 * Always null-terminates dest.
 * Returns the size of the copied string.
 */
size_t str_copy(const char *src, char *dest, size_t dsz);


/**
 * Much like strlen(3).
 */
size_t str_len(const char *str);


/**
 * Reverses the given null-terminated string.
 * Equivalent to
 *  lstr_rev(str, str_len(str))
 */
inline void str_rev(char *str)
{
    return lstr_rev(str, str_len(str));
}
