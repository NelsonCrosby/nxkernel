@ Implements the particular boot logic for this platform.

	.data
msg:	.string	"YATTA!\r\n"
	.align	2

	.section .text.boot
	.global	_start

_start:
	@ Give us a stack
	mov	sp, #0x8000

	@ Set up logging?
	bl	platform_log_init

	@ Try a hello world...
	ldr	a1, =msg
	bl	_write_cstr

	@ Switch into rust
	bl	platform_main

	@ We're done here
	b	platform_stop

	.text
	.global	platform_stop
@ Closest thing to a halt the platform will provide us.
platform_stop:
	wfe
	b	platform_stop
