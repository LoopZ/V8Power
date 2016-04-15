
; Copyright (C) 2016 Jerome Shidel
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

; NASM for DOS

%imacro CheckDOSBOX 0
    pushf
    push        es
    push        di
    push        si
    push        cx
    push        bx

    mov         bx, 0xfe03
    mov         es, bx
    mov         si, 0x0000
    mov         cx, 0x0010
    mov         di, %%DOSBOX
    xor         bx, bx
    clc
    mov         ah, 0x02
%%Checking:
    mov         al, [es:si]
    mov         ah, [cs:di]
    xor         al, ah
    or          bl, al
    inc         si
    inc         di
    loop        %%Checking
    cmp         bl, 0x00
    jne         %%NotDOSBOX
    mov         ax, 0x0001
    jmp         %%Done
%%NotDOSBOX:
    xor         ax, ax
    jmp         %%Done

%%DOSBOX:
    db          'The DOSBox Team.'
%%Done:
    pop         bx
    pop         cx
    pop         si
    pop         di
    pop         es
    popf
%endmacro

%imacro MachineStatus 0

    CheckDOSBOX
    cmp         al, 0
    je          %%NotDOSBOX
    mov         al, 101
    jmp         %%Done

%%NotDOSBOX:
    ; Test Pre-186, CL is AND with 0x0f prior to/during shr
    mov         cl, 0x20
    mov         ax, 0x0001
    shr         ax, cl
    cmp         ax, 0x0000
    jne         %%186OrBetter
    xor         al, al
    jmp         %%Done
%%186OrBetter:
    ; At least a 80186
    ; Pre-286 updates the Stack Pointer before push
    mov         ax, sp
    push        sp
    pop         bx
    cmp         ax, bx
    je          %%286OrBetter
    mov         ax, 1
    jmp         %%Done
%%286OrBetter:
    ; At least a 286
    ; Check push/pop of upper flag bits for 386 or better
    pushf
    mov         ax, 0x7000
    push        ax
    popf
    pushf
    pop         ax
    popf
    and         ah, 0x70
    cmp         ah, 0x70
    je          %%386OrBetter
    mov         al, 2
    jmp         %%Done
%%386OrBetter:
    ; At least a 386
    ; Test setting AC Flag
cpu 386

    mov         bx, sp
    and         sp, 0xfffc


    pushfd
    pushfd
    pop         eax
    or          eax, 0x40000
    push        eax
    popfd
    pushfd
    pop         eax
    popfd
    mov         sp, bx
    test        eax, 0x40000

    jnz         %%486OrBetter

    mov         al, 3
    jmp         %%Done32
%%486OrBetter:

cpu 486
    ; At least a 486
    ; Test setting ID Flag Bit

    mov         ecx, 1
    shl         ecx, 21
    pushfd
    pushfd
    pop         eax
    mov         ebx, eax
    xor         eax, ecx
    push        eax
    popfd
    pushfd
    pop         eax
    popfd
    and         eax, ecx
    and         ebx, ecx
    cmp         eax, ebx
    jne         %%UseCPUid
    mov         al, 4
    jmp         %%Done32

%%UseCPUid:

cpu 586
    mov         eax, 1
    cpuid
    shr         ax, 0x08
    and         ax, 0x0f

%%Done32:

cpu 8086
use16

%%Done:
%endmacro

%imacro MachineStatusMessage 1
    mov         al, %1
    mov         bx, %%Messages
%%ScanLoop:
    mov         ah, [bx]
    inc         bx
    cmp         al, ah
    je          %%Found
    cmp         ah, 0
    je          %%NotFound
%%ScanNext:
    mov         ah, [bx]
    inc         bx
    cmp         ah, 0
    jne         %%ScanNext
    jmp         %%ScanLoop

%%Found:
    WriteStr    bx
%%NotFound:
    WriteStr    %%MsgCRLF
    jmp         %%Done
%%MsgCRLF:
    db CRLF,0
%%Messages:
    db 1, '80186',0
    db 2, '80286',0
    db 3, '80386',0
    db 4, '80486',0
    db 5, '80586',0
    db 6, '80686',0
    db 101,'DOSBox',0
    db 0,'8086',0
%%Done:

%endmacro

