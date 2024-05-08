stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram0'
index ds.w

	segment 'rom'

song dc.b 2, 3, 4, 2, 4, 5, 6, 6
pitch dc.w $08e0, $07e8, $0776, $06a6, $05ec, $0597, $04fb, $0470
INDEX_LIMIT dc.w 8

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
	
	;set up timer
	MOV TIM3_CR1,#%00000000 ; TIM3 OFF
	MOV TIM3_PSCR,#$0A ; prescaler x128
	BSET TIM3_EGR,#0 ; force UEV to update prescaler
	MOV TIM3_IER,#$01 ; TIM3 interrupt on update enabled 
	MOV TIM3_ARRH, #$03 ;500ms timer
	MOV TIM3_ARRL, #$D1
	BRES TIM3_SR1, #0
	
	;set up PWM
	MOV TIM2_CR1,#%00000001 ; counter enable ON 
	MOV TIM2_IER,#$00   ; no interrupts 
	MOV TIM2_CCMR1,#%01100000 
	MOV TIM2_CCER1,#%00000000 ; high-cycle disabled 
	
	MOV index, #$0
	RIM

infinite_loop.l
	MOV TIM3_ARRH, #$03
	MOV TIM3_ARRL, #$D1
	call play_sound
	MOV TIM3_ARRH, #$26 ;5s timer
	MOV TIM3_ARRL, #$26
	BSET TIM3_CR1, #0
wait_timer_5s
	ld A, TIM3_CR1
	cp A, #$01
	jreq wait_timer_5s
	jra infinite_loop

play_sound
	MOV TIM2_CCER1,#%00000001
loop
	call set_tone_values ; sets CCR and ARR values.
wait_for_timer_loop
	ld A, TIM3_CR1
	cp A, #$01
	jreq wait_for_timer_loop
	bset TIM3_CR1, #0 ;start time
	ldw X, index
	incw X ; increment index
	ldw index, X
	cpw X, INDEX_LIMIT ; compare index with limit.
	jrne loop
wait_for_timer_last_iter ; wait if previous timer is still busy.
	ld A, TIM3_CR1
	cp A, #$01
	jreq wait_for_timer_last_iter 
	BRES TIM2_CCER1, #0 ; else disable PWM.
	ldw X, #$0
	ldw index, X
	ret
	
	
	
	

set_tone_values
	; get index in song table for tone to be played.
	ldw X, index
	ld A, (song,X)
	ld XL, A
	; fetch ARR of tone to play via index in song table.
	sllw X ;double to get to byte count. every tone is 2 bytes
	ld A, (pitch,X) ; Y contains ARR-value (the 2 bytes)
	ld YH, A
	incw X
	ld A, (pitch,X)
	ld YL, A
	; put in lower byte
	ld A, YH
	ld TIM2_ARRH, A
	; put in higher byte
	ld A, YL
	ld TIM2_ARRL, A	
	; put in duty cycle
	srlw Y
	ld A, YH
	ld TIM2_CCR1H, A
	ld A, YL
	ld TIM2_CCR1L, A
	ret
	

	interrupt Timer3Interrupt
Timer3Interrupt
	; reset the UIF and disable the counter of the timer
	BRES TIM3_SR1, #0
	BRES TIM3_CR1, #0
	IRET
	
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
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+NonHandledInterrupt}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+Timer3Interrupt}	; irq15
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
