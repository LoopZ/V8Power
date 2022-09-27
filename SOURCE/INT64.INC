; Copyright (C) 2020-2022 Jerome Shidel
; Open source see License file

; NASM 2.14rc0 for DOS

; Undefine if you need to save a couple bytes and don't care about trashed
; registers.
%idefine SAVE_REGS

; Below are a list of 64-bit integer functions for working with signed and
; unsigned number on the 8086 platform without the need for a coprocessor.
; The macros listed before the "comming soon" section appear to be functioning
; properly. However, these are all highly experimental and much testing is still
; required. Functions below the "coming soon" section either do not exist or
; have not been finished. Those obviously will not work correctly, yet.

; Also, some unsigned macros (like uInt64_MOV) is identical to it's signed
; counterpart. This is for programmer convenience and permits using consistent
; u* or s* macros with specific numbers.

; Macro Functions

; Unsigned 64-bit integer function macros
; Ascii_uInt64		dest, address2 (convert from ascii to uInt64, CF overflow or error)
; uInt64_StdOutBin	address
; uInt64_StdOutHex	address
; uInt64_StdOutInt	address
; uInt64_Zero		address
; uInt64_Store		address (from DX:CX:BX:AX)
; uInt64_Load		address (into DX:CX:BX:AX)
; uInt64_PUSH		address (push uInt64 onto stack)
; uInt64_POP		address (pop uInt64 from stack)
; uInt64_MOV		dest, src
; uInt64_RCL		dest (CF for bit in/out)
; uInt64_RCR		dest (CF for bit in/out)
; uInt64_ROL		dest, bits
; uInt64_ROR		dest, bits
; uInt64_SHL		dest, bits  (CF if any bits were pushed off the end)
; uInt64_SHR		dest, bits  (CF if any bits were pushed off the end)
; uInt64_AND		dest, address2
; uInt64_XOR		dest, address2
; uInt64_OR		dest, address2
; uInt64_CMP		address1, address2 (then test flags, ie JA, JBE and etc)
; uInt64_INC		address, (CF if overflow)
; uInt64_DEC		address, (CF if underflow)
; uInt64_ADD		dest, address2 (result in dest, CF overflow)
; uInt64_SUB		dest, address2 (result in dest, CF underflow)
; uInt64_DIV		dest, address2 (result in dest, CF on error, DIV by 0)

; Signed versions identical to the Unsigned 64-bit versions
; sInt64_StdOutBin	address
; sInt64_StdOutHex	address
; sInt64_Zero		address
; sInt64_Store		address (from DX:CX:BX:AX)
; sInt64_Load		address (into DX:CX:BX:AX)
; sInt64_PUSH		address (push sInt64 onto stack)
; sInt64_POP		address (pop sInt64 from stack)
; sInt64_MOV		dest, src
; sInt64_RCL		dest (CF for bit in/out)
; sInt64_RCR		dest (CF for bit in/out)
; sInt64_ROL		dest, bits
; sInt64_ROR		dest, bits
; sInt64_SHL		dest, bits  (CF if any bits were pushed off the end)
; sInt64_SHR		dest, bits  (CF if any bits were pushed off the end)
; sInt64_ADD		dest, address2 (result in dest, CF overflow)
; sInt64_SUB		dest, address2 (result in dest, CF underflow)
; sInt64_DIV		dest, address2 (result in dest, CF on error, DIV by 0)


; Signed 64-bit integer function macros only. They are different from or do
; not have unsigned Int64 counterparts.
; Ascii_sInt64		dest, address2 (convert from ascii to sInt64, CF overflow or error)
; sInt64_StdOutInt	address
; sInt64_INC		address, (CF if overflow)
; sInt64_DEC		address, (CF if underflow)
; sInt64_ABS   		address, (CF if number was not positive)
; sInt64_NEG   		address, (CF if number was positive)

; coming soon, or at least someday eventually, maybe.
; uInt64_MUL		dest, address2 (result in dest, CF overflow)

; sInt64_CMP		address1, address2 (then test flags, ie JA, JBE and etc)
; sInt64_MUL		dest, address2 (result in dest, CF overflow)
; sInt64_DIV		dest, address2 (result in dest, CF overflow)

; -----------------------------------------------------------------------------
%idefine sInt64_StdOutBin	uInt64_StdOutBin
%idefine sInt64_StdOutHex 	uInt64_StdOutHex
%idefine sInt64_Zero		uInt64_Zero
%idefine sInt64_Store		uInt64_Store
%idefine sInt64_Load 		uInt64_Load
%idefine sInt64_PUSH 		uInt64_PUSH
%idefine sInt64_POP 		uInt64_POP
%idefine sInt64_MOV 		uInt64_MOV
%idefine sInt64_RCR 		uInt64_RCR
%idefine sInt64_RCL 		uInt64_RCL
%idefine sInt64_ROR 		uInt64_ROR
%idefine sInt64_ROL 		uInt64_ROL
%idefine sInt64_SHR 		uInt64_SHR
%idefine sInt64_SHL 		uInt64_SHL
%idefine sInt64_AND 		uInt64_AND
%idefine sInt64_XOR 		uInt64_XOR
%idefine sInt64_OR 		uInt64_OR
%idefine sInt64_ADD		uInt64_ADD	; Humm
%idefine sInt64_SUB		uInt64_SUB	; Humm

%imacro call_proc 1
	%define %1_REQUIRED
	call proc_%1
%endmacro

%imacro Int64_Store 1
    uInt64_Store %1
%endmacro

%imacro Int64_Load 1
    uInt64_Load %1
%endmacro

%imacro uInt64_StdOutBin 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call_proc uInt64_StdOutBin
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro uInt64_StdOutHex 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call_proc uInt64_StdOutHex
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro uInt64_StdOutInt 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call_proc uInt64_StdOutInt
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro uInt64_Zero 1
    %ifdef SAVE_REGS
        push di
    %endif
    mov  di, %1
    call_proc uInt64_Zero
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

%imacro uInt64_PUSH 1
    mov  ax, [%1 + 6]
    push ax
    mov  ax, [%1 + 4]
    push ax
    mov  ax, [%1 + 2]
    push ax
    mov  ax, [%1 + 0]
    push ax
%endmacro

%imacro uInt64_POP 1
    pop  ax
    mov  [%1], ax
    pop  ax
    mov  [%1 + 2], ax
    pop  ax
    mov  [%1 + 4], ax
    pop  ax
    mov  [%1 + 6], ax
%endmacro

%imacro uInt64_MOV 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call_proc uInt64_MOV
    %ifdef SAVE_REGS
        pop  si
        pop  di
    %endif
%endmacro

%imacro uInt64_RCR 1
    %ifdef SAVE_REGS
        push di
    %endif
    mov  di, %1
    call_proc uInt64_RCR
    %ifdef SAVE_REGS
        pop  di
    %endif
%endmacro

%imacro uInt64_RCL 1
    %ifdef SAVE_REGS
        push di
    %endif
    mov  di, %1
    call_proc uInt64_RCL
    %ifdef SAVE_REGS
        pop  di
    %endif
%endmacro

%imacro uInt64_ROR 2
    %ifdef SAVE_REGS
        push di
        push cx
    %endif
    mov  di, %1
    mov  cx, %2
    call_proc uInt64_ROR
    %ifdef SAVE_REGS
        pop  cx
        pop  di
    %endif
%endmacro

%imacro uInt64_ROL 2
    %ifdef SAVE_REGS
        push di
        push cx
    %endif
    mov  di, %1
    mov  cx, %2
    call_proc uInt64_ROL
    %ifdef SAVE_REGS
        pop  cx
        pop  di
    %endif
%endmacro

%imacro uInt64_SHR 2
    %ifdef SAVE_REGS
        push di
        push cx
    %endif
    mov  di, %1
    mov  cx, %2
    call_proc uInt64_SHR
    %ifdef SAVE_REGS
        pop  cx
        pop  di
    %endif
%endmacro

%imacro uInt64_SHL 2
    %ifdef SAVE_REGS
        push di
        push cx
    %endif
    mov  di, %1
    mov  cx, %2
    call_proc uInt64_SHL
    %ifdef SAVE_REGS
        pop  cx
        pop  di
    %endif
%endmacro

%imacro uInt64_AND 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call_proc uInt64_AND
    %ifdef SAVE_REGS
        pop  si
        pop  di
    %endif
%endmacro

%imacro uInt64_XOR 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call_proc uInt64_XOR
    %ifdef SAVE_REGS
        pop  si
        pop  di
    %endif
%endmacro

%imacro uInt64_OR 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call_proc uInt64_OR
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
    call_proc uInt64_CMP
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
    call_proc uInt64_ADD
    %ifdef SAVE_REGS
        pop  si
        pop  di
    %endif
%endmacro

%imacro uInt64_SUB 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call_proc uInt64_SUB
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
    call_proc uInt64_MUL_WORD
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
    call_proc uInt64_INC
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro uInt64_DEC 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call_proc uInt64_DEC
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro sInt64_INC 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call_proc sInt64_INC
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro sInt64_DEC 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call_proc sInt64_DEC
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro sInt64_ABS 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call_proc sInt64_ABS
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro sInt64_DIV 2
    %ifdef SAVE_REGS
    	push	ax
    	%ifnidni %1, di
    		push di
    	%endif
    	%ifnidni %2, si
	        push si
	%endif
    %endif

    %ifidni %2, di
    	push	di
    %endif
    %ifnidni %1, di
    	mov	di, %1
    %endif
    %ifnidni %2, si
    	mov	si, %2
    %endif
    %ifidni %2, di
    	pop	si
    %endif

    call_proc sInt64_DIV

    %ifdef SAVE_REGS
    	%ifnidni %2, si
	    	pop si
	%endif
    	%ifnidni %1, di
        	pop di
        %endif
        pop	ax
    %endif
%endmacro

%imacro sInt64_StdOutInt 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call_proc sInt64_StdOutInt
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro ASCII_sInt64 2
    %ifdef SAVE_REGS
        push si
        push di
    %endif
    %ifidni %2, di
	    mov  si, %2
	    mov	 di, %1
    %else
	    mov	 di, %1
	    mov  si, %2
    %endif
    call_proc	ASCII_sInt64
    %ifdef SAVE_REGS
        pop  di
        pop  si
    %endif
%endmacro

%imacro ASCII_uInt64 2
    %ifdef SAVE_REGS
        push si
        push di
    %endif
    %ifidni %2, di
	    mov  si, %2
	    mov	 di, %1
    %else
	    mov	 di, %1
	    mov  si, %2
    %endif
    call_proc	ASCII_uInt64
    %ifdef SAVE_REGS
        pop  di
        pop  si
    %endif
%endmacro


; Functions and procedures ----------------------------------------------------
%imacro Int64_procs 0
%rep 10

%ifdef uInt64_StdOutBin_REQUIRED
%ifndef uInt64_StdOutBin_DEFINED
%define uInt64_StdOutBin_DEFINED

proc_uInt64_StdOutBin:
    ; si address of Int64
    %ifdef SAVE_REGS
        pushf
        push        ax
        push	    cx
        push	    dx

    %endif
    mov             cx, 4   ; words in Int64
    add             si, 6   ; Offset to last word of Int64
.RepeatWord:
    mov             ax, [si]
    push            cx
    mov	 	    cx, 16
.RepeatBits:
    mov		    dl, '0'
    test	    ax, 0x8000
    jz		    .ZeroBit
    inc		    dl
.ZeroBit:
    push	    ax
    mov		    ah, 0x02
    int		    0x21
    pop		    ax
    shl		    ax, 1
.NoSpace:
    loop	    .RepeatBits
    pop             cx
    sub             si, 2
    ; uncomment to separate words with spaces
    ;push	    	ax
    ;mov		ah, 0x02
    ;mov		dl, 32
    ;int		0x21
    ;pop		ax
    loop            .RepeatWord
    %ifdef SAVE_REGS
    	pop	    dx
        pop	    cx
        pop         ax
        popf
    %endif
    ret
%endif
%endif

%ifdef uInt64_StdOutHex_REQUIRED
%ifndef uInt64_StdOutHex_DEFINED
%define uInt64_StdOutHex_DEFINED

proc_uInt64_StdOutHex:
    ; si address of Int64
    %ifdef SAVE_REGS
        pushf
        push        ax
        push	    cx
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
        pop  	    cx
        pop         ax
        popf
    %endif
    ret
%endif
%endif

%ifdef uInt64_StdOutInt_REQUIRED
%ifndef uInt64_StdOutInt_DEFINED
%define uInt64_StdOutInt_DEFINED

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

%endif
%endif

%ifdef uInt64_Zero_REQUIRED
%ifndef uInt64_Zero_DEFINED
%define uInt64_Zero_DEFINED
proc_uInt64_Zero:
    ; di address of Int64
    %ifdef SAVE_REGS
        push ax
    %endif
    xor  ax, ax
    mov	 [di], ax
    mov  [di+2],ax
    mov  [di+4],ax
    mov  [di+6],ax
    %ifdef SAVE_REGS
        pop  ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_MOV_REQUIRED
%ifndef uInt64_MOV_DEFINED
%define uInt64_MOV_DEFINED

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
%endif
%endif

%ifdef uInt64_RCL_REQUIRED
%ifndef uInt64_RCL_DEFINED
%define uInt64_RCL_DEFINED

proc_uInt64_RCL:
    ; di destination Int64
    %ifdef SAVE_REGS
        push ax
    %endif
    mov  ax, [di]
    rcl  ax, 1
    mov	 [di], ax
    mov  ax, [di + 2]
    rcl  ax, 1
    mov	 [di + 2], ax
    mov  ax, [di + 4]
    rcl  ax, 1
    mov	 [di + 4], ax
    mov  ax, [di + 6]
    rcl  ax, 1
    mov	 [di + 6], ax
    %ifdef SAVE_REGS
        pop ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_RCR_REQUIRED
%ifndef uInt64_RCR_DEFINED
%define uInt64_RCR_DEFINED

proc_uInt64_RCR:
    ; di destination Int64
    %ifdef SAVE_REGS
        push ax
    %endif
    mov  ax, [di + 6]
    rcr  ax, 1
    mov	 [di + 6], ax
    mov  ax, [di + 4]
    rcr  ax, 1
    mov	 [di + 4], ax
    mov  ax, [di + 2]
    rcr  ax, 1
    mov	 [di + 2], ax
    mov  ax, [di]
    rcr  ax, 1
    mov	 [di], ax
    %ifdef SAVE_REGS
        pop ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_ROL_REQUIRED
%ifndef uInt64_ROL_DEFINED
%define uInt64_ROL_DEFINED

proc_uInt64_ROL:
    ; di destination Int64
    ; cx is bits to rotate
    %ifdef SAVE_REGS
        push ax
        push cx
    %endif
.ShiftLoop:
    cmp  cx, 0
    jz   .DoneShift
    clc
    call_proc uInt64_RCL
    jnc   .NoRolledBit
    mov   ax, 1
    or    [di], ax
.NoRolledBit:
    dec  cx
    jmp  .ShiftLoop
.DoneShift:
    %ifdef SAVE_REGS
        pop cx
        pop ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_ROR_REQUIRED
%ifndef uInt64_ROR_DEFINED
%define uInt64_ROR_DEFINED

proc_uInt64_ROR:
    ; di destination Int64
    ; cx is bits to rotate
    %ifdef SAVE_REGS
        push ax
        push cx
    %endif
.ShiftLoop:
    cmp  cx, 0
    jz   .DoneShift
    clc
    call_proc uInt64_RCR
    jnc   .NoRolledBit
    mov   ax, 0x8000
    or    [di + 6], ax
.NoRolledBit:
    dec  cx
    jmp  .ShiftLoop
.DoneShift:
    %ifdef SAVE_REGS
        pop cx
        pop ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_SHL_REQUIRED
%ifndef uInt64_SHL_DEFINED
%define uInt64_SHL_DEFINED

proc_uInt64_SHL:
    ; di destination Int64
    ; cx is bits to rotate
    %ifdef SAVE_REGS
        push ax
        push cx
        push dx
    %endif
    xor  dl, dl
.ShiftLoop:
    cmp  cx, 0
    jz   .DoneShift
    clc
    call_proc uInt64_RCL
    jnc   .NoLostBit
    or	  dl, 1
.NoLostBit:
    dec   cx
    jmp  .ShiftLoop
.DoneShift:
    clc
    test  dl, dl
    jz    .NoLoss
    stc
.NoLoss:
    %ifdef SAVE_REGS
        pop dx
        pop cx
        pop ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_SHR_REQUIRED
%ifndef uInt64_SHR_DEFINED
%define uInt64_SHR_DEFINED

proc_uInt64_SHR:
    ; di destination Int64
    ; cx is bits to rotate
    %ifdef SAVE_REGS
        push ax
        push cx
        push dx
    %endif
    xor  dl, dl
.ShiftLoop:
    cmp  cx, 0
    jz   .DoneShift
    clc
    call_proc uInt64_RCR
    jnc   .NoLostBit
    or	  dl, 1
.NoLostBit:
    dec   cx
    jmp  .ShiftLoop
.DoneShift:
    clc
    test  dl, dl
    jz    .NoLoss
    stc
.NoLoss:
    %ifdef SAVE_REGS
        pop dx
        pop cx
        pop ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_AND_REQUIRED
%ifndef uInt64_AND_DEFINED
%define uInt64_AND_DEFINED

proc_uInt64_AND:
    ; di destination Int64
    ; si source Int64
    %ifdef SAVE_REGS
        push ax
    %endif
    mov  ax, [si]
    and	 [di], ax
    mov  ax, [si + 2]
    and	 [di + 2], ax
    mov  ax, [si + 4]
    and	 [di + 4], ax
    mov  ax, [si + 6]
    and	 [di + 6], ax
    %ifdef SAVE_REGS
        pop ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_XOR_REQUIRED
%ifndef uInt64_XOR_DEFINED
%define uInt64_XOR_DEFINED

proc_uInt64_XOR:
    ; di destination Int64
    ; si source Int64
    %ifdef SAVE_REGS
        push ax
    %endif
    mov  ax, [si]
    xor	 [di], ax
    mov  ax, [si + 2]
    xor	 [di + 2], ax
    mov  ax, [si + 4]
    xor	 [di + 4], ax
    mov  ax, [si + 6]
    xor	 [di + 6], ax
    %ifdef SAVE_REGS
        pop ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_OR_REQUIRED
%ifndef uInt64_OR_DEFINED
%define uInt64_OR_DEFINED

proc_uInt64_OR:
    ; di destination Int64
    ; si source Int64
    %ifdef SAVE_REGS
        push ax
    %endif
    mov  ax, [si]
    or	 [di], ax
    mov  ax, [si + 2]
    or	 [di + 2], ax
    mov  ax, [si + 4]
    or	 [di + 4], ax
    mov  ax, [si + 6]
    or	 [di + 6], ax
    %ifdef SAVE_REGS
        pop ax
    %endif
    ret
%endif
%endif

%ifdef uInt64_CMP_REQUIRED
%ifndef uInt64_CMP_DEFINED
%define uInt64_CMP_DEFINED

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

%endif
%endif


%ifdef uInt64_ADD_REQUIRED
%ifndef uInt64_ADD_DEFINED
%define uInt64_ADD_DEFINED
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
%endif
%endif


%ifdef uInt64_SUB_REQUIRED
%ifndef uInt64_SUB_DEFINED
%define uInt64_SUB_DEFINED

proc_uInt64_SUB:
    ; di first Int64
    ; si second Int64
    %ifdef SAVE_REGS
        push ax
        push bx
        push cx
        push dx
    %endif
    xor  bx, bx
    mov  cx, 4          ; Words in Int64
    xor  dx, dx
.Repeat:
    test    dx, dx
    jz	    .NoBorrowNow
    call    .Borrow
.NoBorrowNow:
    mov     ax, [di + bx]
    sub     ax, [si + bx]
    cmp     ax, [di + bx]
    jbe	    .NoBorrowNext
    inc	    dx
.NoBorrowNext:
    mov     [di + bx], ax
    add     bx, 2
    loop    .Repeat
    clc
    test    dx, dx
    jz	    .Done
    stc
.Done:
    %ifdef SAVE_REGS
    	pop  dx
        pop  cx
        pop  bx
        pop  ax
    %endif
    ; Carry Flag on Underflow.
    ret
.Borrow:
    push    bx
    push    cx
.BorrowAgain:
    mov     ax, [di + bx]
    dec	    ax
    mov	    [di+bx], ax
    cmp     ax, 0xffff
    jne     .BorrowDone
    add	    bx, 2
    loop    .BorrowAgain
.BorrowDone:
    xor	    dx, dx
.BorrowFail:
    pop     cx
    pop     bx
    ret

%endif
%endif

%ifdef uInt64_MUL_WORD_REQUIRED
%ifndef uInt64_MUL_WORD_DEFINED
%define uInt64_MUL_WORD_DEFINED
proc_uInt64_MUL_WORD:
    ; di address of Int64
    ; bx multiplication factor
    %ifdef SAVE_REGS
        push    ax
        push    cx
        push    dx
        push    si
        push	di
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
    	pop	di
        pop     si
        pop     dx
        pop     cx
        pop     ax
    %endif
    ; Carry Flag on Overflow.
    ret
%endif
%endif


%ifdef uInt64_INC_REQUIRED
%ifndef uInt64_INC_DEFINED
%define uInt64_INC_DEFINED
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
%endif
%endif

%ifdef uInt64_DEC_REQUIRED
%ifndef uInt64_DEC_DEFINED
%define uInt64_DEC_DEFINED
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
%endif
%endif

%ifdef sInt64_INC_REQUIRED
%ifndef sInt64_INC_DEFINED
%define sInt64_INC_DEFINED
proc_sInt64_INC:
    %ifdef SAVE_REGS
	push	ax
	push    bx
    %endif
	mov	ax, [si+6]
	and	ax, 0x8000
	call_proc 	uInt64_INC
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

%endif
%endif

%ifdef sInt64_DEC_REQUIRED
%ifndef sInt64_DEC_DEFINED
%define sInt64_DEC_DEFINED
proc_sInt64_DEC:
    %ifdef SAVE_REGS
	push	ax
	push    bx
    %endif
	mov	ax, [si+6]
	and	ax, 0x8000
	call_proc	uInt64_DEC
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

%endif
%endif

%ifdef sInt64_ABS_REQUIRED
%ifndef sInt64_ABS_DEFINED
%define sInt64_ABS_DEFINED
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
    call_proc	uInt64_INC
    stc
    jmp		.Done
.Positive:
    clc
.Done:
    pop		ax
    ret

%endif
%endif

%ifdef sInt64_NEG_REQUIRED
%ifndef sInt64_NEG_DEFINED
%define sInt64_NEG_DEFINED
proc_sInt64_NEG:
    ; si address destination/source Int64
    push	ax
    mov		ax, [si+6]
    test	ax, 0x8000
    jnz		.Negative
    not		word [si+6]
    not		word [si+4]
    not		word [si+2]
    not		word [si]
    call_proc	uInt64_INC	; maybe DEC instead, need to test more
    stc
    jmp		.Done
.Negative:
    clc
.Done:
    pop		ax
    ret

%endif
%endif

%ifdef sInt64_DIV_REQUIRED
%ifndef sInt64_DIV_DEFINED
%define sInt64_DIV_DEFINED

proc_sInt64_DIV:
    ; this could be streamlined and consolidated a lot.


    ; si address source Int64 divisor; si out is remainder
    ; di address source Int64 dividend; di out is quotient
    %ifdef SAVE_REGS
	push    ax
    %endif
    push	bp
    mov		bp, sp

    ; save positive/negative result flag
    mov		ax, [di+6]
    xor		ax, [si+6]
    push	ax	; bp - 2 = result +/- flag

    ; convert numbers to positive if needed
    push	di
    push	si
    call_proc   sInt64_ABS
    mov         si, di
    call_proc   sInt64_ABS
    pop		si
    pop		di

    ; test DIV by zero error
    mov		ax, [si]
    or		ax, [si + 2]
    or		ax, [si + 4]
    or 		ax, [si + 6]
    test	ax, ax
    jz		.ErrorResult

    ; shift divisor to left most position
    xor		cx, cx
.ShiftDivLeft:
    test	word [si+6], 0x8000
    jnz		.ShiftDivLeftDone
    clc
    rcl		word [si], 1
    rcl		word [si + 2], 1
    rcl		word [si + 4], 1
    rcl		word [si + 6], 1
    inc		cx
    jmp		.ShiftDivLeft
.ShiftDivLeftDone:
    %idefine    Int64_DIVSUB si

    sInt64_PUSH	di ; put remainder on stack at bp - 10
    %idefine    Int64_DIVREM  ss:bp-10

    ; prepare addition bit value
    call_proc   sInt64_Zero
    mov		word [di], 1
    push	cx
    sInt64_SHL  di, cx
    pop		cx
    sInt64_PUSH	di ; put addition bits on stack at bp - 18
    %idefine  Int64_DIVADD  ss:bp-18

    ; clear result value
    call_proc   sInt64_Zero
    %idefine    Int64_DIVRES di

    inc		cx
.DivLoop:
    push	cx

    call	.Compare_REMSUB
    jb		.IsLessThan

    call	.ValueFits

    ; Is Less Than remainder, proceed to next bit
.IsLessThan:
    call	.ShiftValsRight
    pop		cx
    loop	.DivLoop

    mov		ax, [Int64_DIVREM + 6]
    mov		[si + 6], ax
    mov		ax, [Int64_DIVREM + 4]
    mov		[si + 4], ax
    mov		ax, [Int64_DIVREM + 2]
    mov		[si + 2], ax
    mov		ax, [Int64_DIVREM]
    mov		[si], ax


    ; check flag to see if result is negative
    mov		ax, [ss:bp-2]
    test	ax, 0x8000	; either (but not both) are negative
    jz		.PositiveResult
    xchg	di, si
    call_proc	sInt64_NEG
    xchg	di, si
    jmp		.PositiveResult
.ErrorResult:
    stc
    jmp		.DivDone
.PositiveResult:
    clc
.DivDone:
    ; discard remaining data on stack
    mov		sp, bp
    pop		bp
    %ifdef SAVE_REGS
	pop    ax
    %endif
    ret

.ShiftValsRight:
    clc
    rcr		word [Int64_DIVSUB + 6], 1
    rcr		word [Int64_DIVSUB + 4], 1
    rcr		word [Int64_DIVSUB + 2], 1
    rcr		word [Int64_DIVSUB], 1
    clc
    rcr		word [Int64_DIVADD + 6], 1
    rcr		word [Int64_DIVADD + 4], 1
    rcr		word [Int64_DIVADD + 2], 1
    rcr		word [Int64_DIVADD], 1
    ret

.Compare_REMSUB:
    mov		ax, [Int64_DIVREM + 6]
    cmp		ax, [si + 6]
    jne		.Compare_REMSUB_DONE
    mov		ax, [Int64_DIVREM + 4]
    cmp		ax, [si + 4]
    jne		.Compare_REMSUB_DONE
    mov		ax, [Int64_DIVREM + 2]
    cmp		ax, [si + 2]
    jne		.Compare_REMSUB_DONE
    mov		ax, [Int64_DIVREM]
    cmp		ax, [si]
    jne		.Compare_REMSUB_DONE
.Compare_REMSUB_DONE:
    ret

.ValueFits:
    ; add bit value to result
    clc
    mov		ax, [Int64_DIVADD]
    adc		[di], ax
    mov		ax, [Int64_DIVADD + 2]
    adc		[di + 2], ax
    mov		ax, [Int64_DIVADD + 4]
    adc		[di + 4], ax
    mov		ax, [Int64_DIVADD + 6]
    adc		[di + 6], ax
    ; reduce remainder by SUB value
    push	di
    mov		di, bp
    sub 	di, 10
    xor  bx, bx
    mov  cx, 4          ; Words in Int64
    xor  dx, dx
.SubRepeat:
    test    dx, dx
    jz	    .NoBorrowNow
    call    .SubBorrow
.NoBorrowNow:
    mov     ax, [ss:di + bx]
    sub     ax, [Int64_DIVSUB + bx]
    cmp     ax, [ss:di + bx]
    jbe	    .NoBorrowNext
    inc	    dx
.NoBorrowNext:
    mov     [di + bx], ax
    add     bx, 2
    loop    .SubRepeat
    clc
    test    dx, dx
    jz	    .SubDone
    stc
.SubDone:
    pop	     di
    ret
.SubBorrow:
    push    bx
    push    cx
.BorrowAgain:
    mov     ax, [ss:di + bx]
    dec	    ax
    mov	    [ss:di + bx], ax
    cmp     ax, 0xffff
    jne     .BorrowDone
    add	    bx, 2
    loop    .BorrowAgain
.BorrowDone:
    xor	    dx, dx
.BorrowFail:
    pop     cx
    pop     bx
    ret


%endif
%endif

%ifdef sInt64_StdOutInt_REQUIRED
%ifndef sInt64_StdOutInt_DEFINED
%define sInt64_StdOutInt_DEFINED
proc_sInt64_StdOutInt:
    ; si address destination/source Int64
    %ifdef SAVE_REGS
	push    di
    %endif
    push	bp
    mov		bp, sp
    sub		sp, 8
    mov  	di, sp
    call_proc	uInt64_MOV
    mov		si, di
    call_proc	sInt64_ABS
    jnc		.NotNegative
    StdOutChar  '-'
.NotNegative:
    call_proc	uInt64_StdOutInt
    mov		sp, bp
    pop		bp
    %ifdef SAVE_REGS
        pop	di
    %endif
    ret

%endif
%endif

%ifdef ASCII_uInt64_REQUIRED
%ifndef ASCII_uInt64_DEFINED
%define ASCII_uInt64_DEFINED
%define ASCII_sInt64_REQUIRED
proc_ASCII_uInt64:
    ; for now not going to worry about it.

%endif
%endif

%ifdef ASCII_sInt64_REQUIRED
%ifndef ASCII_sInt64_DEFINED
%define ASCII_sInt64_DEFINED
proc_ASCII_sInt64:
    ; si address source ASCII text
    ; di address destination Int64
    call_proc	uInt64_Zero
    %ifdef SAVE_REGS
	push		di
	push		si
	push		bx
	push		dx
	push		ax
    %endif

    xor		dx, dx
    mov		ax, [si]
    cmp		al, '-'
    jne		.NotNeg
    or 		dl, 1 		; negative flag
    inc		si
    mov 	ax, [si]
.NotNeg:
    cmp		al, '0'
    jne		.NotHex
    cmp		ah, 'x'
    je		.IsHex
    cmp		ah, 'X'
    jne		.NotHex
.IsHex:
    inc		si		; 'add si, 2' is 1 byte more then 2x 'inc si'
    inc		si
    or		dl, 2		; hex flag
    jmp		.NotHex
.NotHex:

    cld
.ConvertLoop:
    lodsb
    cmp		al, '0'
    jb		.BadAscii
    cmp		al, '9'
    jna		.HaveDigit
    test	dl, 2
    jz		.HaveDigit
    cmp		al, 'a'
    jb		.NotLower
    cmp		al, 'f'
    ja		.NotLower
    sub		al, 0x20	; make upper case
.NotLower:
    cmp		al, 'A'
    jb		.BadAscii
    cmp		al, 'F'
    ja		.BadAscii
    sub         al, 0x07	; shift value down to top of numbers
.HaveDigit:
    xor		ah, ah
    sub		al, 0x30
    cmp		al, 0xf
    ja		.BadAscii
    mov		bx, 10
    test	dl, 2
    jz		.ShiftNum
    mov		bx, 0x10
.ShiftNum:
    %ifndef SAVE_REGS
        push    ax
        push    dx
        push    si
        push	di
    %endif
    call_proc	uInt64_MUL_WORD
    %ifndef SAVE_REGS
        pop    di
        pop    si
        pop    dx
        pop    ax
    %endif
    jc		.MathError
    adc		[di], ax
    adc		[di + 2], word 0
    adc		[di + 4], word 0
    adc		[di + 6], word 0
    jc		.MathError

    ; should test highest bit for overflow. when using signed numbers.
    jmp		.ConvertLoop

.BadAscii:
    cmp		al, 0
    je		.EndNumber
    cmp		al, 32
    je		.EndNumber
    cmp		al, 13
    je		.EndNumber
    jmp		.MathError
.EndNumber:
    test	dl, 1
    jz		.DontMakeNeg
    xchg	si, di
    call_proc	sInt64_NEG
    xchg	si, di

.DontMakeNeg:
    clc
    jmp		.Done

.MathError:
;    call 	proc_uInt64_Zero
    stc
.Done:
    %ifdef SAVE_REGS
    	pop		ax
    	pop		dx
    	pop		bx
    	pop		si
	pop		di
    %endif
    ret
%endif
%endif

%endrep

%endmacro
