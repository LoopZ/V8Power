
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
    je          %%Unknown
    mov         al, 101
    jmp         %%Done
%%Unknown:
    xor         al, al
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
    db 101,'DOSBox',0
    db 0,'Unknown',0
%%Done:

%endmacro

