@ Implements the lowest-level logging facilities supported by this platform.
@ In the rpi2 case, there are two serial UARTs - this is the first, a
@ "mini UART" that seems to have the majority of the user examples.

@ This implementation is not tested, and was written while trying
@ to get QEMU to work (this is the wrong device for QEMU).
@ It should be revised before trying to use it.

	.data
	.include "aux.s"
	@ in case your syntax highlighting is broken: "

	.text
@ void platform_log_init()
	.global platform_log_init
@ void _write_lstr(unsigned len, char *data)
	.global	_write_lstr
@ void _write_cstr(char *data)
	.global _write_cstr


@ void platform_log_init()
platform_log_init:

	@ set up gpio
	ldr	ip, =BCM_GPIO_BASE
	ldr	ip, [ip]
	ldr	r0, [ip, #GPFSEL1]
	@ gpio14 alt5
	mvn	r1, #0x7000
	mov	r2, #0x2000
	and	r0, r0, r1
	orr	r0, r0, r2
	@ gpio15 alt5
	mvn	r1, #0x038000
	mov	r2, #0x010000
	and	r0, r0, r1
	orr	r0, r0, r2
	@ save
	str	r0, [ip, #GPFSEL1]

	mov	r0, #0
	mov	r1, #0xC000
	str	r0, [ip, #GPPUD]

	mov	r2, #150
_pub_log_init_loop1:
	subs	r2, r2, #1
	bne	_pub_log_init_loop1

	str	r1, [ip, #GPPUDCLK0]

	mov	r2, #150
_pub_log_init_loop2:
	subs	r2, r2, #1
	bne	_pub_log_init_loop2

	str	r0, [r3, #GPPUDCLK0]

	@ setup uart
	mov	r0, #0
	mov	r1, #1
	mov	r3, #3
	ldr	ip, =BCM_AUX_BASE
	ldr	ip, [ip]
	str	r1, [ip, #AUX_ENABLES]
	str	r0, [ip, #AUX_MU_IER_REG]
	str	r0, [ip, #AUX_MU_CNTL_REG]
	str	r3, [ip, #AUX_MU_LCR_REG]
	str	r0, [ip, #AUX_MU_MCR_REG]
	str	r0, [ip, #AUX_MU_IER_REG]
	mov	r2, #((1 << 14) | (1 << 15))
	str	r2, [ip, #AUX_MU_IIR_REG]
	mov	r2, #230
	str	r2, [ip, #AUX_MU_BAUD_REG]

	ldr	ip, =BCM_AUX_BASE
	ldr	ip, [ip]
	str	r3, [ip, #AUX_MU_CNTL_REG]

	bx	lr


@ void _write_lstr(unsigned len, char *data)
@ a1(r0): string length
@ a2(r1): next char address
@ r2	: current char 
_write_lstr:
	ldr	ip, =BCM_AUX_BASE
	ldr	ip, [ip]
	@ cancel if len == 0
	cmp	a1, #0
	bxeq	lr
_write_lstr_loop:
	@ copy byte
	ldrb	r2, [a2], +#1
	str	r2, [ip, #AUX_MU_IO_REG]
	@ decr len
	subs	a1, a1, #1
	@ repeat if len > 0, else return
	bne	_write_lstr_loop
	bx	lr

@ void _write_cstr(char *data)
@ a1(r0): next char address
@ r2	: current char
_write_cstr:
	ldr	ip, =BCM_AUX_BASE
	ldr	ip, [ip]
_write_cstr_loop:
	@ load first char immediately
	ldrb	r2, [a1], +#1
	@ if c == '\0', return
	cmp	r1, #0
	bxeq	lr
	@ not returning; write and repeat
	str	r2, [ip, #AUX_MU_IO_REG]
	b	_write_cstr_loop
