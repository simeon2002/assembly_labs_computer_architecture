stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"


	segment 'ram0'
index DS.W ;counter

	segment 'rom'
	
array_count DC.W 7
array DC.B 3,6,12,24,48,96,192 ; knight ridder led values

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

init ; init ports and peripherals
	;set up LEDs
	MOV PD_DDR, #$FF
	MOV PD_CR1, #$FF
	MOV PD_CR2, #$00
	MOV PD_ODR, #$00
	
	;set up timer
	MOV TIM3_CR1,#%00000000 ; TIM3 OFF
	MOV TIM3_PSCR,#$07 ; prescaler x128
	BSET TIM3_EGR,#$00 ; force UEV to update prescaler
	MOV TIM3_IER,#$01 ; TIM3 interrupt on update enabled 
	MOV TIM3_ARRH, #$1E ;500ms timer
	MOV TIM3_ARRL, #$85
	;BRES TIM3_SR1, #0 ;IF UNCOMMENTED IT WILL SUPPRESS THE INITIAL INTERRUPT
	
	; initialize index
	LD A, #$0
	LD index, A
	RIM

infinite_loop.l
	nop
	nop
	call knight_rider
	call reset_index
	jra infinite_loop

reset_index
	ldw x, #$0
	ldw index, x
	ret

knight_rider
loop
	BSET TIM3_CR1, #0 ;enable timer (towards interrupt)
	ldw x, index
	CPW x, array_count
	JRNE loop
	RET

increment_index
	LDW X, index
	incw X
	LDW index, X
	jra return
	
	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret
	
	
	interrupt ISR_TIM3
ISR_TIM3
	LDW X, index
	LD A, (array,X)
	LD PD_ODR, A
	BRES TIM3_SR1, #0 ;reset interrupt flag
	BRES TIM3_CR1, #0 ;disable timer
	; check if index = array_count already such that index isn't incremented.
	ldw X,  index
	cpw x, array_count
	jrne increment_index
return 
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
