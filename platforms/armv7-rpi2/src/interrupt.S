
	.data

	@ These instructions will be populated into
	@ the interrupt handler vector.
	@ All elements in the vector
	@ load the corresponding handler function into pc.
	.align 2
_intr_vectbl:
	ldr	pc, [pc, #24]
	ldr	pc, [pc, #24]
	ldr	pc, [pc, #24]
	ldr	pc, [pc, #24]
	ldr	pc, [pc, #24]
	ldr	pc, [pc, #24]
	ldr	pc, [pc, #24]
	ldr	pc, [pc, #24]
	.word	_ih_reset
	.word	_ih_undefined
	.word	_ih_softintr
	.word	_ih_abort_prefetch
	.word	_ih_abort_data
	.word	_ih_
	.word	_ih_hardintr
	.word	_ih_fastintr

	@ Messages to log when undefined interrupts occur
s_undefined:
	.string	"! undefined\r\n"
s_softintr:
	.string	"! swi\r\n"
s_abort_prefetch:
	.string	"! prefetch abort\r\n"
s_abort_data:
	.string	"! data abort\r\n"
s_reserved:
	.string	"!?\r\n"
s_hardintr:
	.string	"! irq\r\n"
s_fastintr:
	.string	"! fiq\r\n"


	.text
@ void _intr_init()
	.global	_intr_init


@ void _intr_init()
_intr_init:
	push	{v1-v8, lr}

	@ Ensure interrupts are disabled while we're working
	mrs	r0, CPSR
	orr	r0, r0, #0xE0
	msr	CPSR_c, r0

	@ Set the handler vectable base address to 0,
	@ in case the bootloader changed it
	mov	r0, #0
	MCR	p15, 0, r0, c12, c0, 0

	@ Copy vectbl into place, in two lots of eight
	ldr	r0, =_intr_vectbl
	ldr	r1, =0x0
	ldmia	r0!, {v1-v8}
	stmia	r1!, {v1-v8}
	ldmia	r0!, {v1-v8}
	stmia	r1!, {v1-v8}

	@ Enable all interrupts
	mrs	r0, CPSR
	bic	r0, r0, #0xE0
	msr	CPSR_c, r0

	pop	{v1-v8, pc}


.macro	_ih_get rd
	mov	rd, #0x0C
	ldr	rd, [rd]
.endm


	@ intr: Reset
	@ mode: svc
	@ The reset handler just jumps back to _start.
_ih_reset:
	b	_start


	@ intr: Undefined instruction
	@ mode: und
	@ Need to either:
	@ - Emulate this instruction (nope),
	@    return to lr (after the bad instruction)
	@ - Kill whoever is responsible for this madness
_ih_undefined:
	@ Right now kernel is always at fault, so just die
	@ ldr	a1, =s_undefined
	@ bl	_uart_write_cstr
	b	_stop


	@ intr: Software interrupt (swi)
	@ mode: svc
	@ Perform userspace-requested operation,
	@ return to lr (after the swi instruction)
_ih_softintr:
	stmfd	sp!, {r4-r12, lr}

	ldr	a1, =s_softintr
	bl	_uart_write_cstr

	ldmfd	sp!, {r4-r12, pc}^


	@ intr: Prefetch abort
	@ mode: abt
	@ do ???, return to lr - 4 (repeat failed instruction)
_ih_abort_prefetch:
	ldr	a1, =s_abort_prefetch
	bl	_uart_write_cstr
	b	_stop


	@ intr: Data abort
	@ mode: abt
	@ do ???, return to lr - 8 (instruction before failed instruction?)
_ih_abort_data:
	ldr	a1, =s_abort_data
	bl	_uart_write_cstr
	b	_stop


	@ intr: Reserved
	@ mode: -
	@ This shouldn't happen, so just abort if it does.
_ih_:
	b	_stop


	@ intr: Interrupt request (irq)
	@ mode: irq
	@ Handle request, return to lr - 4 (repeat interrupted instruction)
_ih_hardintr:
	ldr	a1, =s_hardintr
	bl	_uart_write_cstr
	b	_stop


	@ intr: Fast interrupt request (fiq)
	@ mode: fiq
	@ Handle request, return to lr - 4 (repeat interrupted instruction)
_ih_fastintr:
	ldr	a1, =s_fastintr
	bl	_uart_write_cstr
	b	_stop
