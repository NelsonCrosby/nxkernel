@ Implements the lowest-level logging facilities supported by this platform.
@ In the rpi2 case, there are two serial UARTs - this is the second, more
@ powerful UART (a PL110) - the one that QEMU connects to.

	.data
#include "aux.S"


	.text
@ void _uart_init()
	.global _uart_init
@ void _uart_write_lstr(unsigned len, const char *data)
	.global	_uart_write_lstr
@ void _uart_write_cstr(const char *data)
	.global _uart_write_cstr


@ void _uart_init()
@ r0	: value to write
@ ip	: peripheral base address
_uart_init:
	push	{lr}

	ldr	ip, =BCM_UART_BASE
	ldr	ip, [ip]
	mov	r0, #0
	str	r0, [ip, #UART_CR]

	@ @ set up gpio pins
	ldr	ip, =BCM_GPIO_BASE
	ldr	ip, [ip]
	@ @    4 << 15: FSEL15 - pin 15 = RX
	@ @  | 4 << 12: FSEL14 - pin 14 = TX
	@ mov	r0, #((4 << 15) | (4 << 12))
	@ str	r0, [ip, #GPFSEL1]

	bl	_gpio_pull

	@ uart config
	ldr	ip, =BCM_UART_BASE
	ldr	ip, [ip]
	@ clear pending interrupts
	mov	r0, #0x7FF
	str	r0, [ip, #UART_ICR]
	@ baud 115200 == 0b1.101000 (3MHz / (baud * 16))
	mov	r0, #1
	str	r0, [ip, #UART_IBRD]
	mov	r0, #40
	str	r0, [ip, #UART_FBRD]
	@    0x60: WLEN - 8-bit words
	@  | 0x10: FEN - enable FIFOs
	@  | 0x00: STP2 - enable 2 stop bits
	mov	r0, #0x70
	str	r0, [ip, #UARTLCR_LCRH]
	@    0x00: no (?) interrupts please
	mov	r0, #0x07F2
	str	r0, [ip, #UART_IMSC]
	@    0x0100: TXE - enable transmit
	@  | 0x0001: UARTEN - enable UART
	mov	r0, #0x0301
	str	r0, [ip, #UART_CR]

	@ uart is ready to transmit!
	pop	{pc}


@ void _uart_write_lstr(unsigned len, const char *data)
@ a1(r0): string length
@ a2(r1): next char address
@ r2	: current char
@ ip	: peripheral base address
_uart_write_lstr:
	push	{lr}

	ldr	ip, =BCM_UART_BASE
	ldr	ip, [ip]
	@ cancel if len == 0
	cmp	a1, #0
	moveq	pc, lr
_write_lstr_loop:
	@ this is a private function and
	@ we know that it uses only r3 (which we don't)
	bl	_wait_ready
	@ copy byte
	ldrb	r2, [a2], +#1
	str	r2, [ip, #UART_DR]
	@ decr len
	subs	a1, a1, #1
	@ return if len == 0, else repeat
	bne	_write_lstr_loop
	pop	{pc}

@ void _uart_write_cstr(const char *data)
@ a1(r0): next char address
@ r2	: current char
_uart_write_cstr:
	push	{lr}

	ldr	ip, =BCM_UART_BASE
	ldr	ip, [ip]
_write_cstr_loop:
	@ this is a private function and
	@ we know that it uses only r3 (which we don't)
	bl	_wait_ready
	@ load first char immediately
	ldrb	r2, [a1], +#1
	@ if c == '\0', return
	cmp	r2, #0
	popeq	{pc}
	@ not returning; write and repeat
	str	r2, [ip, #UART_DR]
	b	_write_cstr_loop

@ void _wait_ready()
@ r3	: flags are loaded here
@ ip	: (in) must hold the value at BCM_UART_BASE
_wait_ready:
	ldr	r3, [ip, #UART_FR]
	tst	r3, #0x20
	bne	_wait_ready
	mov	pc, lr

@ macro _gpio_pull_delay (reg count, op2 upto)
.macro	_gpio_pull_delay rcount, oupto
	mov	\rcount, \oupto
1:
	subs	\rcount, \rcount, #1
	bne	1b
.endm

@ void _gpio_pull()
@ r0	: value to write
@ ip	: (in) must hold the value at BCM_GPIO_BASE
_gpio_pull:
	push	{lr}
	
	mov	r0, #0
	str	r0, [ip, #GPPUD]
	_gpio_pull_delay r0, #150

	mov	r0, #((1 << 14) | (1 << 15))
	str	r0, [ip, #GPPUDCLK0]
	_gpio_pull_delay r0, #150

	mov	r0, #0
	str	r0, [ip, #GPPUDCLK0]

	pop	{pc}
