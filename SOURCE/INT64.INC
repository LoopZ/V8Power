; Copyright (C) 2020-2022 Jerome Shidel
; Open source see License file

; NASM 2.14rc0 for DOS

; Undefine if you need to save a couple bytes and don't care about trashed
; registers.
%idefine SAVE_REGS

; Macro Functions

; Signed 64-bit integer function macros
; Int64_StdOutHex   address

; Unsigned 64-bit integer function macros
; uInt64_StdOutHex	address
; uInt64_StdOutInt	address
; uInt64_Zero		address
; uInt64_Store		address (from DX:CX:BX:AX)
; uInt64_Load		address (into DX:CX:BX:AX)
; uInt64_MOV		dest, src
; uInt64_CMP		address1, address2 (test flags, ie JA, JBE and etc)
; uInt64_INC		address, (CF if overflow)
; uInt64_DEC		address, (CF if underflow)
; uInt64_ADD		address1, address2 (result in address1, CF overflow)

; Signed versions identical to the Unsigned 64-bit versions
; sInt64_StdOutHex	address
; sInt64_Zero		address
; sInt64_Store		address (from DX:CX:BX:AX)
; sInt64_Load		address (into DX:CX:BX:AX)
; sInt64_MOV		dest, src

; Signed 64-bit integer function macros
; sInt64_ABS   		address
; sInt64_StdOutInt	address
; sInt64_INC		address, (CF if overflow)
; sInt64_DEC		address, (CF if underflow)


; coming soon, or at least someday eventually.
; uInt64_MUL		address1, address2 (result in address1, CF overflow)
; uInt64_DIV		address1, address2 (result in address1, CF overflow)

; sInt64_CMP		address1, address2 (test flags, ie JA, JBE and etc)
; sInt64_ADD		address1, address2 (result in address1, CF overflow)
; sInt64_MUL		address1, address2 (result in address1, CF overflow)
; sInt64_DIV		address1, address2 (result in address1, CF overflow)

; -----------------------------------------------------------------------------
%idefine sInt64_StdOutHex 	uInt64_StdOutHex
%idefine sInt64_Zero		uInt64_Zero
%idefine sInt64_Store		uInt64_Store
%idefine sInt64_Load 		uInt64_Load
%idefine sInt64_MOV 		uInt64_MOV

%imacro Int64_Store 1
    uInt64_Store %1
%endmacro

%imacro Int64_Load 1
    uInt64_Load %1
%endmacro

%imacro uInt64_StdOutHex 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call proc_uInt64_StdOutHex
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro uInt64_StdOutInt 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call proc_uInt64_StdOutInt
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro uInt64_Zero 1
    %ifdef SAVE_REGS
        push di
    %endif
    mov  di, %1
    call proc_uInt64_Zero
    %ifdef SAVE_REGS
        pop  di
    %endif
%endmacro

%imacro uInt64_Store 1
    mov  [%1], ax
    mov  [%1 + 2], bx
    mov  [%1 + 4], cx
    mov  [%1 + 6], dx
%endmacro

%imacro uInt64_Load 1
    mov  ax, [%1]
    mov  bx, [%1 + 2]
    mov  cx, [%1 + 4]
    mov  dx, [%1 + 6]
%endmacro

%imacro uInt64_MOV 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call proc_uInt64_MOV
    %ifdef SAVE_REGS
        pop  si
        pop  di
    %endif
%endmacro

%imacro uInt64_CMP 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call proc_uInt64_CMP
    %ifdef SAVE_REGS
        pop  si
        pop  di
    %endif
%endmacro

%imacro uInt64_ADD 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call proc_uInt64_ADD
    %ifdef SAVE_REGS
        pop  si
        pop  di
    %endif
%endmacro

%imacro uInt64_MUL_WORD 2
    %ifdef SAVE_REGS
        push di
        push bx
    %endif
    mov  di, %1
    mov  bx, %2
    call proc_uInt64_MUL_WORD
    %ifdef SAVE_REGS
        pop  bx
        pop  di
    %endif
%endmacro

%imacro uInt64_INC 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call proc_uInt64_INC
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro uInt64_DEC 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call proc_uInt64_DEC
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro sInt64_INC 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call proc_sInt64_INC
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro sInt64_DEC 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call proc_sInt64_DEC
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro sInt64_ABS 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call proc_sInt64_ABS
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro sInt64_StdOutInt 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call proc_sInt64_StdOutInt
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

; Functions and procedures ----------------------------------------------------

proc_uInt64_StdOutHex:
    ; si address of Int64
    %ifdef SAVE_REGS
        pushf
        push        ax
    %endif
    mov             cx, 4   ; words in Int64
    add             si, 6   ; Offset to last word of Int64
.Repeat:
    mov             ax, [si]
    push            cx
    StdOutHexWord   ax
    pop             cx
    sub             si, 2
    loop            .Repeat
    %ifdef SAVE_REGS
        pop         ax
        popf
    %endif
    ret

proc_uInt64_StdOutInt:
    ; si address of Int64
    push        bp
    push        si
    push        di
    %ifdef SAVE_REGS
        pushf
        push        ax
        push        bx
        push        cx
        push        dx
    %endif

    mov  bx, [si]
    mov  cx, [si + 2]
    mov  di, [si + 4]
    mov  si, [si + 6]

    ; si:di:cx:bx is 64bit number

    mov         bp, 0x000a      ; Base 10 divisor, all digits 0-9
    push        bp              ; Push 10 to stack for terminate.

.Repeat:
    xor         dx, dx
    xchg        ax, si
    div         bp              ; 0 : si
    xchg        ax, si
    xchg        ax, di
    div         bp              ; si remainder : di
    xchg        ax, di
    xchg        ax, cx
    div         bp              ; di remainder : cx
    xchg        ax, cx
    xchg        ax, bx
    div         bp              ; cx remainder : bx
    mov         bx, ax
    push        dx              ; push remainder to stack
    or          ax, cx          ; or values to test non-zero
    or          ax, di
    or          ax, si
    jnz         .Repeat         ; Not zero then repeat

.Display:
    pop         ax
    cmp         ax, bp
    je          .Done
    add         al, 0x30
    StdOutChar  al
    jmp         .Display

.Done:

    %ifdef SAVE_REGS
        pop         dx
        pop         cx
        pop         bx
        pop         ax
        popf
    %endif
    pop         si
    pop         di
    pop         bp
    ret

proc_uInt64_Zero:
    ; di address of Int64
    %ifdef SAVE_REGS
        pushf
        push ax
        push cx
        push di
    %endif
    cld
    xor  ax, ax
    mov  cx, 4
.Repeat:
    stosw
    loop .Repeat
    %ifdef SAVE_REGS
        pop  di
        pop  cx
        pop  ax
        popf
    %endif
    ret

proc_uInt64_MOV:
    ; di destination Int64
    ; si source Int64
    %ifdef SAVE_REGS
        push ax
    %endif
    mov  ax, [si]
    mov	 [di], ax
    mov  ax, [si + 2]
    mov	 [di + 2], ax
    mov  ax, [si + 4]
    mov	 [di + 4], ax
    mov  ax, [si + 6]
    mov	 [di + 6], ax
    %ifdef SAVE_REGS
        pop ax
    %endif
    ret

proc_uInt64_CMP:
    ; di first Int64
    ; si second Int64
    %ifdef SAVE_REGS
        push ax
        push bx
        push cx
    %endif
    mov  bx, 8              ; Int64 Size in bytes, start MSB
.Repeat:
    sub  bx, 2
    mov  ax, [di+bx]
    mov  cx, [si+bx]
    cmp  ax, cx
    jne  .Done              ; JNE and preserve flags
    test bx, bx             ; test if done
    jnz  .Repeat
                            ; 0 and Int64's equal
.Done:
    %ifdef SAVE_REGS
        pop  cx
        pop  bx
        pop  ax
    %endif
    ret

proc_uInt64_ADD:
    ; di first Int64
    ; si second Int64
    %ifdef SAVE_REGS
        push ax
        push bx
        push cx
    %endif
    xor  bx, bx
    mov  cx, 4          ; Words in Int64
    clc
    pushf
.Repeat:
    popf
    mov     ax, [di + bx]
    adc     ax, [si + bx]
    mov     [di + bx], ax
    pushf
    add     bx, 2
    loop    .Repeat
    popf
    %ifdef SAVE_REGS
        pop  cx
        pop  bx
        pop  ax
    %endif
    ; Carry Flag on Overflow.
    ret

proc_uInt64_MUL_WORD:
    ; di address of Int64
    ; bx multiplication factor
    %ifdef SAVE_REGS
        push    ax
        push    cx
        push    dx
        push    si
    %endif
    mov     cx, 4
    xor     si, si
    clc
    pushf
.Repeat:
    mov     ax, [di]
    mul     bx
    xchg    si, dx
    popf
    adc     ax, dx
    pushf
    mov     [di], ax
    add     di, 2
    loop    .Repeat
    popf
    jc      .Overflow
    test    si, si
    jnz     .Overflow
    clc
    jmp     .Done
.Overflow:
    stc
.Done:
    %ifdef SAVE_REGS
        pop     si
        pop     dx
        pop     cx
        pop     ax
    %endif
    ; Carry Flag on Overflow.
    ret

proc_uInt64_INC:
    ; si address destination/source Int64, CF if overflowed
	inc word [si]
	jnz	 .DoneInc
	inc word [si + 2]
	jnz	 .DoneInc
	inc word [si + 4]
	jnz	 .DoneInc
	inc word [si + 6]
	jnz	 .DoneInc
	stc
	jmp	.Done
.DoneInc:
	clc
.Done:
	ret

proc_uInt64_DEC:
    ; si address destination/source Int64, CF if overflowed
    	push	ax
    	mov	ax, 0xffff
	dec 	word [si]
	cmp	ax, [si]
	jne	 .DoneInc
	dec 	word [si + 2]
	cmp	ax, [si + 2]
	jne	 .DoneInc
	dec 	word [si + 4]
	cmp	ax, [si + 4]
	jne	 .DoneInc
	dec 	word [si + 6]
	cmp	ax, [si + 6]
	jne	 .DoneInc
	stc
	jmp	.Done
.DoneInc:
	clc
.Done:
	pop	ax
	ret

proc_sInt64_INC:
    %ifdef SAVE_REGS
	push	ax
	push    bx
    %endif
	mov	ax, [si+6]
	and	ax, 0x8000
	call	proc_uInt64_INC
	jc	.Done
	mov	bx, [si+6]
	and	bx, 0x8000
	cmp	ax, bx
	je	.Done
.Done:
    %ifdef SAVE_REGS
	pop	bx
	pop	ax
    %endif
	ret

proc_sInt64_DEC:
    %ifdef SAVE_REGS
	push	ax
	push    bx
    %endif
	mov	ax, [si+6]
	and	ax, 0x8000
	call	proc_uInt64_DEC
	jc	.Done
	mov	bx, [si+6]
	and	bx, 0x8000
	cmp	ax, bx
	je	.Done
.Done:
    %ifdef SAVE_REGS
	pop	bx
	pop	ax
    %endif
	ret


proc_sInt64_ABS:
    ; si address destination/source Int64
    push	ax
    mov		ax, [si+6]
    test	ax, 0x8000
    jz		.Positive
    not		word [si+6]
    not		word [si+4]
    not		word [si+2]
    not		word [si]
    call	proc_uInt64_INC
    stc
    jmp		.Done
.Positive:
    clc
.Done:
    pop		ax
    ret

proc_sInt64_StdOutInt:
    ; si address destination/source Int64
    %ifdef SAVE_REGS
	push    di
    %endif
    mov  	di, temp_StdOutInt
    call	proc_uInt64_MOV
    mov		si, di
    call	proc_sInt64_ABS
    jnc		.NotNegative
    StdOutChar  '-'
.NotNegative:
    call	proc_uInt64_StdOutInt
    %ifdef SAVE_REGS
        pop	di
    %endif
    ret

temp_StdOutInt:
    dq 0
