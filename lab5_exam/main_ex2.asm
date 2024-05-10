stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram0'
duty_mode ds.b ; 0= 20%, 1=80%

	segment 'rom'

VALUE20 DC.W 4000 ;0X0FA0
VALUE80 DC.W 16000 ;0X3E80

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
	;set up timer with 200Hz
	; timer 2 setup
	BSET PD_DDR, #4
	BSET PD_CR1, #4
	BSET PD_ODR, #4
	MOV TIM2_CR1,#%0000001 ; counter enable ON 
	MOV TIM2_IER,#$00 ; no interrupts are required for PWM 
	MOV TIM2_CCMR1,#%01100000 ; PWM mode 1 + CC1 as output 
	MOV TIM2_CCER1,#%00000001 ; CC1 output ENABLED 
	LDW X, #$4e20
	ld A, XH
	ld TIM2_ARRH, A
	ld A, XL
	ld TIM2_ARRL, A
	; INITIAL CCR
	LDW X, VALUE20
	ld A, XH
	ld TIM2_CCR1H, A
	ld A, XL
	ld TIM2_CCR1L, A

	
	; timer 3 setup
	MOV TIM3_CR1, #$0
	MOV TIM3_PSCR, #$07
	MOV TIM3_EGR, #$01
	MOV TIM3_IER, #$01
	MOV TIM3_ARRH, #$7A
	MOV TIM3_ARRL, #$12
	MOV TIM3_SR1, #$00
	
	; setup E5 as interrupt at rising edge only
	MOV PE_DDR, #$0
	BSET PE_CR1, #5
	BSET PE_CR2, #5
	MOV EXTI_CR2, #$01

	RIM
	
infinite_loop.l
	LD A, TIM3_CR1
	CP A, #$01
	jreq infinite_loop
	BSET TIM3_CR1, #0
	jra infinite_loop

	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

	interrupt ISR_TIM3
ISR_TIM3
	BRES TIM3_SR1, #0
	BRES TIM3_CR1, #0
	ld A, duty_mode
	cp A, #$0
	jreq change_mode_to_80 ; change to mode 1
	jp change_mode_to_20 ; change to mode 0
end_interrupt_tim3
	iret
	
change_mode_to_20
	; insert value CCR
	LDW X, VALUE20
	ld A, XH
	ld TIM2_CCR1H, A
	ld A, XL
	ld TIM2_CCR1L, A
	; change duty_mode flagg
	MOV duty_mode, #$0
	jp end_interrupt_tim3

change_mode_to_80
	; insert value CCR
	LDW X, VALUE80
	ld A, XH
	ld TIM2_CCR1H, A
	ld A, XL
	ld TIM2_CCR1L, A
	; change duty_mode flag.
	MOV duty_mode, #$1
	jp end_interrupt_tim3

	interrupt ISR_PE
ISR_PE
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
