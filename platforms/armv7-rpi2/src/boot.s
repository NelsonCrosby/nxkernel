@ Implements the particular boot logic for this platform.

	.data
msg:	.string	"YATTA!\r\n"
	.align	2

	.section .text.boot
	.global	_start

_start:
	@ Give ourselves a stack
	mov	sp, #0x8000

	@ Set up logging
	bl	_uart_init

	@ Try a hello world...
	ldr	a1, =msg
	bl	_uart_write_cstr

	@ We're done here
	b	_stop

	.text
	.global	_stop
@ Closest thing to a halt the platform will provide us
@ (until I figure out power control)
@ void _stop()
_stop:
	wfe
	b	_stop
