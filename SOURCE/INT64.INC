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

; Int64_StdOutHex   address
; Int64_Zero        address
; Int64_Store       address (from DX:CX:BX:AX)
; Int64_Load        address (into DX:CX:BX:AX)
; Int64_CMP         address1, address2 (test flags, ie JG, JLE and etc)
; Int64_ADD         address1, address2 (result in address1, CF overflow)

%imacro Int64_StdOutHex 1
    %ifdef SAVE_REGS
        push si
    %endif
    mov  si, %1
    call proc_Int64_StdOutHex
    %ifdef SAVE_REGS
        pop  si
    %endif
%endmacro

%imacro Int64_Zero 1
    %ifdef SAVE_REGS
        push di
    %endif
    mov  di, %1
    call proc_Int64_Zero
    %ifdef SAVE_REGS
        pop  di
    %endif
%endmacro

%imacro Int64_Store 1
    mov  [%1], ax
    mov  [%1 + 2], bx
    mov  [%1 + 4], cx
    mov  [%1 + 6], dx
%endmacro

%imacro Int64_Load 1
    mov  ax, [%1]
    mov  bx, [%1 + 2]
    mov  cx, [%1 + 4]
    mov  dx, [%1 + 6]
%endmacro

proc_Int64_CMP:
    %ifdef SAVE_REGS
        push ax
        push bx
        push cx
    %endif
    mov  bx, 8              ; Int64 Size in bytes
.Repeat:
    sub  bx, 2
    mov  ax, [di]
    mov  cx, [si]
    cmp  ax, cx
    jne  .Done              ; JNE and preserve flags
    cmp  bx, 0              ; test if done
    jne  .Repeat
                            ; 0 and Int64's equal
.Done:
    %ifdef SAVE_REGS
        pop  cx
        pop  bx
        pop  ax
    %endif
    ret

%imacro Int64_CMP 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call proc_Int64_ADD
    %ifdef SAVE_REGS
        pop  si
        pop  di
    %endif
%endmacro

%imacro Int64_ADD 2
    %ifdef SAVE_REGS
        push di
        push si
    %endif
    mov  di, %1
    mov  si, %2
    call proc_Int64_ADD
    %ifdef SAVE_REGS
        pop  si
        pop  di
    %endif
%endmacro

proc_Int64_StdOutHex:
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
    ; StdOutChar ' '
    pop             cx
    sub             si, 2
    loop            .Repeat
    %ifdef SAVE_REGS
        pop         ax
        popf
    %endif
    ret

proc_Int64_Zero:
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

proc_Int64_ADD:
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
