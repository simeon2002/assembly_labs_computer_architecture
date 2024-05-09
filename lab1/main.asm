stm8/

	#include "mapping.inc"
	#include "stm8s105k.inc"
	
	segment 'ram0'
delay_index1 ds.b
delay_index2 ds.b
index EQU 16
mode_flag ds.b ; 0 is forward mode 1 is reverse mode

	segment 'rom'
FORWARD_LIMIT DC.B 3
REVERSE_LIMIT DC.B 0

	mov PD_ODR, #$1
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
	;set up output port D
	mov PD_DDR, #$FF
	mov PD_CR1, #$FF
	mov PD_ODR, #$03

	RIM
	mov index, #0
	mov mode_flag, #0
	
infinite_loop.l

	call knight_rider_light
	jra infinite_loop

knight_rider_light
	; wait with delay
	call delay_outer
	; check if in forward or reverse condition
	ld a, mode_flag
	cp a, #$0
	jreq forward_mode
	jp reverse_mode
	; checking end condition
end_condition
	ld a, index
	cp a, REVERSE_LIMIT
	jrne knight_rider_light
	mov mode_flag, #$0 ; return back to forward mode.
	ret

forward_mode
	ld a, PD_ODR
	sll a
	sll a
	ld PD_ODR, a
	
	; check if reverse mode needs be activated.
	inc index
	ld a, index
	cp a, FORWARD_LIMIT
	jrne continue_forward
	mov mode_flag, #1
continue_forward
	jp end_condition

reverse_mode
	ld a, PD_ODR
	srl a
	srl a
	ld PD_ODR, a
	
	; check if reverse mode needs to be activated.
	ld a, index
	dec index
	jp end_condition

delay_outer ; 256 times and 100 times
	mov delay_index1, #0
	mov delay_index2, #0
loop
	call delay_inner
	inc delay_index1
	ld a, delay_index1
	cp a, #100
	jrne loop
	ret
	
delay_inner
	inc delay_index2
	ld a, delay_index2
	cp a, #$ff
	jrne delay_inner
	ret
	
	
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
	dc.l {$82000000+NonHandledInterrupt}	; irq15
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
