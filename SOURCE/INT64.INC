; Copyright (C) 2020 Jerome Shidel
;
;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation; either version 2 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License along
;   with this program; if not, write to the Free Software Foundation, Inc.,
;   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

; NASM 2.14rc0 for DOS

; Undefine if you need to save a couple bytes and don't care about trashed
; registers.
%idefine SAVE_REGS

; Macro Functions

; Signed 64-bit integer function macros
; Int64_StdOutHex   address

; Unsigned 64-bit integer function macros
; uInt64_StdOutHex   address
; uInt64_Zero        address
; uInt64_Store       address (from DX:CX:BX:AX)
; uInt64_Load        address (into DX:CX:BX:AX)
; uInt64_CMP         address1, address2 (test flags, ie JA, JBE and etc)
; uInt64_ADD         address1, address2 (result in address1, CF overflow)

%imacro Int64_StdOutHex 1
    uInt64_StdOutHex %1
%endmacro

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

proc_uInt64_CMP:
    ; di first Int64
    ; si second Int64
    %ifdef SAVE_REGS
        push ax
        push bx
        push cx
    %endif
    mov  bx, 8              ; Int64 Size in bytes
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
