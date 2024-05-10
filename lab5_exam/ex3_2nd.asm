stm8/

	#include "mapping.inc"
	segment 'ram0'
index ds.w ; already cleared to 0 so no need for setup.
sum ds.b	; same here
average_result ds.b ; same here.
remainder ds.b

	segment 'rom'
list dc.b $F0, $02, $04, $10
list_signed dc.b 64, 88, 0, 0
LIST_COUNT DC.W 4
DIVISOR DC.B 4

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

infinite_loop.l
	call calculate_average
	call calculate_average_signed
calc_done
	jra calc_done

calculate_sum
	; fetching value
	ldw X, index
	ld A, (list,X)
	; doing and storing addition
	ADD A, sum
	; checking whether overflow is present w C bit
	jrnc no_carry
	; if carry(i.e. overflow present) move FF to average result.
	MOV average_result, #$FF
	jp sum_done
no_carry
	ld sum, A
	incw X
	ldw index, X
	cpw X, LIST_COUNT
	jreq sum_done
	jp calculate_sum
sum_done
	ret
	
calculate_average
	; get sum
	call calculate_sum
	; check whether carry was present.
	ld A, average_result
	cp A, #$FF
	jreq carry_present
	; do division
	ld A, sum
	ld XL, A
	ld A, DIVISOR
	div X, A
	ld remainder, A
	ld A, XL
	ld average_result, A
carry_present
	ret
	
calculate_sum_signed ;differnet list so other func required!
	; fetching value
	ldw X, index
	ld A, (list_signed,X)
	; doing and storing addition
	ADD A, sum
	; checking for overflow present
	jrnv no_overflow_signed
	; if overflow present move FF to average result and be done
	MOV average_result, #$FF
	jp sum_done_signed
no_overflow_signed
	ld sum, A
	incw X
	ldw index, X
	cpw X, LIST_COUNT
	jreq sum_done_signed
	jp calculate_sum_signed
sum_done_signed
	ret
	


calculate_average_signed
	ldw X, #0
	ldw index, X ; reset index
	MOV sum, #0 ; reset sum.
	call calculate_sum_signed
	; check for overflow to skip division
	ld A, average_result
	cp A, #$FF
	jreq overflow_present_signed
	; do division
	ld A, sum
	sra A
	sra A
	ld average_result, A
overflow_present_signed
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
