.global _start
.global platform_stop

_start:
	@ Give us a stack
	mov sp, #0x8000

	@ We're done here
	b platform_stop

@ Closest thing to a halt the platform will provide us.
platform_stop:
	b platform_stop
