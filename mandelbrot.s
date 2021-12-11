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
	adc	x17, x9, x13
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
	sbc	x17, x9, x13
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
	adc	x7, x9, x17
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
	sbc	x16, x8, x12
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
	adc	x0, x9, x14
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
	sbc	x4, x11, x15
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
	sbc	x1, x15, x11
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
	.globl	_fp_sinv256                     ; -- Begin function fp_sinv256
	.p2align	2
_fp_sinv256:                            ; @fp_sinv256
	.cfi_startproc
; %bb.0:
	ldr	w9, [x0]
	cmp	w9, #2                          ; =2
	b.eq	LBB7_3
; %bb.1:
	cbnz	w9, LBB7_5
; %bb.2:
	mov	w9, #2
	b	LBB7_4
LBB7_3:
	mov	w9, #0
LBB7_4:
	str	w9, [x0]
LBB7_5:
	ldp	q0, q1, [x0]
	ldr	x9, [x0, #32]
	str	x9, [x8, #32]
	stp	q0, q1, [x8]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fp_ssub256                     ; -- Begin function fp_ssub256
	.p2align	2
_fp_ssub256:                            ; @fp_ssub256
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #112                    ; =112
	stp	x29, x30, [sp, #96]             ; 16-byte Folded Spill
	add	x29, sp, #96                    ; =96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
Lloh0:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh1:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh2:
	ldr	x9, [x9]
	stur	x9, [x29, #-8]
	ldr	w9, [x1]
	ldur	q0, [x1, #4]
	ldur	q1, [x1, #20]
	ldr	w10, [x1, #36]
	str	w10, [sp, #80]
	stp	q0, q1, [sp, #48]
	cbz	w9, LBB8_3
; %bb.1:
	cmp	w9, #2                          ; =2
	b.ne	LBB8_4
; %bb.2:
	mov	w9, #0
	b	LBB8_4
LBB8_3:
	mov	w9, #2
LBB8_4:
	str	w9, [sp, #8]
	ldp	q0, q1, [sp, #48]
	stur	q0, [sp, #12]
	stur	q1, [sp, #28]
	ldr	w9, [sp, #80]
	str	w9, [sp, #44]
	ldp	q0, q1, [x0]
	ldr	x9, [x0, #32]
	str	x9, [sp, #80]
	stp	q0, q1, [sp, #48]
	add	x0, sp, #48                     ; =48
	add	x1, sp, #8                      ; =8
	bl	_fp_sadd256
	ldur	x8, [x29, #-8]
Lloh3:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh4:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh5:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB8_6
; %bb.5:
	ldp	x29, x30, [sp, #96]             ; 16-byte Folded Reload
	add	sp, sp, #112                    ; =112
	ret
LBB8_6:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh0, Lloh1, Lloh2
	.loh AdrpLdrGotLdr	Lloh3, Lloh4, Lloh5
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
	b.eq	LBB9_2
; %bb.1:
	ldr	x10, [sp, #40]                  ; 8-byte Folded Reload
	ldr	w10, [x10]
	cmp	w10, #1                         ; =1
	b.ne	LBB9_3
LBB9_2:
	movi.2d	v0, #0000000000000000
	str	xzr, [x8, #32]
	stp	q0, q0, [x8]
	mov	w9, #1
	str	w9, [x8]
	b	LBB9_6
LBB9_3:
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
LBB9_4:                                 ; =>This Inner Loop Header: Depth=1
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
	adc	x26, x13, x7
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
	adc	x7, x26, x13
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
	adc	x26, x7, x8
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
	adc	x13, x26, x8
	; InlineAsm End
	mov	x1, x21
	mov	x17, x20
	subs	x0, x0, #8                      ; =8
	b.ne	LBB9_4
; %bb.5:
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	ldr	w9, [sp, #12]                   ; 4-byte Folded Reload
	str	w9, [x8]
	stp	x16, x15, [x8, #8]
	stp	x1, x17, [x8, #24]
LBB9_6:
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
	.globl	_fp_ssqr256                     ; -- Begin function fp_ssqr256
	.p2align	2
_fp_ssqr256:                            ; @fp_ssqr256
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #112                    ; =112
	stp	x29, x30, [sp, #96]             ; 16-byte Folded Spill
	add	x29, sp, #96                    ; =96
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	ldp	q0, q1, [x0]
	ldr	x9, [x0, #32]
	str	x9, [sp, #80]
	stp	q0, q1, [sp, #48]
	ldp	q0, q1, [x0]
	ldr	x9, [x0, #32]
	str	x9, [sp, #32]
	stp	q0, q1, [sp]
	add	x0, sp, #48                     ; =48
	mov	x1, sp
	bl	_fp_smul256
	ldp	x29, x30, [sp, #96]             ; 16-byte Folded Reload
	add	sp, sp, #112                    ; =112
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fp_asr256                      ; -- Begin function fp_asr256
	.p2align	2
_fp_asr256:                             ; @fp_asr256
	.cfi_startproc
; %bb.0:
	ldp	x10, x9, [x0, #24]
	extr	x9, x10, x9, #1
	str	x9, [x0, #32]
	ldur	q0, [x0, #8]
	dup.2d	v1, v0[1]
	mov.d	v1[1], x10
	ushr.2d	v1, v1, #1
	shl.2d	v2, v0, #63
	orr.16b	v1, v2, v1
	str	q1, [x0, #16]
	fmov	x10, d0
	lsr	x10, x10, #1
	str	x10, [x0, #8]
	ldp	q0, q1, [x0]
	str	x9, [x8, #32]
	stp	q0, q1, [x8]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_int_to_fp256                   ; -- Begin function int_to_fp256
	.p2align	2
_int_to_fp256:                          ; @int_to_fp256
	.cfi_startproc
; %bb.0:
	cbz	w0, LBB12_2
; %bb.1:
	stp	xzr, xzr, [x8, #24]
	mov	w9, #2
	bic	w9, w9, w0, lsr #30
	cmp	w0, #0                          ; =0
	cneg	w10, w0, mi
	stp	w9, wzr, [x8]
	stp	x10, xzr, [x8, #8]
	ret
LBB12_2:
	str	xzr, [x8, #32]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x8]
	mov	w9, #1
	str	w9, [x8]
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_add                    ; -- Begin function complex_add
	.p2align	2
_complex_add:                           ; @complex_add
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #144                    ; =144
	stp	x22, x21, [sp, #96]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #112]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #128]            ; 16-byte Folded Spill
	add	x29, sp, #128                   ; =128
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	mov	x19, x1
	mov	x20, x0
	mov	x21, x8
	ldp	q0, q1, [x0]
	ldr	x8, [x0, #32]
	str	x8, [sp, #80]
	stp	q0, q1, [sp, #48]
	ldp	q0, q1, [x1]
	ldr	x8, [x1, #32]
	str	x8, [sp, #32]
	stp	q0, q1, [sp]
	add	x0, sp, #48                     ; =48
	mov	x1, sp
	mov	x8, x21
	bl	_fp_sadd256
	add	x8, x21, #40                    ; =40
	ldur	q0, [x20, #40]
	ldur	q1, [x20, #56]
	ldr	x9, [x20, #72]
	str	x9, [sp, #80]
	stp	q0, q1, [sp, #48]
	ldur	q0, [x19, #40]
	ldur	q1, [x19, #56]
	ldr	x9, [x19, #72]
	str	x9, [sp, #32]
	stp	q0, q1, [sp]
	add	x0, sp, #48                     ; =48
	mov	x1, sp
	bl	_fp_sadd256
	ldp	x29, x30, [sp, #128]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #112]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #96]             ; 16-byte Folded Reload
	add	sp, sp, #144                    ; =144
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_mul                    ; -- Begin function complex_mul
	.p2align	2
_complex_mul:                           ; @complex_mul
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #336                    ; =336
	stp	x28, x27, [sp, #256]            ; 16-byte Folded Spill
	stp	x24, x23, [sp, #272]            ; 16-byte Folded Spill
	stp	x22, x21, [sp, #288]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #304]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #320]            ; 16-byte Folded Spill
	add	x29, sp, #320                   ; =320
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	.cfi_offset w27, -72
	.cfi_offset w28, -80
	mov	x19, x1
	mov	x20, x0
	mov	x21, x8
	add	x23, sp, #120                   ; =120
Lloh6:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh7:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh8:
	ldr	x8, [x8]
	stur	x8, [x29, #-72]
	ldp	q0, q1, [x0]
	ldr	x8, [x0, #32]
	str	x8, [sp, #192]
	stp	q0, q1, [sp, #160]
	ldp	q0, q1, [x1]
	ldr	x8, [x1, #32]
	stur	x8, [x29, #-80]
	stp	q0, q1, [x29, #-112]
	add	x8, sp, #120                    ; =120
	add	x0, sp, #160                    ; =160
	sub	x1, x29, #112                   ; =112
	bl	_fp_smul256
	add	x22, x20, #40                   ; =40
	add	x24, x19, #40                   ; =40
	ldur	q0, [x20, #40]
	ldur	q1, [x20, #56]
	ldr	x8, [x20, #72]
	str	x8, [sp, #192]
	stp	q0, q1, [sp, #160]
	ldur	q0, [x19, #40]
	ldur	q1, [x19, #56]
	ldr	x8, [x19, #72]
	stur	x8, [x29, #-80]
	stp	q0, q1, [x29, #-112]
	add	x8, sp, #80                     ; =80
	add	x0, sp, #160                    ; =160
	sub	x1, x29, #112                   ; =112
	bl	_fp_smul256
	ldr	w8, [sp, #80]
	ldur	q0, [sp, #84]
	ldur	q1, [sp, #100]
	stp	q0, q1, [x29, #-112]
	ldr	w9, [sp, #116]
	stur	w9, [x29, #-80]
	cbz	w8, LBB14_3
; %bb.1:
	cmp	w8, #2                          ; =2
	b.ne	LBB14_4
; %bb.2:
	mov	w8, #0
	b	LBB14_4
LBB14_3:
	mov	w8, #2
LBB14_4:
	ldp	q0, q1, [x29, #-112]
	ldur	w9, [x29, #-80]
	str	w8, [sp, #160]
	stur	q0, [x23, #44]
	stur	q1, [x23, #60]
	str	w9, [sp, #196]
	ldur	q0, [sp, #120]
	ldr	q1, [x23, #16]
	stp	q0, q1, [x29, #-112]
	ldr	x8, [sp, #152]
	stur	x8, [x29, #-80]
	sub	x0, x29, #112                   ; =112
	add	x1, sp, #160                    ; =160
	mov	x8, x21
	bl	_fp_sadd256
	add	x21, x21, #40                   ; =40
	ldp	q0, q1, [x20]
	ldr	x8, [x20, #32]
	str	x8, [sp, #192]
	stp	q0, q1, [sp, #160]
	ldp	q0, q1, [x24]
	ldr	x8, [x24, #32]
	stur	x8, [x29, #-80]
	stp	q0, q1, [x29, #-112]
	add	x8, sp, #40                     ; =40
	add	x0, sp, #160                    ; =160
	sub	x1, x29, #112                   ; =112
	bl	_fp_smul256
	ldp	q0, q1, [x19]
	ldr	x8, [x19, #32]
	str	x8, [sp, #192]
	stp	q0, q1, [sp, #160]
	ldp	q0, q1, [x22]
	ldr	x8, [x22, #32]
	stur	x8, [x29, #-80]
	stp	q0, q1, [x29, #-112]
	mov	x8, sp
	add	x0, sp, #160                    ; =160
	sub	x1, x29, #112                   ; =112
	bl	_fp_smul256
	add	x0, sp, #40                     ; =40
	mov	x1, sp
	mov	x8, x21
	bl	_fp_sadd256
	ldur	x8, [x29, #-72]
Lloh9:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh10:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh11:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB14_6
; %bb.5:
	ldp	x29, x30, [sp, #320]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #304]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #288]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #272]            ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #256]            ; 16-byte Folded Reload
	add	sp, sp, #336                    ; =336
	ret
LBB14_6:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh6, Lloh7, Lloh8
	.loh AdrpLdrGotLdr	Lloh9, Lloh10, Lloh11
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_sqr                    ; -- Begin function complex_sqr
	.p2align	2
_complex_sqr:                           ; @complex_sqr
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #176                    ; =176
	stp	x29, x30, [sp, #160]            ; 16-byte Folded Spill
	add	x29, sp, #160                   ; =160
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	ldr	q4, [x0]
	ldp	q0, q1, [x0, #16]
	ldp	q2, q3, [x0, #48]
	stp	q2, q3, [sp, #128]
	str	q1, [sp, #112]
	stp	q4, q0, [sp, #80]
	ldr	q4, [x0]
	ldp	q0, q1, [x0, #16]
	ldp	q2, q3, [x0, #48]
	stp	q2, q3, [sp, #48]
	str	q1, [sp, #32]
	stp	q4, q0, [sp]
	add	x0, sp, #80                     ; =80
	mov	x1, sp
	bl	_complex_mul
	ldp	x29, x30, [sp, #160]            ; 16-byte Folded Reload
	add	sp, sp, #176                    ; =176
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_complex_sqrmag_whole           ; -- Begin function complex_sqrmag_whole
	.p2align	2
_complex_sqrmag_whole:                  ; @complex_sqrmag_whole
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #272                    ; =272
	stp	x28, x27, [sp, #224]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #240]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #256]            ; 16-byte Folded Spill
	add	x29, sp, #256                   ; =256
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w27, -40
	.cfi_offset w28, -48
	mov	x19, x0
	add	x20, sp, #128                   ; =128
	ldp	q0, q1, [x0]
	ldr	x8, [x0, #32]
	str	x8, [sp, #80]
	stp	q0, q1, [sp, #48]
	ldp	q2, q3, [x0]
	ldr	x9, [x0, #32]
	stur	x9, [x29, #-48]
	stp	q2, q3, [x20, #48]
	str	q0, [sp, #128]
	str	q1, [x20, #16]
	str	x8, [sp, #160]
	add	x8, sp, #88                     ; =88
	sub	x0, x29, #80                    ; =80
	add	x1, sp, #128                    ; =128
	bl	_fp_smul256
	ldur	q0, [x19, #40]
	ldur	q1, [x19, #56]
	ldr	x8, [x19, #72]
	str	x8, [sp, #80]
	stp	q0, q1, [sp, #48]
	ldur	q2, [x19, #40]
	ldur	q3, [x19, #56]
	ldr	x9, [x19, #72]
	stur	x9, [x29, #-48]
	stp	q2, q3, [x20, #48]
	str	q0, [sp, #128]
	str	q1, [x20, #16]
	str	x8, [sp, #160]
	add	x8, sp, #8                      ; =8
	sub	x0, x29, #80                    ; =80
	add	x1, sp, #128                    ; =128
	bl	_fp_smul256
	sub	x8, x29, #80                    ; =80
	add	x0, sp, #88                     ; =88
	add	x1, sp, #8                      ; =8
	bl	_fp_sadd256
	ldur	x0, [x29, #-72]
	ldp	x29, x30, [sp, #256]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #240]            ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #224]            ; 16-byte Folded Reload
	add	sp, sp, #272                    ; =272
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_calculateMathPos               ; -- Begin function calculateMathPos
	.p2align	2
_calculateMathPos:                      ; @calculateMathPos
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #368                    ; =368
	stp	x24, x23, [sp, #304]            ; 16-byte Folded Spill
	stp	x22, x21, [sp, #320]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #336]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #352]            ; 16-byte Folded Spill
	add	x29, sp, #352                   ; =352
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset w21, -40
	.cfi_offset w22, -48
	.cfi_offset w23, -56
	.cfi_offset w24, -64
	mov	x20, x2
	mov	x21, x1
	mov	x22, x0
	mov	x19, x8
	ldp	w11, w8, [x2]
	ldp	x10, x9, [x2, #24]
	extr	x9, x10, x9, #1
	ldp	x13, x12, [x2, #8]
	extr	x10, x12, x10, #1
	extr	x12, x13, x12, #1
	lsr	x13, x13, #1
	ldp	q0, q1, [x3]
	ldr	x14, [x3, #32]
	str	x14, [sp, #160]
	stp	q0, q1, [sp, #128]
	cbz	w11, LBB17_3
; %bb.1:
	cmp	w11, #2                         ; =2
	b.ne	LBB17_4
; %bb.2:
	mov	w11, #0
	b	LBB17_4
LBB17_3:
	mov	w11, #2
LBB17_4:
	add	x23, sp, #168                   ; =168
	stp	w11, w8, [x29, #-96]
	stp	x13, x12, [x29, #-88]
	stp	x10, x9, [x29, #-72]
	ldp	q0, q1, [sp, #128]
	stp	q0, q1, [x29, #-144]
	ldr	x8, [sp, #160]
	stur	x8, [x29, #-112]
	add	x8, sp, #168                    ; =168
	sub	x0, x29, #144                   ; =144
	sub	x1, x29, #96                    ; =96
	bl	_fp_sadd256
	cbz	w22, LBB17_6
; %bb.5:
	stp	xzr, xzr, [sp, #24]
	mov	w8, #2
	bic	w8, w8, w22, lsr #30
	cmp	w22, #0                         ; =0
	cneg	w9, w22, mi
	str	wzr, [sp, #4]
	stp	x9, xzr, [sp, #8]
	b	LBB17_7
LBB17_6:
	str	xzr, [sp, #32]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [sp]
	mov	w8, #1
LBB17_7:
	str	w8, [sp]
	ldp	q0, q1, [x21]
	ldr	x8, [x21, #32]
	stur	x8, [x29, #-64]
	stp	q0, q1, [x29, #-96]
	add	x8, sp, #48                     ; =48
	mov	x0, sp
	sub	x1, x29, #96                    ; =96
	bl	_fp_smul256
	ldp	q0, q1, [x20]
	ldr	x8, [x20, #32]
	stur	x8, [x29, #-64]
	stp	q0, q1, [x29, #-96]
	add	x8, sp, #88                     ; =88
	add	x0, sp, #48                     ; =48
	sub	x1, x29, #96                    ; =96
	bl	_fp_smul256
	ldp	q0, q1, [x23]
	stp	q0, q1, [x29, #-96]
	ldr	x8, [sp, #200]
	stur	x8, [x29, #-64]
	add	x0, sp, #88                     ; =88
	sub	x1, x29, #96                    ; =96
	mov	x8, x19
	bl	_fp_sadd256
	ldp	x29, x30, [sp, #352]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #336]            ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #320]            ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #304]            ; 16-byte Folded Reload
	add	sp, sp, #368                    ; =368
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_process_mandelbrot             ; -- Begin function process_mandelbrot
	.p2align	2
_process_mandelbrot:                    ; @process_mandelbrot
	.cfi_startproc
; %bb.0:
	stp	x28, x27, [sp, #-96]!           ; 16-byte Folded Spill
	stp	x26, x25, [sp, #16]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #32]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #48]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #64]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80                    ; =80
	sub	sp, sp, #688                    ; =688
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
	add	x8, sp, #192                    ; =192
Lloh12:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh13:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh14:
	ldr	x9, [x9]
	stur	x9, [x29, #-104]
	ldp	q0, q1, [x0]
	ldr	x9, [x0, #32]
	str	x9, [sp, #224]
	stp	q0, q1, [sp, #192]
	ldp	q0, q1, [x1]
	ldr	x9, [x1, #32]
	str	x9, [sp, #264]
	stur	q1, [x8, #56]
	stur	q0, [x8, #40]
	movi.2d	v0, #0000000000000000
	stp	q0, q0, [x29, #-192]
	stur	wzr, [x29, #-160]
	stp	q0, q0, [x29, #-240]
	stur	wzr, [x29, #-208]
	str	w2, [sp, #28]                   ; 4-byte Folded Spill
	cmp	w2, #1                          ; =1
	b.lt	LBB18_4
; %bb.1:
	mov	w21, #0
	add	x8, sp, #352                    ; =352
	orr	x22, x8, #0x4
	add	x10, x8, #44                    ; =44
	add	x9, sp, #272                    ; =272
	orr	x25, x9, #0x4
	add	x9, x9, #44                     ; =44
	stp	x9, x10, [sp, #8]               ; 16-byte Folded Spill
	add	x9, sp, #112                    ; =112
	add	x10, x9, #40                    ; =40
	str	x10, [sp]                       ; 8-byte Folded Spill
	add	x10, sp, #32                    ; =32
	add	x27, x10, #40                   ; =40
	add	x28, x8, #40                    ; =40
	orr	x20, x9, #0x4
	add	x19, x9, #44                    ; =44
	mov	w26, #1
	mov	w23, #1
	mov	w24, #1
LBB18_2:                                ; =>This Inner Loop Header: Depth=1
	ldp	q0, q2, [x29, #-240]
	ldp	q1, q3, [x29, #-240]
	stp	q0, q2, [sp, #480]
	ldp	q0, q2, [x29, #-192]
	stp	q0, q2, [x29, #-144]
	ldur	w8, [x29, #-208]
	ldur	w9, [x29, #-208]
	str	w8, [sp, #512]
	ldur	w8, [x29, #-160]
	stur	w8, [x29, #-112]
	str	w24, [sp, #352]
	str	w8, [x22, #32]
	stp	q0, q2, [x22]
	str	w23, [sp, #392]
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	str	w9, [x8, #32]
	stp	q1, q3, [x8]
	str	w24, [sp, #272]
	ldp	q0, q1, [x29, #-144]
	ldur	w8, [x29, #-112]
	str	w8, [x25, #32]
	stp	q0, q1, [x25]
	str	w23, [sp, #312]
	ldp	q0, q1, [sp, #480]
	ldr	w8, [sp, #512]
	ldr	x9, [sp, #8]                    ; 8-byte Folded Reload
	str	w8, [x9, #32]
	stp	q0, q1, [x9]
	add	x8, sp, #32                     ; =32
	add	x0, sp, #352                    ; =352
	add	x1, sp, #272                    ; =272
	bl	_complex_mul
	ldp	q0, q1, [sp, #224]
	ldr	q2, [sp, #256]
	stp	q0, q1, [sp, #384]
	str	q2, [sp, #416]
	ldp	q0, q2, [sp, #192]
	ldp	q1, q3, [sp, #192]
	stp	q0, q2, [sp, #352]
	ldp	q0, q2, [sp, #32]
	stp	q0, q2, [sp, #272]
	ldr	x8, [sp, #64]
	str	x8, [sp, #304]
	stp	q1, q3, [x29, #-144]
	ldr	x8, [sp, #224]
	stur	x8, [x29, #-112]
	add	x8, sp, #112                    ; =112
	add	x0, sp, #272                    ; =272
	sub	x1, x29, #144                   ; =144
	bl	_fp_sadd256
	ldp	q0, q1, [x27]
	ldr	x8, [x27, #32]
	str	x8, [sp, #304]
	stp	q0, q1, [sp, #272]
	ldp	q0, q1, [x28]
	ldr	x8, [x28, #32]
	stur	x8, [x29, #-112]
	stp	q0, q1, [x29, #-144]
	add	x0, sp, #272                    ; =272
	sub	x1, x29, #144                   ; =144
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	bl	_fp_sadd256
	ldr	w8, [x20, #32]
	ldp	q0, q1, [x20]
	stur	w8, [x29, #-160]
	stp	q0, q1, [x29, #-192]
	ldr	w24, [sp, #112]
	ldr	w23, [sp, #152]
	ldr	w8, [x19, #32]
	ldp	q1, q0, [x19]
	stp	q1, q0, [x29, #-240]
	stur	w8, [x29, #-208]
	ldp	q0, q1, [x29, #-240]
	stp	q0, q1, [sp, #432]
	ldp	q0, q2, [x29, #-192]
	ldp	q1, q3, [x29, #-192]
	stp	q0, q2, [sp, #480]
	mov	w8, w8
	str	w8, [sp, #464]
	ldur	w8, [x29, #-160]
	ldur	w9, [x29, #-160]
	str	w8, [sp, #512]
	str	w24, [sp, #352]
	str	w8, [x22, #32]
	stp	q0, q2, [x22]
	str	w24, [sp, #272]
	str	w9, [x25, #32]
	stp	q1, q3, [x25]
	add	x8, sp, #112                    ; =112
	add	x0, sp, #352                    ; =352
	add	x1, sp, #272                    ; =272
	bl	_fp_smul256
	str	w23, [sp, #352]
	ldp	q0, q1, [sp, #432]
	ldr	w8, [sp, #464]
	str	w8, [x22, #32]
	stp	q0, q1, [x22]
	str	w23, [sp, #272]
	ldp	q0, q1, [x29, #-240]
	ldur	w8, [x29, #-208]
	str	w8, [x25, #32]
	stp	q0, q1, [x25]
	sub	x8, x29, #144                   ; =144
	add	x0, sp, #352                    ; =352
	add	x1, sp, #272                    ; =272
	bl	_fp_smul256
	add	x8, sp, #352                    ; =352
	add	x0, sp, #112                    ; =112
	sub	x1, x29, #144                   ; =144
	bl	_fp_sadd256
	ldr	x8, [sp, #360]
	cmp	x8, #3                          ; =3
	b.hi	LBB18_6
; %bb.3:                                ;   in Loop: Header=BB18_2 Depth=1
	add	w21, w21, #1                    ; =1
	ldr	w8, [sp, #28]                   ; 4-byte Folded Reload
	cmp	w21, w8
	cset	w26, lt
	cmp	w8, w21
	b.ne	LBB18_2
	b	LBB18_5
LBB18_4:
	mov	w26, #0
LBB18_5:
	mov	w21, #-1
LBB18_6:
	ldur	x8, [x29, #-104]
Lloh15:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh16:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh17:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB18_8
; %bb.7:
	mvn	w8, w26
	and	x0, x8, #0x1
	bfi	x0, x21, #32, #32
	add	sp, sp, #688                    ; =688
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #64]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #48]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #32]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #16]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp], #96             ; 16-byte Folded Reload
	ret
LBB18_8:
	bl	___stack_chk_fail
	.loh AdrpLdrGotLdr	Lloh12, Lloh13, Lloh14
	.loh AdrpLdrGotLdr	Lloh15, Lloh16, Lloh17
	.cfi_endproc
                                        ; -- End function
	.globl	_thread                         ; -- Begin function thread
	.p2align	2
_thread:                                ; @thread
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #464                    ; =464
	stp	d9, d8, [sp, #352]              ; 16-byte Folded Spill
	stp	x28, x27, [sp, #368]            ; 16-byte Folded Spill
	stp	x26, x25, [sp, #384]            ; 16-byte Folded Spill
	stp	x24, x23, [sp, #400]            ; 16-byte Folded Spill
	stp	x22, x21, [sp, #416]            ; 16-byte Folded Spill
	stp	x20, x19, [sp, #432]            ; 16-byte Folded Spill
	stp	x29, x30, [sp, #448]            ; 16-byte Folded Spill
	add	x29, sp, #448                   ; =448
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
	mov	x19, x0
Lloh18:
	adrp	x8, l_constinit@PAGE
Lloh19:
	add	x8, x8, l_constinit@PAGEOFF
	ldp	q1, q0, [x8]
	add	x10, sp, #160                   ; =160
	stur	q0, [x10, #120]
	stur	q1, [x10, #104]
	ldur	q0, [x0, #104]
	ldur	q1, [x0, #120]
	ldr	x8, [x0, #136]
	str	x8, [sp, #240]
	stp	q0, q1, [sp, #208]
	mov	w8, #2
	ldur	q0, [x10, #100]
	ldur	w9, [x29, #-156]
	str	w8, [sp, #160]
	stur	q0, [x10, #4]
	ldur	q0, [x10, #116]
	stur	q0, [x10, #20]
	str	w9, [sp, #196]
	sub	x8, x29, #152                   ; =152
	add	x0, sp, #208                    ; =208
	add	x1, sp, #160                    ; =160
	bl	_fp_smul256
	ldp	w20, w8, [x19]
	cmp	w20, w8
	b.le	LBB19_2
LBB19_1:
	mov	x0, #0
	bl	_pthread_exit
LBB19_2:
	add	x22, x19, #104                  ; =104
	add	x9, x19, #24                    ; =24
	add	x8, x19, #144                   ; =144
	stp	x8, x9, [sp]                    ; 16-byte Folded Spill
	add	x25, x19, #64                   ; =64
	add	x26, x19, #184                  ; =184
	mov	w27, #1031798784
	fmov	s8, #1.00000000
	movi.2d	v9, #0000000000000000
	mov	w21, #255
Lloh20:
	adrp	x23, _gradient_stops@PAGE
Lloh21:
	add	x23, x23, _gradient_stops@PAGEOFF
	b	LBB19_4
LBB19_3:                                ;   in Loop: Header=BB19_4 Depth=1
	add	w8, w20, #1                     ; =1
	ldr	w9, [x19, #4]
	cmp	w20, w9
	mov	x20, x8
	b.ge	LBB19_1
LBB19_4:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB19_8 Depth 2
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	ldp	q0, q1, [x8]
	ldr	x8, [x8, #32]
	str	x8, [sp, #192]
	stp	q0, q1, [sp, #160]
	add	x8, sp, #160                    ; =160
	ldur	q0, [x8, #136]
	ldur	q1, [x8, #152]
	stp	q0, q1, [sp, #112]
	ldur	x8, [x29, #-120]
	str	x8, [sp, #144]
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	ldp	q0, q1, [x8]
	ldr	x8, [x8, #32]
	str	x8, [sp, #96]
	stp	q0, q1, [sp, #64]
	add	x8, sp, #208                    ; =208
	add	x1, sp, #160                    ; =160
	add	x2, sp, #112                    ; =112
	add	x3, sp, #64                     ; =64
	mov	x0, x20
	bl	_calculateMathPos
	ldp	w24, w8, [x19, #8]
	cmp	w24, w8
	b.gt	LBB19_3
; %bb.5:                                ;   in Loop: Header=BB19_4 Depth=1
	neg	w28, w24
	b	LBB19_8
LBB19_6:                                ;   in Loop: Header=BB19_8 Depth=2
	lsr	x8, x0, #32
	add	w9, w8, #63                     ; =63
	cmp	w8, #0                          ; =0
	csel	w9, w9, w8, lt
	and	w9, w9, #0xffffffc0
	sub	w8, w8, w9
	scvtf	s0, w8
	fmov	s1, w27
	fmul	s0, s0, s1
	fcvtzs	w8, s0
	frintz	s1, s0
	fsub	s1, s0, s1
	mov	w9, #12
	smaddl	x8, w8, w9, x23
	ldr	d0, [x8]
	ldr	s2, [x8, #8]
	ldur	d3, [x8, #12]
	ldr	s4, [x8, #20]
	fminnm	s1, s1, s8
	fmaxnm	s1, s1, s9
	fsub.2s	v3, v3, v0
	fmla.2s	v0, v3, v1[0]
	fsub	s3, s4, s2
	fmadd	s1, s3, s1, s2
LBB19_7:                                ;   in Loop: Header=BB19_8 Depth=2
	ldr	w8, [x19, #16]
	madd	w8, w8, w24, w20
	sbfiz	x8, x8, #2, #32
	fcvtzs	w9, s0
	ldr	x10, [x19, #232]
	strb	w9, [x10, x8]
	mov	s0, v0[1]
	fcvtzs	w9, s0
	ldr	x10, [x19, #232]
	sxtw	x8, w8
	orr	x11, x8, #0x1
	strb	w9, [x10, x11]
	fcvtzs	w9, s1
	ldr	x10, [x19, #232]
	orr	x11, x8, #0x2
	strb	w9, [x10, x11]
	ldr	x9, [x19, #232]
	orr	x8, x8, #0x3
	strb	w21, [x9, x8]
	add	w8, w24, #1                     ; =1
	ldr	w9, [x19, #12]
	sub	w28, w28, #1                    ; =1
	cmp	w24, w9
	mov	x24, x8
	b.ge	LBB19_3
LBB19_8:                                ;   Parent Loop BB19_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w8, [x19, #20]
	add	w0, w28, w8
	ldp	q0, q1, [x25]
	ldr	x8, [x25, #32]
	str	x8, [sp, #144]
	stp	q0, q1, [sp, #112]
	ldp	q0, q1, [x22]
	ldr	x8, [x22, #32]
	str	x8, [sp, #96]
	stp	q0, q1, [sp, #64]
	ldp	q0, q1, [x26]
	ldr	x8, [x26, #32]
	str	x8, [sp, #48]
	stp	q0, q1, [sp, #16]
	add	x8, sp, #160                    ; =160
	add	x1, sp, #112                    ; =112
	add	x2, sp, #64                     ; =64
	add	x3, sp, #16                     ; =16
	bl	_calculateMathPos
	ldr	w2, [x19, #224]
	ldp	q0, q1, [sp, #208]
	stp	q0, q1, [sp, #112]
	ldr	x8, [sp, #240]
	str	x8, [sp, #144]
	ldp	q0, q1, [sp, #160]
	stp	q0, q1, [sp, #64]
	ldr	x8, [sp, #192]
	str	x8, [sp, #96]
	add	x0, sp, #112                    ; =112
	add	x1, sp, #64                     ; =64
	bl	_process_mandelbrot
	tbz	w0, #0, LBB19_6
; %bb.9:                                ;   in Loop: Header=BB19_8 Depth=2
	movi	d0, #0000000000000000
	movi.2d	v1, #0000000000000000
	b	LBB19_7
	.loh AdrpAdd	Lloh18, Lloh19
	.loh AdrpAdd	Lloh20, Lloh21
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__literal16,16byte_literals
	.p2align	4                               ; -- Begin function main
lCPI20_0:
	.long	0                               ; 0x0
	.long	160                             ; 0xa0
	.long	240                             ; 0xf0
	.long	160                             ; 0xa0
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3
lCPI20_1:
	.long	2                               ; 0x2
	.long	0                               ; 0x0
lCPI20_2:
	.long	900                             ; 0x384
	.long	600                             ; 0x258
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	stp	d11, d10, [sp, #-128]!          ; 16-byte Folded Spill
	stp	d9, d8, [sp, #16]               ; 16-byte Folded Spill
	stp	x28, x27, [sp, #32]             ; 16-byte Folded Spill
	stp	x26, x25, [sp, #48]             ; 16-byte Folded Spill
	stp	x24, x23, [sp, #64]             ; 16-byte Folded Spill
	stp	x22, x21, [sp, #80]             ; 16-byte Folded Spill
	stp	x20, x19, [sp, #96]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #112]            ; 16-byte Folded Spill
	add	x29, sp, #112                   ; =112
	sub	sp, sp, #2448                   ; =2448
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
Lloh22:
	adrp	x8, ___stack_chk_guard@GOTPAGE
Lloh23:
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
Lloh24:
	ldr	x8, [x8]
	stur	x8, [x29, #-136]
	stp	xzr, xzr, [sp, #120]
	mov	w0, #32
	bl	_SDL_Init
Lloh25:
	adrp	x21, ___stderrp@GOTPAGE
Lloh26:
	ldr	x21, [x21, ___stderrp@GOTPAGEOFF]
	tbnz	w0, #31, LBB20_66
; %bb.1:
	add	x3, sp, #120                    ; =120
	add	x4, sp, #128                    ; =128
	mov	w0, #900
	mov	w1, #600
	mov	w2, #0
	bl	_SDL_CreateWindowAndRenderer
	cmn	w0, #1                          ; =1
	b.eq	LBB20_67
; %bb.2:
	ldr	x0, [sp, #128]
	mov	w1, #8196
	movk	w1, #5750, lsl #16
	mov	w2, #1
	mov	w3, #900
	mov	w4, #600
	bl	_SDL_CreateTexture
	mov	x27, x0
	cbz	x0, LBB20_73
; %bb.3:
	mov	x0, x27
	mov	w1, #1
	bl	_SDL_SetTextureBlendMode
	cmn	w0, #1                          ; =1
	b.ne	LBB20_5
; %bb.4:
	ldr	x1, [x21]
Lloh27:
	adrp	x0, l_.str.6@PAGE
Lloh28:
	add	x0, x0, l_.str.6@PAGEOFF
	bl	_fputs
	ldr	x1, [x21]
Lloh29:
	adrp	x0, l_.str.7@PAGE
Lloh30:
	add	x0, x0, l_.str.7@PAGEOFF
	bl	_fputs
	ldr	x1, [x21]
Lloh31:
	adrp	x0, l_.str.8@PAGE
Lloh32:
	add	x0, x0, l_.str.8@PAGEOFF
	bl	_fputs
LBB20_5:
	ldr	x0, [sp, #128]
	mov	w1, #8196
	movk	w1, #5750, lsl #16
	mov	w2, #1
	mov	w3, #240
	mov	w4, #160
	bl	_SDL_CreateTexture
	mov	x28, x0
	cbz	x0, LBB20_74
; %bb.6:
	add	x23, sp, #2200                  ; =2200
Lloh33:
	adrp	x0, l_.str.10@PAGE
Lloh34:
	add	x0, x0, l_.str.10@PAGEOFF
	bl	_puts
	stp	xzr, xzr, [x23, #208]
	stp	xzr, xzr, [x23, #192]
	stp	xzr, xzr, [x23, #176]
	str	xzr, [x23, #168]
	movi.2d	v0, #0000000000000000
	stur	q0, [x23, #120]
	stur	q0, [x23, #136]
	stur	wzr, [x29, #-208]
	mov	w0, #1
	mov	w1, #62848
	movk	w1, #32, lsl #16
	bl	_calloc
	cbz	x0, LBB20_75
; %bb.7:
	str	x0, [sp, #96]                   ; 8-byte Folded Spill
	bl	_SDL_GetPerformanceCounter
	str	x0, [sp, #8]                    ; 8-byte Folded Spill
	mov	w25, #0
	add	x8, sp, #172                    ; =172
	add	x9, x8, #4                      ; =4
	add	x8, sp, #136                    ; =136
	add	x8, x8, #4                      ; =4
	stp	x8, x9, [sp, #72]               ; 16-byte Folded Spill
	add	x8, sp, #244                    ; =244
	add	x19, x8, #4                     ; =4
	add	x8, sp, #208                    ; =208
	add	x22, x8, #4                     ; =4
Lloh35:
	adrp	x8, lCPI20_0@PAGE
Lloh36:
	ldr	q0, [x8, lCPI20_0@PAGEOFF]
	str	q0, [sp, #48]                   ; 16-byte Folded Spill
	mov	w20, #2
Lloh37:
	adrp	x8, lCPI20_1@PAGE
Lloh38:
	ldr	d8, [x8, lCPI20_1@PAGEOFF]
Lloh39:
	adrp	x8, lCPI20_2@PAGE
Lloh40:
	ldr	d9, [x8, lCPI20_2@PAGEOFF]
	mov	w24, #1
	mov	w8, #1
	str	w8, [sp, #92]                   ; 4-byte Folded Spill
	mov	w26, #1
	stp	x28, x27, [sp, #24]             ; 16-byte Folded Spill
LBB20_8:                                ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB20_38 Depth 2
                                        ;     Child Loop BB20_14 Depth 2
                                        ;       Child Loop BB20_16 Depth 3
                                        ;     Child Loop BB20_45 Depth 2
	tbz	w26, #0, LBB20_79
; %bb.9:                                ;   in Loop: Header=BB20_8 Depth=1
	add	x0, sp, #2264                   ; =2264
	bl	_SDL_PollEvent
	mov	w26, #1
	cbnz	w0, LBB20_38
LBB20_10:                               ;   in Loop: Header=BB20_8 Depth=1
	str	w26, [sp, #44]                  ; 4-byte Folded Spill
	ldr	w8, [sp, #92]                   ; 4-byte Folded Reload
	cbz	w8, LBB20_43
; %bb.11:                               ;   in Loop: Header=BB20_8 Depth=1
	cmp	w8, #1                          ; =1
	b.ne	LBB20_61
; %bb.12:                               ;   in Loop: Header=BB20_8 Depth=1
	tbz	w24, #0, LBB20_59
; %bb.13:                               ;   in Loop: Header=BB20_8 Depth=1
	bl	_SDL_GetPerformanceCounter
	str	x0, [sp, #16]                   ; 8-byte Folded Spill
	mov	w28, #0
LBB20_14:                               ;   Parent Loop BB20_8 Depth=1
                                        ; =>  This Loop Header: Depth=2
                                        ;       Child Loop BB20_16 Depth 3
	add	x2, sp, #112                    ; =112
	add	x3, sp, #108                    ; =108
	mov	x0, x27
	mov	x1, #0
	bl	_SDL_LockTexture
	tbnz	w0, #31, LBB20_76
; %bb.15:                               ;   in Loop: Header=BB20_14 Depth=2
	str	w25, [sp, #40]                  ; 4-byte Folded Spill
	mov	x21, #0
	mov	x26, #0
	mov	w8, #220
	sub	w25, w8, w28
	add	x24, sp, #2200                  ; =2200
Lloh41:
	adrp	x27, _thread_blocks@PAGE+8
Lloh42:
	add	x27, x27, _thread_blocks@PAGEOFF+8
LBB20_16:                               ;   Parent Loop BB20_8 Depth=1
                                        ;     Parent Loop BB20_14 Depth=2
                                        ; =>    This Inner Loop Header: Depth=3
	cmp	x26, #4                         ; =4
	ldur	w8, [x27, #-8]
	csel	w9, w28, w25, lo
	add	w8, w8, w9
	ldr	d0, [x27]
	add	w9, w8, #4                      ; =4
Lloh43:
	adrp	x10, l_constinit.13@PAGE
Lloh44:
	add	x10, x10, l_constinit.13@PAGEOFF
	ldp	q1, q2, [x10]
	stp	q1, q2, [x19]
Lloh45:
	adrp	x10, l_constinit.14@PAGE
Lloh46:
	add	x10, x10, l_constinit.14@PAGEOFF
	ldp	q1, q2, [x10]
	stp	q1, q2, [x22]
	add	x10, sp, #280                   ; =280
	add	x3, x10, x21
	stp	w8, w9, [x3]
	str	d0, [x3, #8]
	str	d9, [x3, #16]
	str	w20, [x3, #24]
	add	x8, sp, #244                    ; =244
	ldp	q0, q1, [x8]
	stur	q0, [x3, #28]
	stur	q1, [x3, #44]
	ldr	w8, [sp, #276]
	stp	w8, w20, [x3, #60]
	ldr	w8, [sp, #240]
	str	w8, [x3, #100]
	ldp	q0, q1, [sp, #208]
	stur	q0, [x3, #68]
	stur	q1, [x3, #84]
	str	d8, [x3, #104]
	str	x20, [x3, #112]
	ldr	x8, [x23, #216]
	str	x8, [x3, #136]
	ldur	q0, [x23, #200]
	stur	q0, [x3, #120]
	ldur	q0, [x23, #184]
	str	q0, [x3, #144]
	mov	x8, #-9223372036854775808
	str	x8, [x3, #160]
	ldur	q0, [x23, #168]
	stur	q0, [x3, #168]
	mov	w8, #1
	str	w8, [x3, #184]
	ldur	w10, [x29, #-208]
	ldur	q0, [x23, #136]
	stur	q0, [x3, #204]
	ldur	q0, [x23, #120]
	stur	q0, [x3, #188]
	mov	w8, #256
	stp	w10, w8, [x3, #220]
	ldr	x8, [sp, #96]                   ; 8-byte Folded Reload
	str	x8, [x3, #232]
	mov	x0, x24
	mov	x1, #0
Lloh47:
	adrp	x2, _thread@PAGE
Lloh48:
	add	x2, x2, _thread@PAGEOFF
	bl	_pthread_create
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_27
; %bb.17:                               ;   in Loop: Header=BB20_16 Depth=3
	add	x26, x26, #1                    ; =1
	add	x24, x24, #8                    ; =8
	add	x21, x21, #240                  ; =240
	add	x27, x27, #16                   ; =16
	cmp	x21, #1920                      ; =1920
	b.ne	LBB20_16
; %bb.18:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [x23]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	ldr	w26, [sp, #44]                  ; 4-byte Folded Reload
	cbnz	w0, LBB20_26
; %bb.19:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [x23, #8]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_26
; %bb.20:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [x23, #16]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_26
; %bb.21:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [x23, #24]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_26
; %bb.22:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [x23, #32]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_26
; %bb.23:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [x23, #40]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_26
; %bb.24:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [x23, #48]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_26
; %bb.25:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [x23, #56]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbz	w0, LBB20_30
LBB20_26:                               ;   in Loop: Header=BB20_14 Depth=2
Lloh49:
	adrp	x21, ___stderrp@GOTPAGE
Lloh50:
	ldr	x21, [x21, ___stderrp@GOTPAGEOFF]
	ldr	x8, [x21]
	str	x0, [sp]
	mov	x0, x8
Lloh51:
	adrp	x1, l_.str.16@PAGE
Lloh52:
	add	x1, x1, l_.str.16@PAGEOFF
	bl	_fprintf
	mov	w9, #0
	mov	w25, #71
	mov	w8, #2
	ldr	x27, [sp, #32]                  ; 8-byte Folded Reload
	b	LBB20_28
LBB20_27:                               ;   in Loop: Header=BB20_14 Depth=2
Lloh53:
	adrp	x21, ___stderrp@GOTPAGE
Lloh54:
	ldr	x21, [x21, ___stderrp@GOTPAGEOFF]
	ldr	x8, [x21]
	str	x0, [sp]
	mov	x0, x8
Lloh55:
	adrp	x1, l_.str.15@PAGE
Lloh56:
	add	x1, x1, l_.str.15@PAGEOFF
	bl	_fprintf
	mov	w9, #0
	mov	w25, #71
	mov	w8, #2
	ldr	x27, [sp, #32]                  ; 8-byte Folded Reload
	ldr	w26, [sp, #44]                  ; 4-byte Folded Reload
LBB20_28:                               ;   in Loop: Header=BB20_14 Depth=2
	tbz	w9, #0, LBB20_57
; %bb.29:                               ;   in Loop: Header=BB20_14 Depth=2
	add	w8, w28, #5                     ; =5
	cmp	w28, #219                       ; =219
	mov	x28, x8
	b.ls	LBB20_14
	b	LBB20_58
LBB20_30:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [sp, #112]
	ldr	x1, [sp, #96]                   ; 8-byte Folded Reload
	mov	w2, #62848
	movk	w2, #32, lsl #16
	bl	_memcpy
	ldr	x27, [sp, #32]                  ; 8-byte Folded Reload
	mov	x0, x27
	bl	_SDL_UnlockTexture
	ldr	x0, [sp, #128]
	ldr	x1, [sp, #24]                   ; 8-byte Folded Reload
	mov	x2, #0
	mov	x3, #0
	bl	_SDL_RenderCopy
Lloh57:
	adrp	x21, ___stderrp@GOTPAGE
Lloh58:
	ldr	x21, [x21, ___stderrp@GOTPAGEOFF]
	tbnz	w0, #31, LBB20_33
; %bb.31:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [sp, #128]
	mov	x1, x27
	mov	x2, #0
	mov	x3, #0
	bl	_SDL_RenderCopy
	tbnz	w0, #31, LBB20_34
; %bb.32:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x0, [sp, #128]
	bl	_SDL_RenderPresent
	mov	w8, #0
	mov	w9, #1
	ldr	w25, [sp, #40]                  ; 4-byte Folded Reload
	b	LBB20_28
LBB20_33:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x24, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
	mov	x0, x24
Lloh59:
	adrp	x1, l_.str.17@PAGE
Lloh60:
	add	x1, x1, l_.str.17@PAGEOFF
	b	LBB20_35
LBB20_34:                               ;   in Loop: Header=BB20_14 Depth=2
	ldr	x24, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
	mov	x0, x24
Lloh61:
	adrp	x1, l_.str.18@PAGE
Lloh62:
	add	x1, x1, l_.str.18@PAGEOFF
LBB20_35:                               ;   in Loop: Header=BB20_14 Depth=2
	bl	_fprintf
	mov	w9, #0
	mov	w25, #71
	mov	w8, #2
	b	LBB20_28
LBB20_36:                               ;   in Loop: Header=BB20_38 Depth=2
	cmp	w8, #256                        ; =256
	csel	w26, w26, wzr, ne
LBB20_37:                               ;   in Loop: Header=BB20_38 Depth=2
	add	x0, sp, #2264                   ; =2264
	bl	_SDL_PollEvent
	cbz	w0, LBB20_10
LBB20_38:                               ;   Parent Loop BB20_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w8, [sp, #2264]
	cmp	w8, #768                        ; =768
	b.ne	LBB20_36
; %bb.39:                               ;   in Loop: Header=BB20_38 Depth=2
	ldr	w8, [sp, #2280]
	cmp	w8, #43                         ; =43
	b.ne	LBB20_37
; %bb.40:                               ;   in Loop: Header=BB20_38 Depth=2
	ldr	w8, [sp, #92]                   ; 4-byte Folded Reload
	cmp	w8, #1                          ; =1
	b.ne	LBB20_42
; %bb.41:                               ;   in Loop: Header=BB20_38 Depth=2
	str	wzr, [sp, #92]                  ; 4-byte Folded Spill
	b	LBB20_37
LBB20_42:                               ;   in Loop: Header=BB20_38 Depth=2
	ldr	x0, [sp, #96]                   ; 8-byte Folded Reload
	mov	w1, #62848
	movk	w1, #32, lsl #16
	bl	_bzero
	mov	w24, #1
	mov	w8, #1
	str	w8, [sp, #92]                   ; 4-byte Folded Spill
	b	LBB20_37
LBB20_43:                               ;   in Loop: Header=BB20_8 Depth=1
	add	x2, sp, #112                    ; =112
	add	x3, sp, #108                    ; =108
	mov	x0, x28
	mov	x1, #0
	bl	_SDL_LockTexture
	tbnz	w0, #31, LBB20_80
; %bb.44:                               ;   in Loop: Header=BB20_8 Depth=1
	str	w25, [sp, #40]                  ; 4-byte Folded Spill
	mov	x10, #0
	mov	w9, #0
	add	x0, sp, #2200                   ; =2200
LBB20_45:                               ;   Parent Loop BB20_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	add	x21, x10, #240                  ; =240
	cmp	x21, #2160                      ; =2160
	b.eq	LBB20_48
; %bb.46:                               ;   in Loop: Header=BB20_45 Depth=2
	add	w25, w9, #30                    ; =30
	add	x26, x0, #8                     ; =8
Lloh63:
	adrp	x8, l_constinit.21@PAGE
Lloh64:
	add	x8, x8, l_constinit.21@PAGEOFF
	ldp	q0, q1, [x8]
	ldr	x8, [sp, #80]                   ; 8-byte Folded Reload
	stp	q0, q1, [x8]
Lloh65:
	adrp	x8, l_constinit.22@PAGE
Lloh66:
	add	x8, x8, l_constinit.22@PAGEOFF
	ldp	q0, q1, [x8]
	ldr	x8, [sp, #72]                   ; 8-byte Folded Reload
	stp	q0, q1, [x8]
	ldr	x8, [sp, #112]
	add	x11, sp, #280                   ; =280
	add	x3, x11, x10
	add	w10, w9, #29                    ; =29
	stp	w9, w10, [x3]
	ldr	q0, [sp, #48]                   ; 16-byte Folded Reload
	stur	q0, [x3, #8]
	str	w20, [x3, #24]
	ldur	q0, [sp, #172]
	ldur	q1, [sp, #188]
	stur	q0, [x3, #28]
	stur	q1, [x3, #44]
	ldr	w9, [sp, #204]
	stp	w9, w20, [x3, #60]
	ldr	w9, [sp, #168]
	str	w9, [x3, #100]
	ldur	q0, [sp, #136]
	ldur	q1, [sp, #152]
	stur	q0, [x3, #68]
	stur	q1, [x3, #84]
	str	d8, [x3, #104]
	str	x20, [x3, #112]
	ldr	x9, [x23, #216]
	str	x9, [x3, #136]
	ldur	q0, [x23, #200]
	stur	q0, [x3, #120]
	ldur	q0, [x23, #184]
	str	q0, [x3, #144]
	mov	x9, #-9223372036854775808
	str	x9, [x3, #160]
	ldur	q0, [x23, #168]
	stur	q0, [x3, #168]
	mov	w9, #1
	str	w9, [x3, #184]
	ldur	w11, [x29, #-208]
	ldur	q0, [x23, #136]
	stur	q0, [x3, #204]
	ldur	q0, [x23, #120]
	stur	q0, [x3, #188]
	mov	w9, #256
	stp	w11, w9, [x3, #220]
	str	x8, [x3, #232]
	mov	x1, #0
Lloh67:
	adrp	x2, _thread@PAGE
Lloh68:
	add	x2, x2, _thread@PAGEOFF
	bl	_pthread_create
	mov	x8, x0
	mov	x0, x26
	mov	x10, x21
	mov	x9, x25
	cbz	w8, LBB20_45
; %bb.47:                               ;   in Loop: Header=BB20_8 Depth=1
Lloh69:
	adrp	x21, ___stderrp@GOTPAGE
Lloh70:
	ldr	x21, [x21, ___stderrp@GOTPAGEOFF]
	ldr	x0, [x21]
	str	x8, [sp]
Lloh71:
	adrp	x1, l_.str.15@PAGE
Lloh72:
	add	x1, x1, l_.str.15@PAGEOFF
	bl	_fprintf
	mov	w9, #0
	mov	w25, #71
	mov	w8, #2
	ldr	w26, [sp, #44]                  ; 4-byte Folded Reload
	cbnz	w9, LBB20_61
	b	LBB20_62
LBB20_48:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [x23]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	ldr	w26, [sp, #44]                  ; 4-byte Folded Reload
	cbnz	w0, LBB20_56
; %bb.49:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [x23, #8]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_56
; %bb.50:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [x23, #16]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_56
; %bb.51:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [x23, #24]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_56
; %bb.52:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [x23, #32]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_56
; %bb.53:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [x23, #40]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_56
; %bb.54:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [x23, #48]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbnz	w0, LBB20_56
; %bb.55:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [x23, #56]
	mov	x1, #0
	bl	_pthread_join
                                        ; kill: def $w0 killed $w0 def $x0
	cbz	w0, LBB20_63
LBB20_56:                               ;   in Loop: Header=BB20_8 Depth=1
Lloh73:
	adrp	x21, ___stderrp@GOTPAGE
Lloh74:
	ldr	x21, [x21, ___stderrp@GOTPAGEOFF]
	ldr	x8, [x21]
	str	x0, [sp]
	mov	x0, x8
Lloh75:
	adrp	x1, l_.str.16@PAGE
Lloh76:
	add	x1, x1, l_.str.16@PAGEOFF
	bl	_fprintf
	mov	w9, #0
	mov	w25, #71
	mov	w8, #2
	cbnz	w9, LBB20_61
	b	LBB20_62
LBB20_57:                               ;   in Loop: Header=BB20_8 Depth=1
	mov	w24, #0
	ldr	x28, [sp, #24]                  ; 8-byte Folded Reload
	b	LBB20_62
LBB20_58:                               ;   in Loop: Header=BB20_8 Depth=1
	bl	_SDL_GetPerformanceCounter
	ldr	x8, [sp, #16]                   ; 8-byte Folded Reload
	sub	x8, x0, x8
	ucvtf	s10, x8
	bl	_SDL_GetPerformanceFrequency
	ucvtf	s0, x0
	mov	w8, #1148846080
	fmov	s1, w8
	fmul	s1, s10, s1
	fdiv	s0, s1, s0
	fcvt	d0, s0
	str	d0, [sp]
Lloh77:
	adrp	x0, l_.str.19@PAGE
Lloh78:
	add	x0, x0, l_.str.19@PAGEOFF
	bl	_printf
	ldr	x28, [sp, #24]                  ; 8-byte Folded Reload
LBB20_59:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [sp, #128]
	mov	x1, x27
	mov	x2, #0
	mov	x3, #0
	bl	_SDL_RenderCopy
	tbnz	w0, #31, LBB20_81
; %bb.60:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [sp, #128]
	bl	_SDL_RenderPresent
	mov	w24, #0
LBB20_61:                               ;   in Loop: Header=BB20_8 Depth=1
	mov	w8, #0
LBB20_62:                               ;   in Loop: Header=BB20_8 Depth=1
	cbz	w8, LBB20_8
	b	LBB20_77
LBB20_63:                               ;   in Loop: Header=BB20_8 Depth=1
	mov	x0, x28
	bl	_SDL_UnlockTexture
	ldr	x0, [sp, #128]
	mov	x1, x28
	mov	x2, #0
	mov	x3, #0
	bl	_SDL_RenderCopy
	tbnz	w0, #31, LBB20_65
; %bb.64:                               ;   in Loop: Header=BB20_8 Depth=1
	ldr	x0, [sp, #128]
	bl	_SDL_RenderPresent
	bl	_SDL_GetPerformanceCounter
	mov	x21, x0
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	sub	x8, x0, x8
	ucvtf	s10, x8
	bl	_SDL_GetPerformanceFrequency
	ucvtf	s0, x0
	mov	w8, #1148846080
	fmov	s1, w8
	fmul	s1, s10, s1
	fdiv	s0, s1, s0
	fcvt	d0, s0
	str	d0, [sp]
Lloh79:
	adrp	x0, l_.str.23@PAGE
Lloh80:
	add	x0, x0, l_.str.23@PAGEOFF
	bl	_printf
	mov	w8, #0
	mov	w9, #1
	str	x21, [sp, #8]                   ; 8-byte Folded Spill
	ldr	x28, [sp, #24]                  ; 8-byte Folded Reload
Lloh81:
	adrp	x21, ___stderrp@GOTPAGE
Lloh82:
	ldr	x21, [x21, ___stderrp@GOTPAGEOFF]
	ldp	w25, w26, [sp, #40]             ; 8-byte Folded Reload
	cbnz	w9, LBB20_61
	b	LBB20_62
LBB20_65:                               ;   in Loop: Header=BB20_8 Depth=1
Lloh83:
	adrp	x21, ___stderrp@GOTPAGE
Lloh84:
	ldr	x21, [x21, ___stderrp@GOTPAGEOFF]
	ldr	x25, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
	mov	x0, x25
Lloh85:
	adrp	x1, l_.str.17@PAGE
Lloh86:
	add	x1, x1, l_.str.17@PAGEOFF
	bl	_fprintf
	mov	w9, #0
	mov	w25, #71
	mov	w8, #2
	ldr	x28, [sp, #24]                  ; 8-byte Folded Reload
	ldr	w26, [sp, #44]                  ; 4-byte Folded Reload
	cbnz	w9, LBB20_61
	b	LBB20_62
LBB20_66:
	ldr	x19, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh87:
	adrp	x1, l_.str.3@PAGE
Lloh88:
	add	x1, x1, l_.str.3@PAGEOFF
	b	LBB20_68
LBB20_67:
	ldr	x19, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh89:
	adrp	x1, l_.str.4@PAGE
Lloh90:
	add	x1, x1, l_.str.4@PAGEOFF
LBB20_68:
	mov	x0, x19
	bl	_fprintf
	mov	x28, #0
	mov	x27, #0
LBB20_69:
	mov	x19, #0
	mov	w25, #71
LBB20_70:
Lloh91:
	adrp	x0, l_.str.24@PAGE
Lloh92:
	add	x0, x0, l_.str.24@PAGEOFF
	bl	_puts
	mov	x0, x19
	bl	_free
	mov	x0, x28
	bl	_SDL_DestroyTexture
	mov	x0, x27
	bl	_SDL_DestroyTexture
	ldr	x0, [sp, #128]
	bl	_SDL_DestroyRenderer
	ldr	x0, [sp, #120]
	bl	_SDL_DestroyWindow
	bl	_SDL_Quit
LBB20_71:
	ldur	x8, [x29, #-136]
Lloh93:
	adrp	x9, ___stack_chk_guard@GOTPAGE
Lloh94:
	ldr	x9, [x9, ___stack_chk_guard@GOTPAGEOFF]
Lloh95:
	ldr	x9, [x9]
	cmp	x9, x8
	b.ne	LBB20_84
; %bb.72:
	mov	x0, x25
	add	sp, sp, #2448                   ; =2448
	ldp	x29, x30, [sp, #112]            ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #96]             ; 16-byte Folded Reload
	ldp	x22, x21, [sp, #80]             ; 16-byte Folded Reload
	ldp	x24, x23, [sp, #64]             ; 16-byte Folded Reload
	ldp	x26, x25, [sp, #48]             ; 16-byte Folded Reload
	ldp	x28, x27, [sp, #32]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #16]               ; 16-byte Folded Reload
	ldp	d11, d10, [sp], #128            ; 16-byte Folded Reload
	ret
LBB20_73:
	ldr	x19, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh96:
	adrp	x1, l_.str.5@PAGE
Lloh97:
	add	x1, x1, l_.str.5@PAGEOFF
	mov	x0, x19
	bl	_fprintf
	mov	x28, #0
	b	LBB20_69
LBB20_74:
	ldr	x20, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh98:
	adrp	x1, l_.str.9@PAGE
Lloh99:
	add	x1, x1, l_.str.9@PAGEOFF
	mov	x0, x20
	bl	_fprintf
	b	LBB20_69
LBB20_75:
	ldr	x1, [x21]
Lloh100:
	adrp	x0, l_.str.11@PAGE
Lloh101:
	add	x0, x0, l_.str.11@PAGEOFF
	bl	_fputs
	b	LBB20_69
LBB20_76:
	ldr	x22, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh102:
	adrp	x1, l_.str.12@PAGE
Lloh103:
	add	x1, x1, l_.str.12@PAGEOFF
	mov	x0, x22
	bl	_fprintf
	ldr	x28, [sp, #24]                  ; 8-byte Folded Reload
	b	LBB20_83
LBB20_77:
	cmp	w8, #2                          ; =2
	ldr	x19, [sp, #96]                  ; 8-byte Folded Reload
	b.eq	LBB20_70
; %bb.78:
	mov	w25, #0
	b	LBB20_71
LBB20_79:
	ldr	x19, [sp, #96]                  ; 8-byte Folded Reload
	b	LBB20_70
LBB20_80:
	ldr	x22, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh104:
	adrp	x1, l_.str.20@PAGE
Lloh105:
	add	x1, x1, l_.str.20@PAGEOFF
	b	LBB20_82
LBB20_81:
	ldr	x22, [x21]
	bl	_SDL_GetError
	str	x0, [sp]
Lloh106:
	adrp	x1, l_.str.18@PAGE
Lloh107:
	add	x1, x1, l_.str.18@PAGEOFF
LBB20_82:
	mov	x0, x22
	bl	_fprintf
LBB20_83:
	mov	w25, #71
	ldr	x19, [sp, #96]                  ; 8-byte Folded Reload
	b	LBB20_70
LBB20_84:
	bl	___stack_chk_fail
	.loh AdrpLdrGot	Lloh25, Lloh26
	.loh AdrpLdrGotLdr	Lloh22, Lloh23, Lloh24
	.loh AdrpAdd	Lloh31, Lloh32
	.loh AdrpAdd	Lloh29, Lloh30
	.loh AdrpAdd	Lloh27, Lloh28
	.loh AdrpAdd	Lloh33, Lloh34
	.loh AdrpLdr	Lloh39, Lloh40
	.loh AdrpAdrp	Lloh37, Lloh39
	.loh AdrpLdr	Lloh37, Lloh38
	.loh AdrpAdrp	Lloh35, Lloh37
	.loh AdrpLdr	Lloh35, Lloh36
	.loh AdrpAdd	Lloh41, Lloh42
	.loh AdrpAdd	Lloh47, Lloh48
	.loh AdrpAdd	Lloh45, Lloh46
	.loh AdrpAdd	Lloh43, Lloh44
	.loh AdrpAdd	Lloh51, Lloh52
	.loh AdrpLdrGot	Lloh49, Lloh50
	.loh AdrpAdd	Lloh55, Lloh56
	.loh AdrpLdrGot	Lloh53, Lloh54
	.loh AdrpLdrGot	Lloh57, Lloh58
	.loh AdrpAdd	Lloh59, Lloh60
	.loh AdrpAdd	Lloh61, Lloh62
	.loh AdrpAdd	Lloh67, Lloh68
	.loh AdrpAdd	Lloh65, Lloh66
	.loh AdrpAdd	Lloh63, Lloh64
	.loh AdrpAdd	Lloh71, Lloh72
	.loh AdrpLdrGot	Lloh69, Lloh70
	.loh AdrpAdd	Lloh75, Lloh76
	.loh AdrpLdrGot	Lloh73, Lloh74
	.loh AdrpAdd	Lloh77, Lloh78
	.loh AdrpLdrGot	Lloh81, Lloh82
	.loh AdrpAdd	Lloh79, Lloh80
	.loh AdrpAdd	Lloh85, Lloh86
	.loh AdrpLdrGot	Lloh83, Lloh84
	.loh AdrpAdd	Lloh87, Lloh88
	.loh AdrpAdd	Lloh89, Lloh90
	.loh AdrpAdd	Lloh91, Lloh92
	.loh AdrpLdrGotLdr	Lloh93, Lloh94, Lloh95
	.loh AdrpAdd	Lloh96, Lloh97
	.loh AdrpAdd	Lloh98, Lloh99
	.loh AdrpAdd	Lloh100, Lloh101
	.loh AdrpAdd	Lloh102, Lloh103
	.loh AdrpAdd	Lloh104, Lloh105
	.loh AdrpAdd	Lloh106, Lloh107
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
Lloh108:
	adrp	x0, l___func__.fp_sadd256@PAGE
Lloh109:
	add	x0, x0, l___func__.fp_sadd256@PAGEOFF
Lloh110:
	adrp	x1, l_.str@PAGE
Lloh111:
	add	x1, x1, l_.str@PAGEOFF
Lloh112:
	adrp	x3, l_.str.1@PAGE
Lloh113:
	add	x3, x3, l_.str.1@PAGEOFF
	mov	w2, #252
	bl	___assert_rtn
	.loh AdrpAdd	Lloh112, Lloh113
	.loh AdrpAdd	Lloh110, Lloh111
	.loh AdrpAdd	Lloh108, Lloh109
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

	.section	__TEXT,__const
	.p2align	3                               ; @constinit
l_constinit:
	.quad	1                               ; 0x1
	.quad	-9223372036854775808            ; 0x8000000000000000
	.quad	0                               ; 0x0
	.quad	0                               ; 0x0

	.section	__TEXT,__cstring,cstring_literals
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
	.asciz	"Unable to lock full texture: %s\n"

	.section	__TEXT,__const
	.p2align	3                               ; @constinit.13
l_constinit.13:
	.quad	0                               ; 0x0
	.quad	20496382304121724               ; 0x48d159e26af37c
	.quad	327942116865947584              ; 0x48d159e26af37c0
	.quad	5247073869855161348             ; 0x48d159e26af37c04

	.p2align	3                               ; @constinit.14
l_constinit.14:
	.quad	0                               ; 0x0
	.quad	30744573456182586               ; 0x6d3a06d3a06d3a
	.quad	491913175298921376              ; 0x6d3a06d3a06d3a0
	.quad	7870610804782742022             ; 0x6d3a06d3a06d3a06

	.section	__TEXT,__cstring,cstring_literals
l_.str.15:                              ; @.str.15
	.asciz	"Unable to create thread: Error code %d\n"

l_.str.16:                              ; @.str.16
	.asciz	"Unable to join thread: Error code %d\n"

l_.str.17:                              ; @.str.17
	.asciz	"Unable to copy preview texture: %s\n"

l_.str.18:                              ; @.str.18
	.asciz	"Unable to copy full texture: %s\n"

l_.str.19:                              ; @.str.19
	.asciz	"Full render completed. Time taken: %fms.\n"

l_.str.20:                              ; @.str.20
	.asciz	"Unable to lock preview texture: %s\n"

	.section	__TEXT,__const
	.p2align	3                               ; @constinit.21
l_constinit.21:
	.quad	0                               ; 0x0
	.quad	76861433640456465               ; 0x111111111111111
	.quad	1229782938247303441             ; 0x1111111111111111
	.quad	1229782938247303441             ; 0x1111111111111111

	.p2align	3                               ; @constinit.22
l_constinit.22:
	.quad	0                               ; 0x0
	.quad	115292150460684697              ; 0x199999999999999
	.quad	-7378697629483820647            ; 0x9999999999999999
	.quad	-7378697629483820647            ; 0x9999999999999999

	.section	__TEXT,__cstring,cstring_literals
l_.str.23:                              ; @.str.23
	.asciz	"Preview render completed. Time taken: %fms.\n"

l_.str.24:                              ; @.str.24
	.asciz	"Quitting..."

.subsections_via_symbols
