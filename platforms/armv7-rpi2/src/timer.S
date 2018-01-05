
	.data
#include "aux.S"

	.text
@ void _timer_clock_init()
	.global _timer_clock_init
@ unsigned long long _timer_clock_now()
	.global _timer_clock_now


@ unsigned long long _timer_clock_now()
_timer_clock_now:
	ldr	ip, =BCM_STIMER_BASE
	ldr	ip, [ip]

_now_retry:
	ldr	r1, [ip, #CHI]
	ldr	r0, [ip, #CLO]

	@ Need to confirm that this lo is for this hi
	ldr	r2, [ip, #CHI]
	cmp	r1, r2
	@ If r1 and r2 aren't equal,
	@ then this lo may not correspond to this hi.
	bne	_now_retry

	dmb			@ Memory barrier for peripheral sync
	mov	pc, lr
