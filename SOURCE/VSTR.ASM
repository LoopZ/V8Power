; Copyright (C) 2015 Jerome Shidel
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

%idefine NoVideoOutput

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

    mov al, [NoNewLine]
    cmp al, 1
    je  Done
    StdOutCRLF
Done:
    Terminate 0

SwitchN:
    mov         al, 1
    mov         [NoNewLine], al
    ret

SwitchC:
    NumberParam
    mov     cx, [Repeat]
.SwitchLoop:
    push    cx
    push    ax
    StdOutChar al
    pop     ax
    pop     cx
    loop    .SwitchLoop
    inc     cx
    mov     [Repeat], cx
    ret

SwitchR:
    NumberParam
    mov         [Repeat], ax
    ret

TotalLines:
    xor         bx, bx
    xor         dx, dx
.Looping:
    push        dx
    push        bx
    StdIn
    pop         bx
    pop         dx
    jnc         .EndOfStdIn
    cmp         al, 0x0a
    je          .Looping
    cmp         al, 0x0d
    je          .NewLine
    inc         dx
    jmp         .Looping
.NewLine:
    xor         dx, dx
    inc         bx
    jmp         .Looping
.EndOfStdIn:
    cmp         dx, 0
    je          .Done
    inc         bx
.Done:
    mov         ax, bx
    StdOutIntWord
    ret

SwitchL:
    LookupParam OptionsLines
    cmp         ax, 0xffff
    je          .NotOption
    jmp         ax

.NotOption:
    NumberParam
    mov         bx, ax
    cmp         bx, 0
    je          .ThisLine
.Looping:
    push        bx
    StdIn
    pop         bx
    jnc         .Done
    cmp         al, 0x0d
    jne         .Looping
    dec         bx
    cmp         bx, 0
    je          .ThisLine
    jmp         .Looping
.ThisLine:
    StdIn
    jnc          .Done
    cmp         al, 0x0a
    je          .ThisLine
    cmp         al, 0x0d
    je          .Done
    mov         dl, al
    StdOutChar
    jmp         .ThisLine
.Done:
    StdIn
    jc          .Done
    ret

HelpSwitchHandler

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    jmp         ax

.NotOption:
    NumberParam
    ; do something with ax

.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'N', 0, SwitchN
    SwitchData  'C', 1, SwitchC
    SwitchData  'R', 1, SwitchR
    SwitchData  'L', 1, SwitchL
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
    TableEnd

OptionsLines:
    TableData "TOTAL", TotalLines
    TableEnd

Repeat:
    dw 1
NoNewLine:
    db 0