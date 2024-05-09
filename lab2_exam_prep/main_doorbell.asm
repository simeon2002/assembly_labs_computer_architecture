stm8/
; ONLY DOORBELL SOLVED HERE, THE OTHERS ARE IN LAB2 OR NON-PRESENT.
; LAB3-4-5 ARE COMPLETE.

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram0'


	
	segment 'rom'
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
clear_stack.l
	clr (X)
	incw X
	cpw X,#stack_end	
	jrule clear_stack

init
	MOV PD_DDR, #$08
	MOV PD_CR1, #$08
	BSET PD_ODR, #3

	BSET PE_CR2, #5
	MOV EXTI_CR2, #$1
	
	
	; setup timers.
	; tim2 as pwm
	BSET TIM2_CR1, #0
	MOV TIM2_IER, #$0
	BSET TIM2_CCMR1, #5
	BSET TIM2_CCMR1, #6
	MOV TIM2_CCER1, #$0
	MOV TIM2_ARRH, #$7
	MOV TIM2_ARRL, #$A1
	MOV TIM2_CCR1H, #$03
	MOV TIM2_CCR1L, #$d0 ; CHECK IF POSSIBLE WITHOUT SETTING THIS ONE? 
	
	;tim3 as timer
	MOV TIM3_CR1, #$0
	MOV TIM3_PSCR, #$7
	MOV TIM3_EGR, #$01
	MOV TIM3_IER, #$01
	MOV TIM3_ARRH, #$3D
	MOV TIM3_ARRL, #$09
	MOV TIM3_SR1, #$0
	
	RIM
	
infinite_loop.l
	NOP
	jra infinite_loop
	
	
	interrupt ISR_PE
ISR_PE
	BRES EXTI_CR2, #0
	BSET TIM2_CCER1, #0
	BSET TIM3_CR1, #0
	iret
	
	interrupt ISR_TIM3
ISR_TIM3
	BRES TIM3_CR1, #0
	BRES TIM3_SR1, #0
	BRES TIM2_CCER1, #0
	BSET EXTI_CR2, #0
	iret
	
	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

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
	dc.l {$82000000+ISR_PE}	; irq7
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
