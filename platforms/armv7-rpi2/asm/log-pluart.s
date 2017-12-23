@ Implements the lowest-level logging facilities supported by this platform.
@ In the rpi2 case, there are two serial UARTs - this is the second, more
@ powerful UART (a PL110) - the one that QEMU connects to.

	.data
@ Peripheral register addresses

	.equ	BCM_PERI_BASE,	0x3F000000
	.align 2
BCM_GPIO_BASE:
	.word	(BCM_PERI_BASE + 0x00200000)
BCM_AUX_BASE:
	.word	(BCM_PERI_BASE + 0x00215000)
BCM_UART_BASE:
	.word	(BCM_PERI_BASE + 0x00201000)

@ GPIO peripheral registers
@ Offset these from BCM_GPIO_BASE
	.equ	GPFSEL0,	0x00
	.equ	GPFSEL1,	0x04
	.equ	GPFSEL2,	0x08
	.equ	GPFSEL3,	0x0C
	.equ	GPFSEL4,	0x10
	.equ	GPFSEL5,	0x14

	.equ	GPSET0,		0x1C
	.equ	GPSET1,		0x20
	.equ	GPCLR0,		0x28
	.equ	GPCLR1,		0x2C

	.equ	GPLEV0,		0x34
	.equ	GPLEV1,		0x38

	.equ	GPPUD,		0x94
	.equ	GPPUDCLK0,	0x98
	.equ	GPPUDCLK1,	0x9C

@ Auxiliary peripheral registers
@ Offset these from BCM_AUX_BASE
	.equ	AUX_IRQ,	0x00
	.equ	AUX_ENABLES,	0x04
	.equ	AUX_MU_IO_REG,	0x40
	.equ	AUX_MU_IER_REG,	0x44
	.equ	AUX_MU_IIR_REG,	0x48
	.equ	AUX_MU_LCR_REG,	0x4C
	.equ	AUX_MU_MCR_REG,	0x50
	.equ	AUX_MU_LSR_REG,	0x54
	.equ	AUX_MU_MSR_REG,	0x58
	.equ	AUX_MU_SCRATCH,	0x5C
	.equ	AUX_MU_CNTL_REG,0x60
	.equ	AUX_MU_STAT_REG,0x64
	.equ	AUX_MU_BAUD_REG,0x68

@ PL110 UART peripheral registers
@ Offset these from BCM_UART_BASE
	.equ	UART_DR,	0x00
	.equ	UART_FR,	0x18
	.equ	UART_IBRD,	0x24
	.equ	UART_FBRD,	0x28
	.equ	UARTLCR_LCRH,	0x2C
	.equ	UART_CR,	0x30
	.equ	UART_IMSC,	0x38
	.equ	UART_ICR,	0x44


	.text
@ void platform_log_init()
	.global platform_log_init
@ void _write_lstr(unsigned len, char *data)
	.global	_write_lstr
@ void _write_cstr(char *data)
	.global _write_cstr


@ void platform_log_init()
@ r0	: value to write
@ ip	: peripheral base address
platform_log_init:
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


@ void _write_lstr(unsigned len, char *data)
@ a1(r0): string length
@ a2(r1): next char address
@ r2	: current char
@ ip	: peripheral base address
_write_lstr:
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

@ void _write_cstr(char *data)
@ a1(r0): next char address
@ r2	: current char
_write_cstr:
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
