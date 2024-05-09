stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"

	
	segment 'ram0'
index ds.w ; index for tone array.
duty_cycle_MSB ds.b ;is a word. for the duty cycle calculation
duty_cycle_LSB ds.b
times_played ds.b ;variable to make it only play once.
direction_flag ds.b ; forward = 0, reverse = 1

	segment 'rom'
pitch dc.W $08e0, $07e8, $0776, $06a6, $05ec, $0597, $04fb, $0470
FORWARD_INDEX_LIMIT DC.W 16
REVERSE_INDEX_LIMIT DC.W 0
TIMES_TO_PLAY DC.B 1
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
	; setup of timer.
	MOV TIM3_CR1, #%00000000 ; timer off atm.
	MOV TIM3_PSCR, #$07 ; prescaler of 128
	MOV TIM3_EGR, #%00000000  ; update event needs to update prescaler
	mov TIM3_IER, #$01 ; tim3 interrupt enabled
	MOV TIM3_ARRH, #$1e
	MOV TIM3_ARRL, #$84
	BRES TIM3_SR1, #0
	
	; setup pwm.
	BSET TIM2_CR1, #0 ; to enable the counter.
	MOV TIM2_IER, #$00 ; no interrupts set up.
	MOV TIM2_CCMR1, #%01100000 ; pwm mode 1 + cc1 set as output
	BSET TIM2_CCER1, #0 ; enable cc1 output (do I have to do this at the start or not?? 

	; init index and times_played
	ldw x, #$0
	ldw index, x
	MOV times_played, #$0
	MOV direction_flag, #$0
;	call set_tone_values
	RIM 
	
infinite_loop
	; calculate CCR value (duty cycle counter)
	ld a, times_played
	cp a, TIMES_TO_PLAY
	jreq playing_done
	call play_tone
	inc times_played
playing_done
	jra infinite_loop
	
	
play_tone
	
	; waiting if timer has been set already.
waiting_for_timer
	ld a, TIM3_CR1
	cp a, #$01
	jreq waiting_for_timer
	; pushing arr and ccr values in tim2 registers
	call set_tone_values
	; check for direction flag. 
	LDW X, index
	CPW X, FORWARD_INDEX_LIMIT
	JREQ set_direction_flag
continue
	; check if index = 0 has been reached when Dflag is set.
	jp end_sound_check
end_sound_failed
	; playing the tone
	BSET TIM3_CR1, #0
	jra play_tone
end_sound_success
	BRES TIM2_CCER1, #0
	ret
	
end_sound_check
	; jump to end sound if index is 0 and dir flag is 1.
	ldw X, index
	CPW X, REVERSE_INDEX_LIMIT
	jrne end_sound_failed
	ld a, direction_flag
	cp a, #$01
	jreq end_sound_success
	jp end_sound_failed

set_direction_flag
	mov direction_flag, #$01
	jp continue
	
set_tone_values
	; MSB byte.
	ldw x, index
	ld A, (pitch,X)
	ld TIM2_ARRH, a
	ld yh, a
	; increment index
	ldw x, index
	incw x
	; LST byte.
	ld A, (pitch,X)
	ld TIM2_ARRL, a
	ld yl, a
	; increment index
	incw x
	ldw index, x
	
	; duty cycle calculation
	SRLW Y
	ld a, yh
	ld TIM2_CCR1H, a
	ld a, yl
	ld TIM2_CCR1L, a
	ret
	
	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret
	
	interrupt timer_tone
timer_tone.l
	; increment index.
	ld a, direction_flag
	cp a, #$0
	jreq interrupt_continued;added to see if index_up is required.
	;jreq index_up
	jp index_down
interrupt_continued
	; turn off counter and UIF
	BRES TIM3_CR1, #0
	BRES TIM3_SR1, #0
	iret

;index_up
	;ldw x, index
	;incw x
	;ldw index, x
	;jp interrupt_continued

index_down
	ldw x, index
	decw x
	decw x
	decw x
	decw x
	ldw index, x
	jp interrupt_continued

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
	dc.l {$82000000+timer_tone}	; irq15
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
