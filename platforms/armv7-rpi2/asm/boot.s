@ Implements the particular boot logic for this platform.

	.section .text.boot
	.global	_start

_start:
	@ Give us a stack
	mov	sp, #0x8000

	@ Set up logging
	bl	_uart_init

	@ start kernel proper
	bl	main

	@ We're done here
	b	_stop

	.text
	.global	_stop
@ Closest thing to a halt the platform will provide us.
_stop:
	wfe
	b	_stop
