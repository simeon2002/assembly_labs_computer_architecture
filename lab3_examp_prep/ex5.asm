stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"

	segment 'ram0'
index ds.w
direction_flag ds.b ; 0=forward 1=reverse

	segment 'rom'
pitch dc.w 2272, 2024, 1910, 1702, 1516, 1431, 1275, 1136
FORWARD_LIMIT DC.W 16
REVERSE_LIMIT DC.W 0


main.l
	; initialize SP
	ldw X,#stack_end
	ldw SP,X

	#ifdef RAM0	
	; clear RAM0
ram0_start.b EQU $ram0_segment_start
ram0_end.b EQU $ram0_segment_end
	ldw X,#ram0_start
clear_ram0.l
	clr (X)
	incw X
	cpw X,#ram0_end	
	jrule clear_ram0
	#endif

	#ifdef RAM1
	; clear RAM1
ram1_start.w EQU $ram1_segment_start
ram1_end.w EQU $ram1_segment_end	
	ldw X,#ram1_start
clear_ram1.l
	clr (X)
	incw X
	cpw X,#ram1_end	
	jrule clear_ram1
	#endif

	; clear stack
stack_start.w EQU $stack_segment_start
stack_end.w EQU $stack_segment_end
	ldw X,#stack_start
clear_stack.l`
	clr (X)
	incw X
	cpw X,#stack_end	
	jrule clear_stack

init
	; timer 2 setup
	MOV PD_DDR, #$08
	MOV PD_CR1, #$08
	MOV PD_ODR, #$08
	MOV TIM2_CR1,#%0000001 ; counter enable ON 
	MOV TIM2_IER,#$00 ; no interrupts are required for PWM 
	MOV TIM2_CCMR1,#%01100000 ; PWM mode 1 + CC1 as output 
	MOV TIM2_CCER1,#%00000000 ; CC1 output disabled 
	
	; timer 3 setup
	MOV TIM3_CR1, #$0
	MOV TIM3_PSCR, #$07
	MOV TIM3_EGR, #$01
	MOV TIM3_IER, #$01
	MOV TIM3_ARRH, #$2f
	MOV TIM3_ARRL, #$85
	MOV TIM3_SR1, #$00

	RIM
	
infinite_loop.l
	call play_sound
done
	jp done
	
play_sound
loop
	ld A, direction_flag
	cp A, #$0
	jreq forward_mode
	jp reverse_mode
end_sound
	ret

forward_mode
	ldw Y, index

	; wait for previous timer
timer_wait
	ld A, TIM3_CR1
	cp A, #$1
	jreq timer_wait
	ldw X, index
	cpw X, FORWARD_LIMIT
	jreq change_mode
	; setup duty cycle
	call setup_duty_cycle_and_freq
	; start timer
	bset TIM3_CR1, #0
	bset TIM2_CCER1, #0
	; load Y back to index
	incw Y
	ldw index, Y
	; check if loop condition is false

	jra forward_mode
	
change_mode
	MOV direction_flag, #$01
	jp play_sound


reverse_mode
	; fetch ARR value
	ldw Y, #12
	LDW index, Y
loop_reverse
	ldw Y, index
timer_wait_reverse
	ld A, TIM3_CR1
	cp A, #$1
	jreq timer_wait_reverse
	call setup_duty_cycle_and_freq
	BSET TIM3_CR1, #0 ;ENABLE TIMER
	BSET TIM2_CCER1, #0 ;ENABLE SOUND
	decw Y
	decw Y
	decw Y
	ldw X, index
	cpw X, REVERSE_LIMIT
	jreq end_sound
	ldw index, Y
	jra loop_reverse
	
	
setup_duty_cycle_and_freq
	; FREQUENCY
	; fetch arr value
	ld A, (pitch,Y)
	ld XH, A
	ld TIM2_ARRH, A
	incw Y
	ld A, (pitch,Y)
	ld TIM2_ARRL, A
	LD XL, A
	; DUTY CYCLE
	srlw X
	ld A, XH
	ld TIM2_CCR1H, A
	ld A, XL
	ld TIM2_CCR1L, A
	ret

	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

	interrupt ISR_TIM3
ISR_TIM3
	; DISABLE SOUND
	BRES TIM2_CCER1, #0
	BRES TIM3_CR1, #0
	BRES TIM3_SR1, #0
	IRET

	segment 'vectit'
	dc.l {$82000000+main}									; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+NonHandledInterrupt}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+ISR_TIM3}	; irq15
	dc.l {$82000000+NonHandledInterrupt}	; irq16
	dc.l {$82000000+NonHandledInterrupt}	; irq17
	dc.l {$82000000+NonHandledInterrupt}	; irq18
	dc.l {$82000000+NonHandledInterrupt}	; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+NonHandledInterrupt}	; irq22
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29

	end
