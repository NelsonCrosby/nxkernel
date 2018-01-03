/** Assembly function declarations */

/**
 * Tell the platform to stop the kernel in the most tidy way possible.
 * This may enter a low-power infinite wait,
 * tell the platform to cut power,
 * or other relevant action.
 */
void _stop();

/** Initialize interrupt stuffs */
void _intr_init();

void _swi();

/** Initialize the UART, for use as a logging backend. */
void _uart_init();
/** Write a string of a given length to the UART */
void _uart_write_lstr(unsigned len, const char *data);
/** Write a null-terminated string to the UART */
void _uart_write_cstr(const char *data);
