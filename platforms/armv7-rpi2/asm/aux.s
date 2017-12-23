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
