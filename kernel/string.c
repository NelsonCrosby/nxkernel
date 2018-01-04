#include "string.h"


/**
 * Much like strncpy(3), except using a length-string source.
 * Returns the size of the copied string.
 */
size_t lstr_copy(const char *src, size_t ssz, char *dest, size_t dsz)
{
    for (size_t i = 0; i < dsz; i += 1) {
        if (i == ssz) {
            // Reached the end of src
            return i;
        }

        dest[i] = src[i];
    }

    // Reached the limit of dest
    return dsz;
}


/**
 * Reverses the given length-string in-place.
 */
void lstr_rev(char *str, size_t sz)
{
    char c;
    for (size_t i = 0, k = sz - 1; i < k; i++, k--) {
        c = str[i];
        str[i] = str[k];
        str[k] = c;
    }
}


/**
 * Much like strncpy(3).
 * Always null-terminates dest.
 * Returns the size of the copied string.
 */
size_t str_copy(const char *src, char *dest, size_t dsz)
{
    for (size_t i = 0; i < dsz; i += 1) {
        dest[i] = src[i];
        if (src[i] == '\0') {
            // Reached the end
            return i - 1;
        }
    }

    // Reached the limit of dest
    dest[dsz - 1] = '\0';
    return dsz - 1;
}


/**
 * Much like strlen(3).
 */
size_t str_len(const char *str)
{
    size_t count = 0;
    while (str[count] != '\0')
        count += 1;
    return count;
}


inline void str_rev(char *str);
