stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"

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
  ;port d4
	BSET PD_DDR, #4
	BSET PD_CR1, #4
	BRES PD_CR2, #4
	
	;pin C2
	BRES PC_DDR, #2
	BSET PC_CR1, #2
	BSET PC_CR2, #2
	MOV EXTI_CR1, #%00100000; set interrupt sensitivity
	
	;timer 2: pwm
	MOV TIM2_CR1,#%00000001 ; counter enable ON
	MOV TIM2_IER,#$00 ; no interrupts are required for PWM
	MOV TIM2_CCMR1,#%01100000 ; PWM mode 1 + CC1 as output
	MOV TIM2_CCER1,#%00000000 ; CC1 output disabled 
	MOV TIM2_ARRH, #$07
	MOV TIM2_ARRL, #$D0
	MOV TIM2_CCR1H, #$03
	MOV TIM2_CCR1L, #$E8
	
	
	; timer 3: timer of 1s
	MOV TIM3_CR1,#%00000000 ; TIM3 OFF
	MOV TIM3_PSCR,#$07 ; prescaler x128
	BSET TIM3_EGR,#0 ; force UEV to update prescaler
	MOV TIM3_IER,#$01 ; TIM3 interrupt on update enabled 
	MOV TIM3_ARRH, #$3D
	MOV TIM3_ARRL, #$09
	
	RIM
infinite_loop.lim
	nop
	nop
	nop
	nop
	jra infinite_loop

	interrupt NonHandledInterrupt
NonHandledInterrupt
	IRET
	
	interrupt ButtonPressed
ButtonPressed
	BRES PC_CR2, #2 ;disable interrupt pin C2
	BSET TIM2_CCER1, #0 ; enable pwm signal speaker
	BSET TIM3_CR1, #0 ;enable 1s timer
	IRET
	
	interrupt Timer
Timer
	BSET PC_CR2, #2
	BRES TIM2_CCER1, #0
	BRES TIM3_CR1, #0
	BRES TIM3_SR1, #0 ;needed otherwise update update won't be reset.
	IRET
	
	
	segment 'vectit'
	dc.l {$82000000+main}									; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+ButtonPressed}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+Timer}	; irq15
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
