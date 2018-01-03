
	.text
	.global _swi

_swi:
	swi	1234
	mov	pc, lr
