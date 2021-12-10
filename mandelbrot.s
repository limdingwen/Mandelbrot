	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 12, 0	sdk_version 12, 0
	.globl	_color_lerp                     ; -- Begin function color_lerp
	.p2align	2
_color_lerp:                            ; @color_lerp
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48                     ; =48
	.cfi_def_cfa_offset 48
	str	s0, [sp, #24]
	str	s1, [sp, #28]
	str	s2, [sp, #32]
	str	s3, [sp, #12]
	str	s4, [sp, #16]
	str	s5, [sp, #20]
	str	s6, [sp, #8]
	ldr	s0, [sp, #8]
	fmov	s1, #1.00000000
	fcmp	s0, s1
	b.le	LBB0_2
; %bb.1:
	fmov	s0, #1.00000000
	str	s0, [sp, #8]
LBB0_2:
	ldr	s0, [sp, #8]
	fcmp	s0, #0.0
	b.pl	LBB0_4
; %bb.3:
	movi.2d	v0, #0000000000000000
	str	s0, [sp, #8]
LBB0_4:
	ldr	s0, [sp, #24]
	ldr	s1, [sp, #12]
	ldr	s2, [sp, #24]
	fsub	s1, s1, s2
	ldr	s2, [sp, #8]
	fmul	s1, s1, s2
	fadd	s0, s0, s1
	str	s0, [sp, #36]
	ldr	s0, [sp, #28]
	ldr	s1, [sp, #16]
	ldr	s2, [sp, #28]
	fsub	s1, s1, s2
	ldr	s2, [sp, #8]
	fmul	s1, s1, s2
	fadd	s0, s0, s1
	str	s0, [sp, #40]
	ldr	s0, [sp, #32]
	ldr	s1, [sp, #20]
	ldr	s2, [sp, #32]
	fsub	s1, s1, s2
	ldr	s2, [sp, #8]
	fmul	s1, s1, s2
	fadd	s0, s0, s1
	str	s0, [sp, #44]
	ldr	s0, [sp, #36]
	ldr	s1, [sp, #40]
	ldr	s2, [sp, #44]
	add	sp, sp, #48                     ; =48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_gradient_color                 ; -- Begin function gradient_color
	.p2align	2
_gradient_color:                        ; @gradient_color
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64                     ; =64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48                    ; =48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	x0, [sp, #16]
	str	x1, [sp, #24]
	str	w2, [sp, #12]
	ldr	w10, [sp, #20]
	ldr	w8, [sp, #12]
	sdiv	w9, w8, w10
	mul	w9, w9, w10
	subs	w8, w8, w9
	str	w8, [sp, #12]
	ldr	w8, [sp, #12]
	scvtf	s0, w8
	ldr	w8, [sp, #20]
	scvtf	s1, w8
	fdiv	s0, s0, s1
	ldr	w8, [sp, #16]
	scvtf	s1, w8
	fmul	s0, s0, s1
	fcvtzs	w8, s0
	str	w8, [sp, #8]
	ldr	w8, [sp, #8]
	add	w8, w8, #1                      ; =1
	str	w8, [sp, #4]
	ldr	w8, [sp, #12]
	scvtf	s0, w8
	ldr	w8, [sp, #20]
	scvtf	s1, w8
	fdiv	s0, s0, s1
	ldr	w8, [sp, #16]
	scvtf	s1, w8
	fmul	s0, s0, s1
	ldr	w8, [sp, #8]
	scvtf	s1, w8
	fsub	s0, s0, s1
	str	s0, [sp]
	ldr	x8, [sp, #24]
	ldrsw	x9, [sp, #8]
	mov	x11, #12
	mul	x9, x9, x11
	add	x9, x8, x9
	ldr	x8, [sp, #24]
	ldrsw	x10, [sp, #4]
	mul	x10, x10, x11
	add	x8, x8, x10
	ldr	s6, [sp]
	ldr	s0, [x9]
	ldr	s1, [x9, #4]
	ldr	s2, [x9, #8]
	ldr	s3, [x8]
	ldr	s4, [x8, #4]
	ldr	s5, [x8, #8]
	bl	_color_lerp
	stur	s0, [x29, #-12]
	stur	s1, [x29, #-8]
	stur	s2, [x29, #-4]
	ldur	s0, [x29, #-12]
	ldur	s1, [x29, #-8]
	ldur	s2, [x29, #-4]
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64                     ; =64
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fp_add                         ; -- Begin function fp_add
	.p2align	2
_fp_add:                                ; @fp_add
	.cfi_startproc
; %bb.0:
	mov	x9, x8
	mov	x8, x1
	ldr	x13, [x0]
	ldr	x14, [x0, #8]
	ldr	x15, [x0, #16]
	ldr	x16, [x0, #24]
	ldr	x17, [x8]
	ldr	x0, [x8, #8]
	ldr	x1, [x8, #16]
	ldr	x2, [x8, #24]
	; InlineAsm Start
	adds	x8, x16, x2
	adc	x10, x15, x1
	adc	x11, x14, x0
	adc	x12, x13, x17
	; InlineAsm End
	str	x12, [x9]
	str	x11, [x9, #8]
	str	x10, [x9, #16]
	str	x8, [x9, #24]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_add                    ; -- Begin function complex_add
	.p2align	2
_complex_add:                           ; @complex_add
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48                     ; =48
	.cfi_def_cfa_offset 48
	str	d0, [sp, #16]
	str	d1, [sp, #24]
	str	d2, [sp]
	str	d3, [sp, #8]
	ldr	d0, [sp, #16]
	ldr	d1, [sp]
	fadd	d0, d0, d1
	str	d0, [sp, #32]
	ldr	d0, [sp, #24]
	ldr	d1, [sp, #8]
	fadd	d0, d0, d1
	str	d0, [sp, #40]
	ldr	d0, [sp, #32]
	ldr	d1, [sp, #40]
	add	sp, sp, #48                     ; =48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_mul                    ; -- Begin function complex_mul
	.p2align	2
_complex_mul:                           ; @complex_mul
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48                     ; =48
	.cfi_def_cfa_offset 48
	str	d0, [sp, #16]
	str	d1, [sp, #24]
	str	d2, [sp]
	str	d3, [sp, #8]
	ldr	d0, [sp, #16]
	ldr	d1, [sp]
	fmul	d0, d0, d1
	ldr	d1, [sp, #24]
	ldr	d2, [sp, #8]
	fmul	d1, d1, d2
	fsub	d0, d0, d1
	str	d0, [sp, #32]
	ldr	d0, [sp, #16]
	ldr	d1, [sp, #8]
	fmul	d0, d0, d1
	ldr	d1, [sp]
	ldr	d2, [sp, #24]
	fmul	d1, d1, d2
	fadd	d0, d0, d1
	str	d0, [sp, #40]
	ldr	d0, [sp, #32]
	ldr	d1, [sp, #40]
	add	sp, sp, #48                     ; =48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_sqr                    ; -- Begin function complex_sqr
	.p2align	2
_complex_sqr:                           ; @complex_sqr
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48                     ; =48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32                    ; =32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	str	d0, [sp]
	str	d1, [sp, #8]
	ldr	d0, [sp]
	ldr	d1, [sp, #8]
	ldr	d2, [sp]
	ldr	d3, [sp, #8]
	bl	_complex_mul
	str	d0, [sp, #16]
	str	d1, [sp, #24]
	ldr	d0, [sp, #16]
	ldr	d1, [sp, #24]
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48                     ; =48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_sqrmag                 ; -- Begin function complex_sqrmag
	.p2align	2
_complex_sqrmag:                        ; @complex_sqrmag
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16                     ; =16
	.cfi_def_cfa_offset 16
	str	d0, [sp]
	str	d1, [sp, #8]
	ldr	d0, [sp]
	ldr	d1, [sp]
	fmul	d0, d0, d1
	ldr	d1, [sp, #8]
	ldr	d2, [sp, #8]
	fmul	d1, d1, d2
	fadd	d0, d0, d1
	add	sp, sp, #16                     ; =16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_calculateMathPos               ; -- Begin function calculateMathPos
	.p2align	2
_calculateMathPos:                      ; @calculateMathPos
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32                     ; =32
	.cfi_def_cfa_offset 32
	str	w0, [sp, #28]
	str	w1, [sp, #24]
	str	d0, [sp, #16]
	str	d1, [sp, #8]
	ldr	d0, [sp, #8]
	ldr	d1, [sp, #16]
	fmov	d2, #2.00000000
	fdiv	d1, d1, d2
	fsub	d0, d0, d1
	str	d0, [sp]
	ldr	s1, [sp, #28]
                                        ; implicit-def: $d0
	mov.16b	v0, v1
	sshll.2d	v0, v0, #0
                                        ; kill: def $d0 killed $d0 killed $q0
	scvtf	d0, d0
	ldr	s2, [sp, #24]
                                        ; implicit-def: $d1
	mov.16b	v1, v2
	sshll.2d	v1, v1, #0
                                        ; kill: def $d1 killed $d1 killed $q1
	scvtf	d1, d1
	fdiv	d0, d0, d1
	ldr	d1, [sp, #16]
	fmul	d0, d0, d1
	ldr	d1, [sp]
	fadd	d0, d0, d1
	add	sp, sp, #32                     ; =32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_process_mandelbrot             ; -- Begin function process_mandelbrot
	.p2align	2
_process_mandelbrot:                    ; @process_mandelbrot
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #128                    ; =128
	stp	x29, x30, [sp, #112]            ; 16-byte Folded Spill
	add	x29, sp, #112                   ; =112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	d0, [x29, #-16]
	stur	d1, [x29, #-24]
	stur	w0, [x29, #-28]
	ldur	d0, [x29, #-16]
	stur	d0, [x29, #-48]
	ldur	d0, [x29, #-24]
	stur	d0, [x29, #-40]
	str	xzr, [sp, #48]
	str	xzr, [sp, #56]
	str	wzr, [sp, #44]
LBB8_1:                                 ; =>This Inner Loop Header: Depth=1
	ldr	w8, [sp, #44]
	ldur	w9, [x29, #-28]
	subs	w8, w8, w9
	b.ge	LBB8_6
; %bb.2:                                ;   in Loop: Header=BB8_1 Depth=1
	ldr	d0, [sp, #48]
	ldr	d1, [sp, #56]
	bl	_complex_sqr
	str	d0, [sp, #8]
	str	d1, [sp, #16]
	ldr	d0, [sp, #8]
	ldr	d1, [sp, #16]
	ldur	d2, [x29, #-48]
	ldur	d3, [x29, #-40]
	bl	_complex_add
	str	d0, [sp, #24]
	str	d1, [sp, #32]
	ldur	q0, [sp, #24]
	str	q0, [sp, #48]
	ldr	d0, [sp, #48]
	ldr	d1, [sp, #56]
	bl	_complex_sqrmag
	fmov	d1, #4.00000000
	fcmp	d0, d1
	b.le	LBB8_4
; %bb.3:
	sturb	wzr, [x29, #-8]
	ldr	w8, [sp, #44]
	stur	w8, [x29, #-4]
	b	LBB8_7
LBB8_4:                                 ;   in Loop: Header=BB8_1 Depth=1
; %bb.5:                                ;   in Loop: Header=BB8_1 Depth=1
	ldr	w8, [sp, #44]
	add	w8, w8, #1                      ; =1
	str	w8, [sp, #44]
	b	LBB8_1
LBB8_6:
	mov	w8, #1
	sturb	w8, [x29, #-8]
	mov	w8, #-1
	stur	w8, [x29, #-4]
LBB8_7:
	ldur	x0, [x29, #-8]
	ldp	x29, x30, [sp, #112]            ; 16-byte Folded Reload
	add	sp, sp, #128                    ; =128
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_thread                         ; -- Begin function thread
	.p2align	2
_thread:                                ; @thread
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #128                    ; =128
	stp	x29, x30, [sp, #112]            ; 16-byte Folded Spill
	add	x29, sp, #112                   ; =112
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-8]
	ldur	x8, [x29, #-8]
	stur	x8, [x29, #-16]
	ldur	x8, [x29, #-16]
	ldr	w8, [x8]
	stur	w8, [x29, #-20]
LBB9_1:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB9_3 Depth 2
	ldur	w8, [x29, #-20]
	ldur	x9, [x29, #-16]
	ldr	w9, [x9, #4]
	subs	w8, w8, w9
	b.gt	LBB9_11
; %bb.2:                                ;   in Loop: Header=BB9_1 Depth=1
	ldur	w0, [x29, #-20]
	ldur	x8, [x29, #-16]
	ldr	w1, [x8, #16]
	ldur	x8, [x29, #-16]
	ldr	d0, [x8, #24]
	fmov	d1, #1.50000000
	fmul	d0, d0, d1
	ldur	x8, [x29, #-16]
	ldr	d1, [x8, #32]
	bl	_calculateMathPos
	stur	d0, [x29, #-32]
	ldur	x8, [x29, #-16]
	ldr	w8, [x8, #8]
	stur	w8, [x29, #-36]
LBB9_3:                                 ;   Parent Loop BB9_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldur	w8, [x29, #-36]
	ldur	x9, [x29, #-16]
	ldr	w9, [x9, #12]
	subs	w8, w8, w9
	b.gt	LBB9_9
; %bb.4:                                ;   in Loop: Header=BB9_3 Depth=2
	ldur	x8, [x29, #-16]
	ldr	w8, [x8, #20]
	ldur	w9, [x29, #-36]
	subs	w0, w8, w9
	ldur	x8, [x29, #-16]
	ldr	w1, [x8, #20]
	ldur	x8, [x29, #-16]
	ldr	d0, [x8, #24]
	fmov	d1, #1.00000000
	fmul	d0, d0, d1
	ldur	x8, [x29, #-16]
	ldr	d1, [x8, #40]
	bl	_calculateMathPos
	stur	d0, [x29, #-48]
	ldur	d0, [x29, #-32]
	ldur	d1, [x29, #-48]
	ldur	x8, [x29, #-16]
	ldr	w0, [x8, #48]
	bl	_process_mandelbrot
	str	x0, [sp, #56]
	ldrb	w8, [sp, #56]
	tbz	w8, #0, LBB9_6
; %bb.5:                                ;   in Loop: Header=BB9_3 Depth=2
	str	wzr, [sp, #28]
	str	wzr, [sp, #32]
	str	wzr, [sp, #36]
	ldur	x8, [sp, #28]
	str	x8, [sp, #40]
	ldr	w8, [sp, #36]
	str	w8, [sp, #48]
	b	LBB9_7
LBB9_6:                                 ;   in Loop: Header=BB9_3 Depth=2
	ldr	w2, [sp, #60]
	adrp	x9, _thread.gradient@PAGE
	adrp	x8, _thread.gradient@PAGE
	add	x8, x8, _thread.gradient@PAGEOFF
	ldr	x0, [x9, _thread.gradient@PAGEOFF]
	ldr	x1, [x8, #8]
	bl	_gradient_color
	str	s0, [sp, #16]
	str	s1, [sp, #20]
	str	s2, [sp, #24]
	ldr	x8, [sp, #16]
	str	x8, [sp, #40]
	ldr	w8, [sp, #24]
	str	w8, [sp, #48]
LBB9_7:                                 ;   in Loop: Header=BB9_3 Depth=2
	ldur	w8, [x29, #-36]
	ldur	x9, [x29, #-16]
	ldr	w9, [x9, #16]
	mul	w8, w8, w9
	ldur	w9, [x29, #-20]
	add	w8, w8, w9
	lsl	w8, w8, #2
	str	w8, [sp, #12]
	ldr	s0, [sp, #40]
	fcvtzu	w8, s0
	ldur	x9, [x29, #-16]
	ldr	x9, [x9, #56]
	ldrsw	x10, [sp, #12]
	add	x9, x9, x10
	strb	w8, [x9]
	ldr	s0, [sp, #44]
	fcvtzu	w8, s0
	ldur	x9, [x29, #-16]
	ldr	x9, [x9, #56]
	ldr	w10, [sp, #12]
	add	w10, w10, #1                    ; =1
	add	x9, x9, w10, sxtw
	strb	w8, [x9]
	ldr	s0, [sp, #48]
	fcvtzu	w8, s0
	ldur	x9, [x29, #-16]
	ldr	x9, [x9, #56]
	ldr	w10, [sp, #12]
	add	w10, w10, #2                    ; =2
	add	x9, x9, w10, sxtw
	strb	w8, [x9]
	ldur	x8, [x29, #-16]
	ldr	x8, [x8, #56]
	ldr	w9, [sp, #12]
	add	w9, w9, #3                      ; =3
	add	x9, x8, w9, sxtw
	mov	w8, #255
	strb	w8, [x9]
; %bb.8:                                ;   in Loop: Header=BB9_3 Depth=2
	ldur	w8, [x29, #-36]
	add	w8, w8, #1                      ; =1
	stur	w8, [x29, #-36]
	b	LBB9_3
LBB9_9:                                 ;   in Loop: Header=BB9_1 Depth=1
; %bb.10:                               ;   in Loop: Header=BB9_1 Depth=1
	ldur	w8, [x29, #-20]
	add	w8, w8, #1                      ; =1
	stur	w8, [x29, #-20]
	b	LBB9_1
LBB9_11:
	mov	x0, #0
	bl	_pthread_exit
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #208                    ; =208
	stp	x29, x30, [sp, #192]            ; 16-byte Folded Spill
	add	x29, sp, #192                   ; =192
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	sub	x8, x29, #48                    ; =48
	stur	wzr, [x29, #-4]
	adrp	x9, l___const.main.a@PAGE
	add	x9, x9, l___const.main.a@PAGEOFF
	ldr	q0, [x9]
	str	q0, [x8]
	ldr	q0, [x9, #16]
	str	q0, [x8, #16]
	adrp	x9, l___const.main.b@PAGE
	add	x9, x9, l___const.main.b@PAGEOFF
	ldr	q0, [x9]
	stur	q0, [x29, #-80]
	ldr	q0, [x9, #16]
	stur	q0, [x29, #-64]
	ldr	q0, [x8]
	add	x0, sp, #48                     ; =48
	str	q0, [sp, #48]
	ldr	q0, [x8, #16]
	str	q0, [sp, #64]
	ldur	q0, [x29, #-80]
	add	x1, sp, #16                     ; =16
	str	q0, [sp, #16]
	ldur	q0, [x29, #-64]
	str	q0, [sp, #32]
	add	x8, sp, #80                     ; =80
	bl	_fp_add
	adrp	x0, l_.str@PAGE
	add	x0, x0, l_.str@PAGEOFF
	bl	_printf
	str	wzr, [sp, #12]
LBB10_1:                                ; =>This Inner Loop Header: Depth=1
	ldr	w8, [sp, #12]
	subs	w8, w8, #4                      ; =4
	b.ge	LBB10_4
; %bb.2:                                ;   in Loop: Header=BB10_1 Depth=1
	ldrsw	x9, [sp, #12]
	add	x8, sp, #80                     ; =80
	ldr	x8, [x8, x9, lsl #3]
	adrp	x0, l_.str.1@PAGE
	add	x0, x0, l_.str.1@PAGEOFF
	mov	x9, sp
	str	x8, [x9]
	bl	_printf
; %bb.3:                                ;   in Loop: Header=BB10_1 Depth=1
	ldr	w8, [sp, #12]
	add	w8, w8, #1                      ; =1
	str	w8, [sp, #12]
	b	LBB10_1
LBB10_4:
	adrp	x0, l_.str.2@PAGE
	add	x0, x0, l_.str.2@PAGEOFF
	bl	_puts
	mov	w0, #0
	ldp	x29, x30, [sp, #192]            ; 16-byte Folded Reload
	add	sp, sp, #208                    ; =208
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__const
	.globl	_thread_blocks                  ; @thread_blocks
	.p2align	2
_thread_blocks:
	.long	0                               ; 0x0
	.long	224                             ; 0xe0
	.long	0                               ; 0x0
	.long	299                             ; 0x12b
	.long	225                             ; 0xe1
	.long	449                             ; 0x1c1
	.long	0                               ; 0x0
	.long	299                             ; 0x12b
	.long	450                             ; 0x1c2
	.long	674                             ; 0x2a2
	.long	0                               ; 0x0
	.long	299                             ; 0x12b
	.long	675                             ; 0x2a3
	.long	899                             ; 0x383
	.long	0                               ; 0x0
	.long	299                             ; 0x12b
	.long	0                               ; 0x0
	.long	224                             ; 0xe0
	.long	300                             ; 0x12c
	.long	599                             ; 0x257
	.long	225                             ; 0xe1
	.long	449                             ; 0x1c1
	.long	300                             ; 0x12c
	.long	599                             ; 0x257
	.long	450                             ; 0x1c2
	.long	674                             ; 0x2a2
	.long	300                             ; 0x12c
	.long	599                             ; 0x257
	.long	675                             ; 0x2a3
	.long	899                             ; 0x383
	.long	300                             ; 0x12c
	.long	599                             ; 0x257

	.globl	_gradient_stops                 ; @gradient_stops
	.p2align	2
_gradient_stops:
	.long	0x00000000                      ; float 0
	.long	0x00000000                      ; float 0
	.long	0x437f0000                      ; float 255
	.long	0x437f0000                      ; float 255
	.long	0x437f0000                      ; float 255
	.long	0x00000000                      ; float 0
	.long	0x00000000                      ; float 0
	.long	0x437f0000                      ; float 255
	.long	0x00000000                      ; float 0
	.long	0x437f0000                      ; float 255
	.long	0x00000000                      ; float 0
	.long	0x00000000                      ; float 0
	.long	0x00000000                      ; float 0
	.long	0x00000000                      ; float 0
	.long	0x437f0000                      ; float 255

	.section	__DATA,__const
	.p2align	3                               ; @thread.gradient
_thread.gradient:
	.long	4                               ; 0x4
	.long	64                              ; 0x40
	.quad	_gradient_stops

	.section	__TEXT,__const
	.p2align	3                               ; @__const.main.a
l___const.main.a:
	.quad	0                               ; 0x0
	.quad	0                               ; 0x0
	.quad	0                               ; 0x0
	.quad	253                             ; 0xfd

	.p2align	3                               ; @__const.main.b
l___const.main.b:
	.quad	0                               ; 0x0
	.quad	0                               ; 0x0
	.quad	0                               ; 0x0
	.quad	20                              ; 0x14

	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"c = "

l_.str.1:                               ; @.str.1
	.asciz	"%llu "

l_.str.2:                               ; @.str.2
	.space	1

.subsections_via_symbols
