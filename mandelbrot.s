	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 12, 0	sdk_version 12, 0
	.globl	_color_lerp                     ; -- Begin function color_lerp
	.p2align	2
_color_lerp:                            ; @color_lerp
	.cfi_startproc
; %bb.0:
	fmov	s7, #1.00000000
	fminnm	s6, s6, s7
	movi.2d	v7, #0000000000000000
	fmaxnm	s6, s6, s7
	fsub	s3, s3, s0
	fmadd	s0, s6, s3, s0
	fsub	s3, s4, s1
	fmadd	s1, s6, s3, s1
	fsub	s3, s5, s2
	fmadd	s2, s6, s3, s2
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_gradient_color                 ; -- Begin function gradient_color
	.p2align	2
_gradient_color:                        ; @gradient_color
	.cfi_startproc
; %bb.0:
	lsr	x8, x0, #32
	sdiv	w9, w2, w8
	msub	w9, w9, w8, w2
	scvtf	s0, w9
	scvtf	s1, w8
	scvtf	s2, w0
	fmul	s0, s0, s2
	fdiv	s0, s0, s1
	fcvtzs	w8, s0
	frintz	s1, s0
	fsub	s1, s0, s1
	mov	w9, #12
	smaddl	x8, w8, w9, x1
	ldr	d0, [x8]
	ldr	s2, [x8, #8]
	ldur	d3, [x8, #12]
	ldr	s4, [x8, #20]
	fmov	s5, #1.00000000
	fminnm	s1, s1, s5
	movi.2d	v5, #0000000000000000
	fmaxnm	s1, s1, s5
	fsub.2s	v3, v3, v0
	fmla.2s	v0, v3, v1[0]
	fsub	s3, s4, s2
	fmadd	s2, s1, s3, s2
	mov	s1, v0[1]
                                        ; kill: def $s0 killed $s0 killed $q0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fp_uadd256                     ; -- Begin function fp_uadd256
	.p2align	2
_fp_uadd256:                            ; @fp_uadd256
	.cfi_startproc
; %bb.0:
	ldp	x9, x10, [x0, #8]
	ldp	x11, x12, [x0, #24]
	ldp	x13, x14, [x1, #8]
	ldp	x15, x16, [x1, #24]
	; InlineAsm Start
	adds	x2, x12, x16
	adcs	x1, x11, x15
	adcs	x0, x10, x14
	adcs	x17, x9, x13
	; InlineAsm End
	stp	x17, x0, [x8, #8]
	stp	x1, x2, [x8, #24]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fp_usub256                     ; -- Begin function fp_usub256
	.p2align	2
_fp_usub256:                            ; @fp_usub256
	.cfi_startproc
; %bb.0:
	ldp	x9, x10, [x0, #8]
	ldp	x11, x12, [x0, #24]
	ldp	x13, x14, [x1, #8]
	ldp	x15, x16, [x1, #24]
	; InlineAsm Start
	subs	x2, x12, x16
	sbcs	x1, x11, x15
	sbcs	x0, x10, x14
	sbcs	x17, x9, x13
	; InlineAsm End
	stp	x17, x0, [x8, #8]
	stp	x1, x2, [x8, #24]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fp_uadd512                     ; -- Begin function fp_uadd512
	.p2align	2
_fp_uadd512:                            ; @fp_uadd512
	.cfi_startproc
; %bb.0:
	stp	x26, x25, [sp, #-64]!           ; 16-byte Folded Spill
	stp	x24, x23, [sp, #16]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #32]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 64
	.cfi_offset w19, -8
	.cfi_offset w20, -16
	.cfi_offset w21, -24
	.cfi_offset w22, -32
	.cfi_offset w23, -40
	.cfi_offset w24, -48
	.cfi_offset w25, -56
	.cfi_offset w26, -64
	ldp	x9, x10, [x0, #8]
	ldp	x11, x12, [x0, #24]
	ldp	x13, x14, [x0, #40]
	ldp	x15, x16, [x0, #56]
	ldp	x17, x0, [x1, #8]
	ldp	x2, x3, [x1, #24]
	ldp	x4, x5, [x1, #40]
	ldp	x6, x1, [x1, #56]
	; InlineAsm Start
	adds	x25, x16, x1
	adcs	x24, x15, x6
	adcs	x23, x14, x5
	adcs	x22, x13, x4
	adcs	x21, x12, x3
	adcs	x20, x11, x2
	adcs	x19, x10, x0
	adcs	x7, x9, x17
	; InlineAsm End
	stp	x7, x19, [x8, #8]
	stp	x20, x21, [x8, #24]
	stp	x22, x23, [x8, #40]
	stp	x24, x25, [x8, #56]
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #32]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #16]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp], #64             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fp_ucmp256                     ; -- Begin function fp_ucmp256
	.p2align	2
_fp_ucmp256:                            ; @fp_ucmp256
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48                     ; =48
	.cfi_def_cfa_offset 48
	ldp	x8, x9, [x0, #8]
	ldp	x10, x11, [x0, #24]
	ldp	x12, x13, [x1, #8]
	ldp	x14, x15, [x1, #24]
	; InlineAsm Start
	subs	x1, x11, x15
	sbcs	x0, x10, x14
	sbcs	x17, x9, x13
	sbcs	x16, x8, x12
	; InlineAsm End
	stp	x16, x17, [sp, #16]
	stp	x0, x1, [sp, #32]
	tbnz	x16, #63, LBB5_2
; %bb.1:
	ldp	x8, x9, [sp, #16]
	ldp	x10, x11, [sp, #32]
	orr	x8, x8, x9
	orr	x9, x10, x11
	orr	x8, x8, x9
	cmp	x8, #0                          ; =0
	cset	w0, ne
	add	sp, sp, #48                     ; =48
	ret
LBB5_2:
	mov	w0, #2
	add	sp, sp, #48                     ; =48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fp_sadd256                     ; -- Begin function fp_sadd256
	.p2align	2
_fp_sadd256:                            ; @fp_sadd256
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64                     ; =64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48                    ; =48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	ldr	w10, [x0]
	ldr	w9, [x1]
	cmp	w10, #1                         ; =1
	b.ne	LBB6_3
; %bb.1:
	cmp	w9, #1                          ; =1
	b.eq	LBB6_4
; %bb.2:
	ldp	q0, q1, [x1]
	ldr	x9, [x1, #32]
	b	LBB6_5
LBB6_3:
	cmp	w9, #1                          ; =1
	b.ne	LBB6_6
LBB6_4:
	ldp	q0, q1, [x0]
	ldr	x9, [x0, #32]
LBB6_5:
	str	x9, [x8, #32]
	stp	q0, q1, [x8]
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64                     ; =64
	ret
LBB6_6:
	cbz	w10, LBB6_10
; %bb.7:
	cmp	w10, #2                         ; =2
	b.ne	LBB6_22
; %bb.8:
	cbz	w9, LBB6_12
; %bb.9:
	cmp	w9, #2                          ; =2
	b.eq	LBB6_11
	b	LBB6_22
LBB6_10:
	cbnz	w9, LBB6_13
LBB6_11:
	ldp	x9, x11, [x0, #8]
	ldp	x12, x13, [x0, #24]
	ldp	x14, x15, [x1, #8]
	ldp	x16, x17, [x1, #24]
	; InlineAsm Start
	adds	x3, x13, x17
	adcs	x2, x12, x16
	adcs	x1, x11, x15
	adcs	x0, x9, x14
	; InlineAsm End
	stp	x0, x1, [x8, #8]
	stp	x2, x3, [x8, #24]
	str	w10, [x8]
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64                     ; =64
	ret
LBB6_12:
	mov	w10, #1
	b	LBB6_15
LBB6_13:
	cmp	w9, #2                          ; =2
	b.ne	LBB6_22
; %bb.14:
	mov	w10, #0
LBB6_15:
	ldp	x11, x12, [x0, #8]
	ldp	x13, x14, [x0, #24]
	ldp	x15, x16, [x1, #8]
	ldp	x17, x0, [x1, #24]
	; InlineAsm Start
	subs	x1, x14, x0
	sbcs	x2, x13, x17
	sbcs	x3, x12, x16
	sbcs	x4, x11, x15
	; InlineAsm End
	stp	x4, x3, [sp, #16]
	stp	x2, x1, [sp, #32]
	tbnz	x4, #63, LBB6_19
; %bb.16:
	ldp	x11, x12, [sp, #16]
	ldp	x13, x14, [sp, #32]
	orr	x11, x11, x12
	orr	x12, x13, x14
	orr	x11, x11, x12
	cbz	x11, LBB6_21
; %bb.17:
	cmp	w9, #0                          ; =0
	cset	w9, ne
	eor	w10, w10, #0x1
	stp	x4, x3, [x8, #8]
	stp	x2, x1, [x8, #24]
	orr	w9, w9, w10
	tbnz	w9, #0, LBB6_20
LBB6_18:
	mov	w9, #2
	str	w9, [x8]
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64                     ; =64
	ret
LBB6_19:
	cmp	w9, #0                          ; =0
	cset	w9, eq
	; InlineAsm Start
	subs	x4, x0, x14
	sbcs	x3, x17, x13
	sbcs	x2, x16, x12
	sbcs	x1, x15, x11
	; InlineAsm End
	stp	x1, x2, [x8, #8]
	and	w9, w9, w10
	stp	x3, x4, [x8, #24]
	tbz	w9, #0, LBB6_18
LBB6_20:
	str	wzr, [x8]
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64                     ; =64
	ret
LBB6_21:
	movi.2d	v0, #0000000000000000
	str	xzr, [x8, #32]
	stp	q0, q0, [x8]
	mov	w9, #1
	str	w9, [x8]
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64                     ; =64
	ret
LBB6_22:
	bl	_fp_sadd256.cold.1
	.cfi_endproc
                                        ; -- End function
	.globl	_fp_smul256                     ; -- Begin function fp_smul256
	.p2align	2
_fp_smul256:                            ; @fp_smul256
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #224                    ; =224
	stp	x28, x27, [sp, #128]            ; 16-byte Folded Spill
	stp	x26, x25, [sp, #144]            ; 16-byte Folded Spill
	stp	x24, x23, [sp, #160]            ; 16-byte Folded Spill
	stp	x22, x21, [sp, #176]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #192]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #208]            ; 16-byte Folded Spill
	.cfi_def_cfa_offset 224
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	str	x1, [sp, #40]                   ; 8-byte Folded Spill
	ldr	w9, [x0]
	cmp	w9, #1                          ; =1
	b.eq	LBB7_2
; %bb.1:
	ldr	x10, [sp, #40]                  ; 8-byte Folded Reload
	ldr	w10, [x10]
	cmp	w10, #1                         ; =1
	b.ne	LBB7_3
LBB7_2:
	movi.2d	v0, #0000000000000000
	str	xzr, [x8, #32]
	stp	q0, q0, [x8]
	mov	w9, #1
	str	w9, [x8]
	b	LBB7_6
LBB7_3:
	stp	x8, x0, [sp, #16]               ; 16-byte Folded Spill
	mov	x13, #0
	mov	x16, #0
	mov	x15, #0
	mov	x1, #0
	mov	x17, #0
	mov	x14, #0
	mov	x11, #0
	mov	x5, #0
	cmp	w10, #0                         ; =0
	ccmp	w9, #0, #4, ne
	orr	w9, w10, w9
	mov	w10, #2
	csel	w8, wzr, w10, eq
	cmp	w9, #0                          ; =0
	csel	w8, w10, w8, eq
	str	w8, [sp, #12]                   ; 4-byte Folded Spill
	ldr	x8, [sp, #40]                   ; 8-byte Folded Reload
	ldr	x8, [x8, #32]
	str	x8, [sp, #32]                   ; 8-byte Folded Spill
	mov	w0, #32
	movi.2d	v0, #0000000000000000
LBB7_4:                                 ; =>This Inner Loop Header: Depth=1
	ldr	x8, [sp, #24]                   ; 8-byte Folded Reload
	ldr	x2, [x8, x0]
	ldr	x8, [sp, #32]                   ; 8-byte Folded Reload
	umulh	x7, x8, x2
	mul	x19, x8, x2
	str	xzr, [sp, #112]
	stp	q0, q0, [sp, #80]
	stp	q0, q0, [sp, #48]
	add	x8, sp, #48                     ; =48
	add	x6, x8, x0
	stp	x7, x19, [x6, #24]
	ldp	x7, x19, [sp, #56]
	ldp	x20, x21, [sp, #72]
	ldp	x22, x23, [sp, #88]
	ldp	x24, x25, [sp, #104]
	; InlineAsm Start
	adds	x8, x5, x25
	adcs	x10, x11, x24
	adcs	x12, x14, x23
	adcs	x9, x17, x22
	adcs	x30, x1, x21
	adcs	x28, x15, x20
	adcs	x27, x16, x19
	adcs	x26, x13, x7
	; InlineAsm End
	ldr	x11, [sp, #40]                  ; 8-byte Folded Reload
	ldr	x13, [x11, #24]
	umulh	x14, x13, x2
	mul	x13, x13, x2
	str	xzr, [sp, #112]
	stp	q0, q0, [sp, #80]
	stp	q0, q0, [sp, #48]
	stp	x14, x13, [x6, #16]
	ldp	x13, x14, [sp, #56]
	ldp	x15, x16, [sp, #72]
	ldp	x17, x3, [sp, #88]
	ldp	x4, x5, [sp, #104]
	; InlineAsm Start
	adds	x25, x8, x5
	adcs	x24, x10, x4
	adcs	x23, x12, x3
	adcs	x22, x9, x17
	adcs	x21, x30, x16
	adcs	x20, x28, x15
	adcs	x19, x27, x14
	adcs	x7, x26, x13
	; InlineAsm End
	ldr	x8, [x11, #16]
	umulh	x9, x8, x2
	mul	x8, x8, x2
	str	xzr, [sp, #112]
	stp	q0, q0, [sp, #80]
	stp	q0, q0, [sp, #48]
	stp	x9, x8, [x6, #8]
	ldp	x8, x9, [sp, #56]
	ldp	x10, x12, [sp, #72]
	ldp	x13, x14, [sp, #88]
	ldp	x15, x16, [sp, #104]
	; InlineAsm Start
	adds	x3, x25, x16
	adcs	x1, x24, x15
	adcs	x17, x23, x14
	adcs	x4, x22, x13
	adcs	x30, x21, x12
	adcs	x28, x20, x10
	adcs	x27, x19, x9
	adcs	x26, x7, x8
	; InlineAsm End
	ldr	x8, [x11, #8]
	umulh	x9, x8, x2
	mul	x8, x8, x2
	str	xzr, [sp, #112]
	stp	q0, q0, [sp, #80]
	stp	q0, q0, [sp, #48]
	stp	x9, x8, [x6]
	ldp	x8, x9, [sp, #56]
	ldp	x10, x12, [sp, #72]
	ldp	x2, x6, [sp, #88]
	ldp	x7, x19, [sp, #104]
	; InlineAsm Start
	adds	x5, x3, x19
	adcs	x11, x1, x7
	adcs	x14, x17, x6
	adcs	x20, x4, x2
	adcs	x21, x30, x12
	adcs	x15, x28, x10
	adcs	x16, x27, x9
	adcs	x13, x26, x8
	; InlineAsm End
	mov	x1, x21
	mov	x17, x20
	subs	x0, x0, #8                      ; =8
	b.ne	LBB7_4
; %bb.5:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	w9, [sp, #12]                   ; 4-byte Folded Reload
	str	w9, [x8]
	stp	x16, x15, [x8, #8]
	stp	x1, x17, [x8, #24]
LBB7_6:
	ldp	x29, x30, [sp, #208]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #192]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #176]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #160]            ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #144]            ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #128]            ; 16-byte Folded Reload
	add	sp, sp, #224                    ; =224
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_add                    ; -- Begin function complex_add
	.p2align	2
_complex_add:                           ; @complex_add
	.cfi_startproc
; %bb.0:
	fadd	d0, d2, d0
	fadd	d1, d3, d1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_mul                    ; -- Begin function complex_mul
	.p2align	2
_complex_mul:                           ; @complex_mul
	.cfi_startproc
; %bb.0:
	fmul	d4, d3, d1
	fnmsub	d4, d2, d0, d4
	fmul	d1, d2, d1
	fmadd	d1, d3, d0, d1
	mov.16b	v0, v4
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_sqr                    ; -- Begin function complex_sqr
	.p2align	2
_complex_sqr:                           ; @complex_sqr
	.cfi_startproc
; %bb.0:
	fmul	d2, d1, d1
	fnmsub	d2, d0, d0, d2
	fadd	d1, d1, d1
	fmul	d1, d0, d1
	mov.16b	v0, v2
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_sqrmag                 ; -- Begin function complex_sqrmag
	.p2align	2
_complex_sqrmag:                        ; @complex_sqrmag
	.cfi_startproc
; %bb.0:
	fmul	d1, d1, d1
	fmadd	d0, d0, d0, d1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_calculateMathPos               ; -- Begin function calculateMathPos
	.p2align	2
_calculateMathPos:                      ; @calculateMathPos
	.cfi_startproc
; %bb.0:
	fmov	d2, #-0.50000000
	fmadd	d1, d0, d2, d1
	scvtf	d2, w0
	scvtf	d3, w1
	fmul	d0, d2, d0
	fdiv	d0, d0, d3
	fadd	d0, d1, d0
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_process_mandelbrot             ; -- Begin function process_mandelbrot
	.p2align	2
_process_mandelbrot:                    ; @process_mandelbrot
	.cfi_startproc
; %bb.0:
	cmp	w0, #1                          ; =1
	b.lt	LBB13_3
; %bb.1:
	fmul	d2, d1, d1
	fmadd	d3, d0, d0, d2
	fmov	d2, #4.00000000
	fcmp	d3, d2
	b.le	LBB13_4
; %bb.2:
	mov	x0, #0
	mov	w9, #0
	bfi	x0, x9, #32, #32
	ret
LBB13_3:
	mov	w9, #-1
	mov	w0, #1
	bfi	x0, x9, #32, #32
	ret
LBB13_4:
	mov	w9, #1
	mov.16b	v3, v1
	mov.16b	v4, v0
LBB13_5:                                ; =>This Inner Loop Header: Depth=1
	mov	x8, x9
	cmp	w0, w9
	b.eq	LBB13_8
; %bb.6:                                ;   in Loop: Header=BB13_5 Depth=1
	fmul	d5, d3, d3
	fnmsub	d5, d4, d4, d5
	fadd	d6, d4, d4
	fadd	d4, d5, d0
	fmadd	d3, d3, d6, d1
	fmul	d5, d3, d3
	fmadd	d5, d4, d4, d5
	add	w9, w8, #1                      ; =1
	fcmp	d5, d2
	b.le	LBB13_5
; %bb.7:
	sub	w9, w9, #1                      ; =1
	cmp	w8, w0
	cset	w0, ge
	bfi	x0, x9, #32, #32
	ret
LBB13_8:
	mov	w9, #-1
	cmp	w8, w0
	cset	w0, ge
	bfi	x0, x9, #32, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_thread                         ; -- Begin function thread
	.p2align	2
_thread:                                ; @thread
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	ldp	w8, w14, [x0]
	cmp	w8, w14
	b.le	LBB14_2
LBB14_1:
	mov	x0, #0
	bl	_pthread_exit
LBB14_2:
	ldr	w15, [x0, #12]
	fmov	d0, #-0.75000000
	fmov	d1, #1.50000000
	fmov	d2, #-0.50000000
	mov	w9, #1031798784
	fmov	d3, #4.00000000
Lloh0:
	adrp	x10, _gradient_stops@PAGE
Lloh1:
	add	x10, x10, _gradient_stops@PAGEOFF
	mov	w11, #12
	fmov	s4, #1.00000000
	movi.2d	v5, #0000000000000000
	mov	w12, #255
	b	LBB14_5
LBB14_3:                                ;   in Loop: Header=BB14_5 Depth=1
	ldr	w14, [x0, #4]
LBB14_4:                                ;   in Loop: Header=BB14_5 Depth=1
	add	w13, w8, #1                     ; =1
	cmp	w8, w14
	mov	x8, x13
	b.ge	LBB14_1
LBB14_5:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB14_7 Depth 2
                                        ;       Child Loop BB14_11 Depth 3
	ldr	w13, [x0, #8]
	cmp	w13, w15
	b.gt	LBB14_4
; %bb.6:                                ;   in Loop: Header=BB14_5 Depth=1
	ldp	d18, d6, [x0, #24]
	fmadd	d6, d18, d0, d6
	scvtf	d7, w8
	ldr	s16, [x0, #16]
	sshll.2d	v16, v16, #0
	scvtf	d16, d16
	fmul	d17, d1, d18
	fmul	d7, d7, d17
	fdiv	d7, d7, d16
	fadd	d6, d6, d7
	fmul	d7, d6, d6
LBB14_7:                                ;   Parent Loop BB14_5 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB14_11 Depth 3
	ldr	w14, [x0, #48]
	movi	d16, #0000000000000000
	movi.2d	v17, #0000000000000000
	cmp	w14, #1                         ; =1
	b.lt	LBB14_16
; %bb.8:                                ;   in Loop: Header=BB14_7 Depth=2
	ldr	w15, [x0, #20]
	sub	w16, w15, w13
	ldr	d19, [x0, #40]
	scvtf	d20, w16
	scvtf	d21, w15
	fmadd	d19, d18, d2, d19
	fmul	d18, d18, d20
	fdiv	d18, d18, d21
	fadd	d18, d19, d18
	fmadd	d19, d18, d18, d7
	fcmp	d19, d3
	b.le	LBB14_10
; %bb.9:                                ;   in Loop: Header=BB14_7 Depth=2
	mov	w16, #0
	b	LBB14_15
LBB14_10:                               ;   in Loop: Header=BB14_7 Depth=2
	mov	w16, #1
	mov.16b	v19, v18
	mov.16b	v20, v6
LBB14_11:                               ;   Parent Loop BB14_5 Depth=1
                                        ;     Parent Loop BB14_7 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	mov	x15, x16
	cmp	w14, w16
	b.eq	LBB14_14
; %bb.12:                               ;   in Loop: Header=BB14_11 Depth=3
	fmul	d21, d19, d19
	fnmsub	d21, d20, d20, d21
	fadd	d19, d19, d19
	fmadd	d19, d20, d19, d18
	fadd	d20, d6, d21
	fmul	d21, d19, d19
	fmadd	d21, d20, d20, d21
	add	w16, w15, #1                    ; =1
	fcmp	d21, d3
	b.le	LBB14_11
; %bb.13:                               ;   in Loop: Header=BB14_7 Depth=2
	sub	w16, w16, #1                    ; =1
	cmp	w15, w14
	b.lt	LBB14_15
	b	LBB14_16
LBB14_14:                               ;   in Loop: Header=BB14_7 Depth=2
	mov	w16, #-1
	cmp	w15, w14
	b.ge	LBB14_16
LBB14_15:                               ;   in Loop: Header=BB14_7 Depth=2
	add	w14, w16, #63                   ; =63
	cmp	w16, #0                         ; =0
	csel	w14, w14, w16, lt
	and	w14, w14, #0xffffffc0
	sub	w14, w16, w14
	scvtf	s16, w14
	fmov	s17, w9
	fmul	s16, s16, s17
	fcvtzs	w14, s16
	frintz	s17, s16
	fsub	s17, s16, s17
	smaddl	x14, w14, w11, x10
	ldr	d16, [x14]
	ldr	s18, [x14, #8]
	ldur	d19, [x14, #12]
	ldr	s20, [x14, #20]
	fminnm	s17, s17, s4
	fmaxnm	s17, s17, s5
	fsub.2s	v19, v19, v16
	fmla.2s	v16, v19, v17[0]
	fsub	s19, s20, s18
	fmadd	s17, s19, s17, s18
LBB14_16:                               ;   in Loop: Header=BB14_7 Depth=2
	ldr	w14, [x0, #16]
	madd	w14, w14, w13, w8
	sbfiz	x14, x14, #2, #32
	fcvtzs	w15, s16
	ldr	x16, [x0, #56]
	strb	w15, [x16, x14]
	mov	s16, v16[1]
	fcvtzs	w15, s16
	ldr	x16, [x0, #56]
	sxtw	x14, w14
	orr	x17, x14, #0x1
	strb	w15, [x16, x17]
	fcvtzs	w15, s17
	ldr	x16, [x0, #56]
	orr	x17, x14, #0x2
	strb	w15, [x16, x17]
	ldr	x15, [x0, #56]
	orr	x14, x14, #0x3
	strb	w12, [x15, x14]
	ldr	w15, [x0, #12]
	cmp	w13, w15
	b.ge	LBB14_3
; %bb.17:                               ;   in Loop: Header=BB14_7 Depth=2
	add	w13, w13, #1                    ; =1
	ldr	d18, [x0, #24]
	b	LBB14_7
	.loh AdrpAdd	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__literal16,16byte_literals
	.p2align	4                               ; -- Begin function main
lCPI15_0:
	.long	0                               ; 0x0
	.long	160                             ; 0xa0
	.long	240                             ; 0xf0
	.long	160                             ; 0xa0
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3
lCPI15_1:
	.long	0                               ; 0x0
	.long	299                             ; 0x12b
lCPI15_2:
	.long	900                             ; 0x384
	.long	600                             ; 0x258
lCPI15_3:
	.long	300                             ; 0x12c
	.long	599                             ; 0x257
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	stp	d15, d14, [sp, #-160]!          ; 16-byte Folded Spill
	stp	d13, d12, [sp, #16]             ; 16-byte Folded Spill
	stp	d11, d10, [sp, #32]             ; 16-byte Folded Spill
	stp	d9, d8, [sp, #48]               ; 16-byte Folded Spill
	stp	x28, x27, [sp, #64]             ; 16-byte Folded Spill
	stp	x26, x25, [sp, #80]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #96]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #112]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #128]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #144]            ; 16-byte Folded Spill
	add	x29, sp, #144                   ; =144
	sub	sp, sp, #1136                   ; =1136
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w25, -72
	.cfi_offset w26, -80
	.cfi_offset w27, -88
	.cfi_offset w28, -96
	.cfi_offset b8, -104
	.cfi_offset b9, -112
	.cfi_offset b10, -120
	.cfi_offset b11, -128
	.cfi_offset b12, -136
	.cfi_offset b13, -144
	.cfi_offset b14, -152
	.cfi_offset b15, -160
Lloh2:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh3:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh4:
	ldr	x8, [x8]
	stur	x8, [x29, #-160]
	stp	xzr, xzr, [sp, #216]
	mov	w0, #32
	bl	_SDL_Init
	tbnz	w0, #31, LBB15_74
; %bb.1:
	add	x3, sp, #216                    ; =216
	add	x4, sp, #224                    ; =224
	mov	w0, #900
	mov	w1, #600
	mov	w2, #0
	bl	_SDL_CreateWindowAndRenderer
	cmn	w0, #1                          ; =1
	b.eq	LBB15_75
; %bb.2:
	ldr	x0, [sp, #224]
	mov	w1, #8196
	movk	w1, #5750, lsl #16
	mov	w2, #1
	mov	w3, #900
	mov	w4, #600
	bl	_SDL_CreateTexture
	cbz	x0, LBB15_76
; %bb.3:
	mov	x19, x0
	mov	w1, #1
	bl	_SDL_SetTextureBlendMode
	cmn	w0, #1                          ; =1
	b.ne	LBB15_5
; %bb.4:
Lloh5:
	adrp	x20, ___stderrp@GOTPAGE
Lloh6:
	ldr	x20, [x20, ___stderrp@GOTPAGEOFF]
	ldr	x1, [x20]
Lloh7:
	adrp	x0, l_.str.6@PAGE
Lloh8:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_fputs
	ldr	x1, [x20]
Lloh9:
	adrp	x0, l_.str.7@PAGE
Lloh10:
	add	x0, x0, l_.str.7@PAGEOFF
	bl	_fputs
	ldr	x1, [x20]
Lloh11:
	adrp	x0, l_.str.8@PAGE
Lloh12:
	add	x0, x0, l_.str.8@PAGEOFF
	bl	_fputs
LBB15_5:
	ldr	x0, [sp, #224]
	mov	w1, #8196
	movk	w1, #5750, lsl #16
	mov	w2, #1
	mov	w3, #240
	mov	w4, #160
	bl	_SDL_CreateTexture
	cbz	x0, LBB15_83
; %bb.6:
	mov	x20, x0
Lloh13:
	adrp	x0, l_.str.10@PAGE
Lloh14:
	add	x0, x0, l_.str.10@PAGEOFF
	bl	_puts
	mov	w0, #1
	mov	w1, #62848
	movk	w1, #32, lsl #16
	bl	_calloc
	mov	x21, x0
	cbz	x0, LBB15_84
; %bb.7:
	mov	x0, #0
	bl	_SDL_GetKeyboardState
	str	x0, [sp, #136]                  ; 8-byte Folded Spill
	bl	_SDL_GetPerformanceCounter
	str	x0, [sp, #32]                   ; 8-byte Folded Spill
	str	wzr, [sp, #168]                 ; 4-byte Folded Spill
	mov	w27, #0
	mov	w22, #0
	add	x9, sp, #232                    ; =232
	add	x11, x9, #64                    ; =64
	add	x8, sp, #744                    ; =744
	add	x10, x8, #8                     ; =8
	stp	x10, x11, [sp, #152]            ; 16-byte Folded Spill
	add	x11, x9, #128                   ; =128
	add	x10, x8, #16                    ; =16
	stp	x10, x11, [sp, #120]            ; 16-byte Folded Spill
	add	x11, x9, #192                   ; =192
	add	x10, x8, #24                    ; =24
	stp	x10, x11, [sp, #104]            ; 16-byte Folded Spill
	add	x11, x9, #256                   ; =256
	add	x10, x8, #32                    ; =32
	stp	x10, x11, [sp, #88]             ; 16-byte Folded Spill
	add	x11, x9, #320                   ; =320
	add	x10, x8, #40                    ; =40
	stp	x10, x11, [sp, #72]             ; 16-byte Folded Spill
	add	x11, x9, #384                   ; =384
	add	x10, x8, #48                    ; =48
	stp	x10, x11, [sp, #56]             ; 16-byte Folded Spill
	add	x9, x9, #448                    ; =448
	add	x8, x8, #56                     ; =56
	stp	x8, x9, [sp, #40]               ; 16-byte Folded Spill
	fmov	d8, #2.00000000
	fmov	d9, #-0.50000000
	movi.2d	v10, #0000000000000000
	mov	w28, #1
	movi.2d	v12, #0000000000000000
	fmov	d11, #16.00000000
Lloh15:
	adrp	x8, lCPI15_0@PAGE
Lloh16:
	ldr	q0, [x8, lCPI15_0@PAGEOFF]
	str	q0, [sp, #176]                  ; 16-byte Folded Spill
Lloh17:
	adrp	x26, _thread@PAGE
Lloh18:
	add	x26, x26, _thread@PAGEOFF
Lloh19:
	adrp	x8, lCPI15_1@PAGE
Lloh20:
	ldr	d13, [x8, lCPI15_1@PAGEOFF]
Lloh21:
	adrp	x8, lCPI15_2@PAGE
Lloh22:
	ldr	d14, [x8, lCPI15_2@PAGEOFF]
Lloh23:
	adrp	x8, lCPI15_3@PAGE
Lloh24:
	ldr	d15, [x8, lCPI15_3@PAGEOFF]
	str	x20, [sp, #144]                 ; 8-byte Folded Spill
	b	LBB15_9
LBB15_8:                                ;   in Loop: Header=BB15_9 Depth=1
	cbnz	w8, LBB15_86
LBB15_9:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB15_46 Depth 2
                                        ;     Child Loop BB15_15 Depth 2
                                        ;     Child Loop BB15_53 Depth 2
	tbz	w28, #0, LBB15_80
; %bb.10:                               ;   in Loop: Header=BB15_9 Depth=1
	sub	x0, x29, #216                   ; =216
	bl	_SDL_PollEvent
	mov	w28, #1
	cbnz	w0, LBB15_46
LBB15_11:                               ;   in Loop: Header=BB15_9 Depth=1
	mov.16b	v0, v8
	bl	_log10
	fadd	d1, d0, d0
	fsub	d1, d11, d1
	fcmp	d0, #0.0
	fcsel	d0, d11, d1, gt
	fmul	d0, d0, d0
	fcvtzs	w23, d0
	stp	d10, d8, [sp, #8]
	add	x0, sp, #808                    ; =808
	str	d9, [sp]
	str	x23, [sp, #24]
	mov	w1, #256
Lloh25:
	adrp	x2, l_.str.12@PAGE
Lloh26:
	add	x2, x2, l_.str.12@PAGEOFF
	bl	_snprintf
	ldr	x0, [sp, #216]
	add	x1, sp, #808                    ; =808
	bl	_SDL_SetWindowTitle
	cbz	w27, LBB15_51
; %bb.12:                               ;   in Loop: Header=BB15_9 Depth=1
	cmp	w27, #1                         ; =1
	b.ne	LBB15_66
; %bb.13:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	w8, [sp, #168]                  ; 4-byte Folded Reload
	tbz	w8, #0, LBB15_68
; %bb.14:                               ;   in Loop: Header=BB15_9 Depth=1
	mov	w24, #899
	mov	w25, #679
	bl	_SDL_GetPerformanceCounter
	str	x0, [sp, #168]                  ; 8-byte Folded Spill
LBB15_15:                               ;   Parent Loop BB15_9 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	add	x2, sp, #208                    ; =208
	add	x3, sp, #204                    ; =204
	mov	x0, x19
	mov	x1, #0
	bl	_SDL_LockTexture
	tbnz	w0, #31, LBB15_85
; %bb.16:                               ;   in Loop: Header=BB15_15 Depth=2
	sub	w8, w25, #679                   ; =679
	add	w20, w8, #4                     ; =4
	stp	w8, w20, [sp, #232]
	stp	d13, d14, [sp, #240]
	stp	d8, d9, [sp, #256]
	str	d10, [sp, #272]
	str	w23, [sp, #280]
	str	x21, [sp, #288]
	add	x0, sp, #744                    ; =744
	add	x3, sp, #232                    ; =232
	mov	x1, #0
	mov	x2, x26
	bl	_pthread_create
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_24
; %bb.17:                               ;   in Loop: Header=BB15_15 Depth=2
	sub	w8, w25, #454                   ; =454
	sub	w9, w25, #450                   ; =450
	str	w8, [sp, #296]
	str	w9, [sp, #300]
	stp	d13, d14, [sp, #304]
	stp	d8, d9, [sp, #320]
	add	x8, sp, #232                    ; =232
	str	d10, [x8, #104]
	str	w23, [sp, #344]
	str	x21, [x8, #120]
	ldp	x0, x3, [sp, #152]              ; 16-byte Folded Reload
	mov	x1, #0
	mov	x2, x26
	bl	_pthread_create
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_24
; %bb.18:                               ;   in Loop: Header=BB15_15 Depth=2
	sub	w8, w25, #229                   ; =229
	sub	w9, w25, #225                   ; =225
	str	w8, [sp, #360]
	str	w9, [sp, #364]
	add	x8, sp, #232                    ; =232
	stp	d13, d14, [x8, #136]
	stp	d8, d9, [x8, #152]
	str	d10, [x8, #168]
	str	w23, [sp, #408]
	str	x21, [x8, #184]
	ldp	x0, x3, [sp, #120]              ; 16-byte Folded Reload
	mov	x1, #0
	mov	x2, x26
	bl	_pthread_create
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_24
; %bb.19:                               ;   in Loop: Header=BB15_15 Depth=2
	sub	w8, w25, #4                     ; =4
	str	w8, [sp, #424]
	str	w25, [sp, #428]
	add	x8, sp, #232                    ; =232
	str	d13, [x8, #200]
	str	d14, [x8, #208]
	str	d8, [x8, #216]
	str	d9, [x8, #224]
	str	d10, [x8, #232]
	str	w23, [sp, #472]
	str	x21, [x8, #248]
	ldp	x0, x3, [sp, #104]              ; 16-byte Folded Reload
	mov	x1, #0
	mov	x2, x26
	bl	_pthread_create
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_24
; %bb.20:                               ;   in Loop: Header=BB15_15 Depth=2
	sub	w8, w24, #679                   ; =679
	str	w8, [sp, #488]
	sub	w8, w24, #675                   ; =675
	str	w8, [sp, #492]
	add	x8, sp, #232                    ; =232
	stp	d15, d14, [x8, #264]
	stp	d8, d9, [x8, #280]
	str	d10, [x8, #296]
	str	w23, [sp, #536]
	str	x21, [x8, #312]
	ldp	x0, x3, [sp, #88]               ; 16-byte Folded Reload
	mov	x1, #0
	mov	x2, x26
	bl	_pthread_create
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_24
; %bb.21:                               ;   in Loop: Header=BB15_15 Depth=2
	sub	w8, w24, #454                   ; =454
	str	w8, [sp, #552]
	sub	w8, w24, #450                   ; =450
	str	w8, [sp, #556]
	add	x8, sp, #232                    ; =232
	str	d15, [x8, #328]
	str	d14, [x8, #336]
	str	d8, [x8, #344]
	str	d9, [x8, #352]
	str	d10, [x8, #360]
	str	w23, [sp, #600]
	str	x21, [x8, #376]
	ldp	x0, x3, [sp, #72]               ; 16-byte Folded Reload
	mov	x1, #0
	mov	x2, x26
	bl	_pthread_create
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_24
; %bb.22:                               ;   in Loop: Header=BB15_15 Depth=2
	sub	w8, w24, #229                   ; =229
	str	w8, [sp, #616]
	sub	w8, w24, #225                   ; =225
	str	w8, [sp, #620]
	add	x8, sp, #232                    ; =232
	stp	d15, d14, [x8, #392]
	stp	d8, d9, [x8, #408]
	str	d10, [x8, #424]
	str	w23, [sp, #664]
	str	x21, [x8, #440]
	ldp	x0, x3, [sp, #56]               ; 16-byte Folded Reload
	mov	x1, #0
	mov	x2, x26
	bl	_pthread_create
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_24
; %bb.23:                               ;   in Loop: Header=BB15_15 Depth=2
	sub	w8, w24, #4                     ; =4
	str	w8, [sp, #680]
	str	w24, [sp, #684]
	add	x8, sp, #232                    ; =232
	str	d15, [x8, #456]
	str	d14, [x8, #464]
	str	d8, [x8, #472]
	str	d9, [x8, #480]
	str	d10, [x8, #488]
	str	w23, [sp, #728]
	str	x21, [x8, #504]
	ldp	x0, x3, [sp, #40]               ; 16-byte Folded Reload
	mov	x1, #0
	mov	x2, x26
	bl	_pthread_create
                                        ; kill: def $w0 killed $w0 def $x0
	cbz	w0, LBB15_27
LBB15_24:                               ;   in Loop: Header=BB15_15 Depth=2
Lloh27:
	adrp	x8, ___stderrp@GOTPAGE
Lloh28:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh29:
	ldr	x8, [x8]
	str	x0, [sp]
	mov	x0, x8
Lloh30:
	adrp	x1, l_.str.14@PAGE
Lloh31:
	add	x1, x1, l_.str.14@PAGEOFF
LBB15_25:                               ;   in Loop: Header=BB15_15 Depth=2
	bl	_fprintf
	mov	w9, #0
	mov	w22, #71
	mov	w8, #2
	tbz	w9, #0, LBB15_43
LBB15_26:                               ;   in Loop: Header=BB15_15 Depth=2
	sub	w24, w24, #5                    ; =5
	add	w25, w25, #5                    ; =5
	sub	w8, w20, #4                     ; =4
	cmp	w8, #219                        ; =219
	b.ls	LBB15_15
	b	LBB15_67
LBB15_27:                               ;   in Loop: Header=BB15_15 Depth=2
	add	x8, sp, #232                    ; =232
	ldr	x0, [x8, #512]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_35
; %bb.28:                               ;   in Loop: Header=BB15_15 Depth=2
	add	x8, sp, #232                    ; =232
	ldr	x0, [x8, #520]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_35
; %bb.29:                               ;   in Loop: Header=BB15_15 Depth=2
	add	x8, sp, #232                    ; =232
	ldr	x0, [x8, #528]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_35
; %bb.30:                               ;   in Loop: Header=BB15_15 Depth=2
	add	x8, sp, #232                    ; =232
	ldr	x0, [x8, #536]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_35
; %bb.31:                               ;   in Loop: Header=BB15_15 Depth=2
	add	x8, sp, #232                    ; =232
	ldr	x0, [x8, #544]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_35
; %bb.32:                               ;   in Loop: Header=BB15_15 Depth=2
	add	x8, sp, #232                    ; =232
	ldr	x0, [x8, #552]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_35
; %bb.33:                               ;   in Loop: Header=BB15_15 Depth=2
	add	x8, sp, #232                    ; =232
	ldr	x0, [x8, #560]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_35
; %bb.34:                               ;   in Loop: Header=BB15_15 Depth=2
	add	x8, sp, #232                    ; =232
	ldr	x0, [x8, #568]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbz	w0, LBB15_36
LBB15_35:                               ;   in Loop: Header=BB15_15 Depth=2
Lloh32:
	adrp	x8, ___stderrp@GOTPAGE
Lloh33:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh34:
	ldr	x8, [x8]
	str	x0, [sp]
	mov	x0, x8
Lloh35:
	adrp	x1, l_.str.15@PAGE
Lloh36:
	add	x1, x1, l_.str.15@PAGEOFF
	b	LBB15_25
LBB15_36:                               ;   in Loop: Header=BB15_15 Depth=2
	ldr	x0, [sp, #208]
	mov	x1, x21
	mov	w2, #62848
	movk	w2, #32, lsl #16
	bl	_memcpy
	mov	x0, x19
	bl	_SDL_UnlockTexture
	ldr	x0, [sp, #224]
	ldr	x1, [sp, #144]                  ; 8-byte Folded Reload
	mov	x2, #0
	mov	x3, #0
	bl	_SDL_RenderCopy
	tbnz	w0, #31, LBB15_39
; %bb.37:                               ;   in Loop: Header=BB15_15 Depth=2
	ldr	x0, [sp, #224]
	mov	x1, x19
	mov	x2, #0
	mov	x3, #0
	bl	_SDL_RenderCopy
	tbnz	w0, #31, LBB15_40
; %bb.38:                               ;   in Loop: Header=BB15_15 Depth=2
	ldr	x0, [sp, #224]
	bl	_SDL_RenderPresent
	mov	w8, #0
	mov	w9, #1
	b	LBB15_42
LBB15_39:                               ;   in Loop: Header=BB15_15 Depth=2
Lloh37:
	adrp	x8, ___stderrp@GOTPAGE
Lloh38:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh39:
	ldr	x22, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
	mov	x0, x22
Lloh40:
	adrp	x1, l_.str.16@PAGE
Lloh41:
	add	x1, x1, l_.str.16@PAGEOFF
	b	LBB15_41
LBB15_40:                               ;   in Loop: Header=BB15_15 Depth=2
Lloh42:
	adrp	x8, ___stderrp@GOTPAGE
Lloh43:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh44:
	ldr	x22, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
	mov	x0, x22
Lloh45:
	adrp	x1, l_.str.17@PAGE
Lloh46:
	add	x1, x1, l_.str.17@PAGEOFF
LBB15_41:                               ;   in Loop: Header=BB15_15 Depth=2
	bl	_fprintf
	mov	w9, #0
	mov	w22, #71
	mov	w8, #2
LBB15_42:                               ;   in Loop: Header=BB15_15 Depth=2
	fmov	d11, #16.00000000
	tbnz	w9, #0, LBB15_26
LBB15_43:                               ;   in Loop: Header=BB15_9 Depth=1
	str	wzr, [sp, #168]                 ; 4-byte Folded Spill
	ldr	x20, [sp, #144]                 ; 8-byte Folded Reload
	cbz	w8, LBB15_9
	b	LBB15_86
LBB15_44:                               ;   in Loop: Header=BB15_46 Depth=2
	cmp	w8, #256                        ; =256
	csel	w28, w28, wzr, ne
LBB15_45:                               ;   in Loop: Header=BB15_46 Depth=2
	sub	x0, x29, #216                   ; =216
	bl	_SDL_PollEvent
	cbz	w0, LBB15_11
LBB15_46:                               ;   Parent Loop BB15_9 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldur	w8, [x29, #-216]
	cmp	w8, #768                        ; =768
	b.ne	LBB15_44
; %bb.47:                               ;   in Loop: Header=BB15_46 Depth=2
	ldur	w8, [x29, #-200]
	cmp	w8, #43                         ; =43
	b.ne	LBB15_45
; %bb.48:                               ;   in Loop: Header=BB15_46 Depth=2
	cmp	w27, #1                         ; =1
	b.ne	LBB15_50
; %bb.49:                               ;   in Loop: Header=BB15_46 Depth=2
	mov	w27, #0
	b	LBB15_45
LBB15_50:                               ;   in Loop: Header=BB15_46 Depth=2
	mov	x0, x21
	mov	w1, #62848
	movk	w1, #32, lsl #16
	bl	_bzero
	mov	w8, #1
	str	w8, [sp, #168]                  ; 4-byte Folded Spill
	mov	w27, #1
	b	LBB15_45
LBB15_51:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x9, [sp, #136]                  ; 8-byte Folded Reload
	ldrb	w8, [x9, #26]
	fcvt	d0, s12
	fmul	d1, d8, d0
	fadd	d2, d1, d10
	cmp	w8, #0                          ; =0
	fcsel	d2, d10, d2, eq
	ldrb	w8, [x9, #4]
	fsub	d3, d9, d1
	cmp	w8, #0                          ; =0
	fcsel	d3, d9, d3, eq
	ldrb	w8, [x9, #22]
	fsub	d4, d2, d1
	cmp	w8, #0                          ; =0
	fcsel	d10, d2, d4, eq
	ldrb	w8, [x9, #7]
	fadd	d2, d3, d1
	cmp	w8, #0                          ; =0
	fcsel	d9, d3, d2, eq
	ldrb	w8, [x9, #21]
	fsub	d1, d8, d1
	cmp	w8, #0                          ; =0
	fcsel	d1, d8, d1, eq
	ldrb	w8, [x9, #9]
	fmadd	d0, d1, d0, d1
	cmp	w8, #0                          ; =0
	fcsel	d8, d1, d0, eq
	add	x2, sp, #208                    ; =208
	add	x3, sp, #204                    ; =204
	mov	x0, x20
	mov	x1, #0
	bl	_SDL_LockTexture
	tbnz	w0, #31, LBB15_88
; %bb.52:                               ;   in Loop: Header=BB15_9 Depth=1
	mov	x10, #0
	mov	w9, #0
	add	x0, sp, #744                    ; =744
LBB15_53:                               ;   Parent Loop BB15_9 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	add	x20, x10, #64                   ; =64
	cmp	x20, #576                       ; =576
	b.eq	LBB15_56
; %bb.54:                               ;   in Loop: Header=BB15_53 Depth=2
	add	w25, w9, #30                    ; =30
	ldr	x8, [sp, #208]
	add	x24, x0, #8                     ; =8
	add	x11, sp, #232                   ; =232
	add	x3, x11, x10
	add	w10, w9, #29                    ; =29
	stp	w9, w10, [x3]
	ldr	q0, [sp, #176]                  ; 16-byte Folded Reload
	stur	q0, [x3, #8]
	str	d8, [x3, #24]
	str	d9, [x3, #32]
	str	d10, [x3, #40]
	str	w23, [x3, #48]
	str	x8, [x3, #56]
	mov	x1, #0
	mov	x2, x26
	bl	_pthread_create
	mov	x8, x0
	mov	x0, x24
	mov	x10, x20
	mov	x9, x25
	cbz	w8, LBB15_53
; %bb.55:                               ;   in Loop: Header=BB15_9 Depth=1
Lloh47:
	adrp	x9, ___stderrp@GOTPAGE
Lloh48:
	ldr	x9, [x9, ___stderrp@GOTPAGEOFF]
Lloh49:
	ldr	x0, [x9]
	str	x8, [sp]
Lloh50:
	adrp	x1, l_.str.14@PAGE
Lloh51:
	add	x1, x1, l_.str.14@PAGEOFF
	b	LBB15_65
LBB15_56:                               ;   in Loop: Header=BB15_9 Depth=1
	add	x20, sp, #232                   ; =232
	ldr	x0, [x20, #512]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_64
; %bb.57:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [x20, #520]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_64
; %bb.58:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [x20, #528]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_64
; %bb.59:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [x20, #536]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_64
; %bb.60:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [x20, #544]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_64
; %bb.61:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [x20, #552]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_64
; %bb.62:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [x20, #560]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB15_64
; %bb.63:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [x20, #568]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbz	w0, LBB15_70
LBB15_64:                               ;   in Loop: Header=BB15_9 Depth=1
Lloh52:
	adrp	x8, ___stderrp@GOTPAGE
Lloh53:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh54:
	ldr	x8, [x8]
	str	x0, [sp]
	mov	x0, x8
Lloh55:
	adrp	x1, l_.str.15@PAGE
Lloh56:
	add	x1, x1, l_.str.15@PAGEOFF
LBB15_65:                               ;   in Loop: Header=BB15_9 Depth=1
	bl	_fprintf
	mov	w9, #0
	mov	w22, #71
	mov	w8, #2
	ldr	x20, [sp, #144]                 ; 8-byte Folded Reload
	cbz	w9, LBB15_8
LBB15_66:                               ;   in Loop: Header=BB15_9 Depth=1
	mov	w8, #0
	cbz	w8, LBB15_9
	b	LBB15_86
LBB15_67:                               ;   in Loop: Header=BB15_9 Depth=1
	bl	_SDL_GetPerformanceCounter
	ldr	x8, [sp, #168]                  ; 8-byte Folded Reload
	sub	x8, x0, x8
	mov.16b	v11, v12
	mov.16b	v12, v15
	ucvtf	s15, x8
	bl	_SDL_GetPerformanceFrequency
	ucvtf	s0, x0
	mov	w8, #1148846080
	fmov	s1, w8
	fmul	s1, s15, s1
	mov.16b	v15, v12
	mov.16b	v12, v11
	fmov	d11, #16.00000000
	fdiv	s0, s1, s0
	fcvt	d0, s0
	str	d0, [sp]
Lloh57:
	adrp	x0, l_.str.18@PAGE
Lloh58:
	add	x0, x0, l_.str.18@PAGEOFF
	bl	_printf
	ldr	x20, [sp, #144]                 ; 8-byte Folded Reload
LBB15_68:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [sp, #224]
	mov	x1, x19
	mov	x2, #0
	mov	x3, #0
	bl	_SDL_RenderCopy
	tbnz	w0, #31, LBB15_89
; %bb.69:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [sp, #224]
	bl	_SDL_RenderPresent
	str	wzr, [sp, #168]                 ; 4-byte Folded Spill
	mov	w8, #0
	cbz	w8, LBB15_9
	b	LBB15_86
LBB15_70:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x20, [sp, #144]                 ; 8-byte Folded Reload
	mov	x0, x20
	bl	_SDL_UnlockTexture
	ldr	x0, [sp, #224]
	mov	x1, x20
	mov	x2, #0
	mov	x3, #0
	bl	_SDL_RenderCopy
	tbnz	w0, #31, LBB15_72
; %bb.71:                               ;   in Loop: Header=BB15_9 Depth=1
	ldr	x0, [sp, #224]
	bl	_SDL_RenderPresent
	bl	_SDL_GetPerformanceCounter
	mov	x20, x0
	ldr	x8, [sp, #32]                   ; 8-byte Folded Reload
	sub	x8, x0, x8
	ucvtf	s12, x8
	bl	_SDL_GetPerformanceFrequency
	ucvtf	s0, x0
	fdiv	s12, s12, s0
	mov	w8, #1148846080
	fmov	s0, w8
	fmul	s0, s12, s0
	fcvt	d0, s0
	str	d0, [sp]
Lloh59:
	adrp	x0, l_.str.20@PAGE
Lloh60:
	add	x0, x0, l_.str.20@PAGEOFF
	bl	_printf
	mov	w8, #0
	mov	w9, #1
	str	x20, [sp, #32]                  ; 8-byte Folded Spill
	b	LBB15_73
LBB15_72:                               ;   in Loop: Header=BB15_9 Depth=1
Lloh61:
	adrp	x8, ___stderrp@GOTPAGE
Lloh62:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh63:
	ldr	x22, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
	mov	x0, x22
Lloh64:
	adrp	x1, l_.str.16@PAGE
Lloh65:
	add	x1, x1, l_.str.16@PAGEOFF
	bl	_fprintf
	mov	w9, #0
	mov	w22, #71
	mov	w8, #2
LBB15_73:                               ;   in Loop: Header=BB15_9 Depth=1
	fmov	d11, #16.00000000
	ldr	x20, [sp, #144]                 ; 8-byte Folded Reload
	cbnz	w9, LBB15_66
	b	LBB15_8
LBB15_74:
Lloh66:
	adrp	x8, ___stderrp@GOTPAGE
Lloh67:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh68:
	ldr	x19, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh69:
	adrp	x1, l_.str.3@PAGE
Lloh70:
	add	x1, x1, l_.str.3@PAGEOFF
	b	LBB15_77
LBB15_75:
Lloh71:
	adrp	x8, ___stderrp@GOTPAGE
Lloh72:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh73:
	ldr	x19, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh74:
	adrp	x1, l_.str.4@PAGE
Lloh75:
	add	x1, x1, l_.str.4@PAGEOFF
	b	LBB15_77
LBB15_76:
Lloh76:
	adrp	x8, ___stderrp@GOTPAGE
Lloh77:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh78:
	ldr	x19, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh79:
	adrp	x1, l_.str.5@PAGE
Lloh80:
	add	x1, x1, l_.str.5@PAGEOFF
LBB15_77:
	mov	x0, x19
	bl	_fprintf
	mov	x20, #0
	mov	x19, #0
LBB15_78:
	mov	x21, #0
LBB15_79:
	mov	w22, #71
LBB15_80:
Lloh81:
	adrp	x0, l_.str.21@PAGE
Lloh82:
	add	x0, x0, l_.str.21@PAGEOFF
	bl	_puts
	mov	x0, x21
	bl	_free
	mov	x0, x20
	bl	_SDL_DestroyTexture
	mov	x0, x19
	bl	_SDL_DestroyTexture
	ldr	x0, [sp, #224]
	bl	_SDL_DestroyRenderer
	ldr	x0, [sp, #216]
	bl	_SDL_DestroyWindow
	bl	_SDL_Quit
LBB15_81:
	ldur	x8, [x29, #-160]
Lloh83:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh84:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh85:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB15_91
; %bb.82:
	mov	x0, x22
	add	sp, sp, #1136                   ; =1136
	ldp	x29, x30, [sp, #144]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #128]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #112]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #96]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #80]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #64]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #48]               ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #32]             ; 16-byte Folded Reload
	ldp	d13, d12, [sp, #16]             ; 16-byte Folded Reload
	ldp	d15, d14, [sp], #160            ; 16-byte Folded Reload
	ret
LBB15_83:
Lloh86:
	adrp	x8, ___stderrp@GOTPAGE
Lloh87:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh88:
	ldr	x20, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh89:
	adrp	x1, l_.str.9@PAGE
Lloh90:
	add	x1, x1, l_.str.9@PAGEOFF
	mov	x0, x20
	bl	_fprintf
	mov	x20, #0
	b	LBB15_78
LBB15_84:
Lloh91:
	adrp	x8, ___stderrp@GOTPAGE
Lloh92:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh93:
	ldr	x1, [x8]
Lloh94:
	adrp	x0, l_.str.11@PAGE
Lloh95:
	add	x0, x0, l_.str.11@PAGEOFF
	bl	_fputs
	b	LBB15_79
LBB15_85:
Lloh96:
	adrp	x8, ___stderrp@GOTPAGE
Lloh97:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh98:
	ldr	x22, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh99:
	adrp	x1, l_.str.13@PAGE
Lloh100:
	add	x1, x1, l_.str.13@PAGEOFF
	mov	x0, x22
	bl	_fprintf
	ldr	x20, [sp, #144]                 ; 8-byte Folded Reload
	b	LBB15_79
LBB15_86:
	cmp	w8, #2                          ; =2
	b.eq	LBB15_80
; %bb.87:
	mov	w22, #0
	b	LBB15_81
LBB15_88:
Lloh101:
	adrp	x8, ___stderrp@GOTPAGE
Lloh102:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh103:
	ldr	x22, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh104:
	adrp	x1, l_.str.19@PAGE
Lloh105:
	add	x1, x1, l_.str.19@PAGEOFF
	b	LBB15_90
LBB15_89:
Lloh106:
	adrp	x8, ___stderrp@GOTPAGE
Lloh107:
	ldr	x8, [x8, ___stderrp@GOTPAGEOFF]
Lloh108:
	ldr	x22, [x8]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh109:
	adrp	x1, l_.str.17@PAGE
Lloh110:
	add	x1, x1, l_.str.17@PAGEOFF
LBB15_90:
	mov	x0, x22
	bl	_fprintf
	b	LBB15_79
LBB15_91:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh2, Lloh3, Lloh4
	.loh AdrpAdd	Lloh11, Lloh12
	.loh AdrpAdd	Lloh9, Lloh10
	.loh AdrpAdd	Lloh7, Lloh8
	.loh AdrpLdrGot	Lloh5, Lloh6
	.loh AdrpAdd	Lloh13, Lloh14
	.loh AdrpLdr	Lloh23, Lloh24
	.loh AdrpAdrp	Lloh21, Lloh23
	.loh AdrpLdr	Lloh21, Lloh22
	.loh AdrpAdrp	Lloh19, Lloh21
	.loh AdrpLdr	Lloh19, Lloh20
	.loh AdrpAdd	Lloh17, Lloh18
	.loh AdrpAdrp	Lloh15, Lloh19
	.loh AdrpLdr	Lloh15, Lloh16
	.loh AdrpAdd	Lloh25, Lloh26
	.loh AdrpAdd	Lloh30, Lloh31
	.loh AdrpLdrGotLdr	Lloh27, Lloh28, Lloh29
	.loh AdrpAdd	Lloh35, Lloh36
	.loh AdrpLdrGotLdr	Lloh32, Lloh33, Lloh34
	.loh AdrpAdd	Lloh40, Lloh41
	.loh AdrpLdrGotLdr	Lloh37, Lloh38, Lloh39
	.loh AdrpAdd	Lloh45, Lloh46
	.loh AdrpLdrGotLdr	Lloh42, Lloh43, Lloh44
	.loh AdrpAdd	Lloh50, Lloh51
	.loh AdrpLdrGotLdr	Lloh47, Lloh48, Lloh49
	.loh AdrpAdd	Lloh55, Lloh56
	.loh AdrpLdrGotLdr	Lloh52, Lloh53, Lloh54
	.loh AdrpAdd	Lloh57, Lloh58
	.loh AdrpAdd	Lloh59, Lloh60
	.loh AdrpAdd	Lloh64, Lloh65
	.loh AdrpLdrGotLdr	Lloh61, Lloh62, Lloh63
	.loh AdrpAdd	Lloh69, Lloh70
	.loh AdrpLdrGotLdr	Lloh66, Lloh67, Lloh68
	.loh AdrpAdd	Lloh74, Lloh75
	.loh AdrpLdrGotLdr	Lloh71, Lloh72, Lloh73
	.loh AdrpAdd	Lloh79, Lloh80
	.loh AdrpLdrGotLdr	Lloh76, Lloh77, Lloh78
	.loh AdrpAdd	Lloh81, Lloh82
	.loh AdrpLdrGotLdr	Lloh83, Lloh84, Lloh85
	.loh AdrpAdd	Lloh89, Lloh90
	.loh AdrpLdrGotLdr	Lloh86, Lloh87, Lloh88
	.loh AdrpAdd	Lloh94, Lloh95
	.loh AdrpLdrGotLdr	Lloh91, Lloh92, Lloh93
	.loh AdrpAdd	Lloh99, Lloh100
	.loh AdrpLdrGotLdr	Lloh96, Lloh97, Lloh98
	.loh AdrpAdd	Lloh104, Lloh105
	.loh AdrpLdrGotLdr	Lloh101, Lloh102, Lloh103
	.loh AdrpAdd	Lloh109, Lloh110
	.loh AdrpLdrGotLdr	Lloh106, Lloh107, Lloh108
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function fp_sadd256.cold.1
_fp_sadd256.cold.1:                     ; @fp_sadd256.cold.1
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh111:
	adrp	x0, l___func__.fp_sadd256@PAGE
Lloh112:
	add	x0, x0, l___func__.fp_sadd256@PAGEOFF
Lloh113:
	adrp	x1, l_.str@PAGE
Lloh114:
	add	x1, x1, l_.str@PAGEOFF
Lloh115:
	adrp	x3, l_.str.1@PAGE
Lloh116:
	add	x3, x3, l_.str.1@PAGEOFF
	mov	w2, #249
	bl	___assert_rtn
	.loh AdrpAdd	Lloh115, Lloh116
	.loh AdrpAdd	Lloh113, Lloh114
	.loh AdrpAdd	Lloh111, Lloh112
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

	.p2align	3                               ; @fp_ucmp256.zero
_fp_ucmp256.zero:
	.space	32

	.section	__TEXT,__cstring,cstring_literals
l___func__.fp_sadd256:                  ; @__func__.fp_sadd256
	.asciz	"fp_sadd256"

l_.str:                                 ; @.str
	.asciz	"main.c"

l_.str.1:                               ; @.str.1
	.asciz	"(a.sign == SIGN_POS && b.sign == SIGN_NEG) || (a.sign == SIGN_NEG && b.sign == SIGN_POS)"

l_.str.3:                               ; @.str.3
	.asciz	"Unable to init SDL: %s\n"

l_.str.4:                               ; @.str.4
	.asciz	"Unable to create window and renderer: %s\n"

l_.str.5:                               ; @.str.5
	.asciz	"Unable to create full texture: %s\n"

l_.str.6:                               ; @.str.6
	.asciz	"Blend blendmode not supported on this platform."

l_.str.7:                               ; @.str.7
	.asciz	"Preview may not be shown during the render."

l_.str.8:                               ; @.str.8
	.asciz	"You may wish to disable SHOW_PREVIEW_WHEN_RENDERING."

l_.str.9:                               ; @.str.9
	.asciz	"Unable to create preview texture: %s\n"

l_.str.10:                              ; @.str.10
	.asciz	"Started."

l_.str.11:                              ; @.str.11
	.asciz	"Unable to allocate memory for stored_pixels."

l_.str.12:                              ; @.str.12
	.asciz	"X: %.17g, Y: %.17g, Size: %.17g, Iterations: %d"

l_.str.13:                              ; @.str.13
	.asciz	"Unable to lock full texture: %s\n"

l_.str.14:                              ; @.str.14
	.asciz	"Unable to create thread: Error code %d\n"

l_.str.15:                              ; @.str.15
	.asciz	"Unable to join thread: Error code %d\n"

l_.str.16:                              ; @.str.16
	.asciz	"Unable to copy preview texture: %s\n"

l_.str.17:                              ; @.str.17
	.asciz	"Unable to copy full texture: %s\n"

l_.str.18:                              ; @.str.18
	.asciz	"Full render completed. Time taken: %fms.\n"

l_.str.19:                              ; @.str.19
	.asciz	"Unable to lock preview texture: %s\n"

l_.str.20:                              ; @.str.20
	.asciz	"Preview render completed. Time taken: %fms.\n"

l_.str.21:                              ; @.str.21
	.asciz	"Quitting..."

.subsections_via_symbols
