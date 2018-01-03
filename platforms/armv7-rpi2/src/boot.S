@ Implements the particular boot logic for this platform.

	.section .text.boot
	.global	_start

_start:
	@ Give ourselves a stack
	mov	sp, #0x8000

	@ Enter C main
	bl	platform_main

	@ Be done
	b	_stop

	.text
	.global	_stop
@ Closest thing to a halt the platform will provide us
@ (until I figure out power control)
@ void _stop()
_stop:
	wfe
	b	_stop
