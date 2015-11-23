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

%imacro GetStdIn 0
    StdIn
    jnc     %%Done
    pushf
    call InputFilter
    popf
%%Done:
%endmacro

PassThrough:
    GetStdIn
    jnc     NoInput
    StdOutChar al
    jmp     PassThrough
NoInput:
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

SwitchS:
    mov         al, 0x01
    mov         [NextReplace], al
    mov         [SearchFor], di
    xor         al, al
    mov         [si], al
    ret

SwitchReplace:
    xor         al, al
    mov         [NextReplace], al
    mov         [ReplaceWith], di
    mov         [si], al
    mov         [ReplaceWith], di
    mov         si, [SearchFor]
    xor         cx, cx
.Looping:
    push        cx
    GetStdIn
    pop         cx
    pushf
    mov         dl, al
    mov         al, [si]
    cmp         al, dl
    jne         .Missmatch
    inc         cx
    inc         si
    mov         al, [si]
    cmp         al, 0x00
    je          .ReplaceIt
    popf
    jmp         .Looping
.Missmatch:
    push        dx
    cmp         cx, 0
    je          .NoBuffered
    mov         si, [SearchFor]
.BufferedOut:
    lodsb
    mov         dl, al
    StdOutChar
    loop        .BufferedOut
.NoBuffered:
    pop         dx
    popf
    jnc         .Done
    StdOutChar
.Continued:
    xor         cx, cx
    mov         si, [SearchFor]
    jmp         .Looping
.ReplaceIt:
    StdOutStr   [ReplaceWith]
    popf
    jnc         .Done
    jmp         .Continued
.Done:
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
    GetStdIn
    pop         bx
    jnc         .Done
    cmp         al, 0x0d
    jne         .Looping
    dec         bx
    cmp         bx, 0
    je          .ThisLine
    jmp         .Looping
.ThisLine:
    GetStdIn
    jnc          .Done
    cmp         al, 0x0a
    je          .ThisLine
    cmp         al, 0x0d
    je          .Done
    mov         dl, al
    StdOutChar
    jmp         .ThisLine
.Done:
    GetStdIn
    jc          .Done
    ret

TotalLines:
    xor         bx, bx
    xor         dx, dx
.Looping:
    push        dx
    push        bx
    GetStdIn
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

SwitchU:
    mov         al, [Filter]
    or          al, 00000001b
    mov         [Filter], al
    ret

SwitchD:
    mov         al, [Filter]
    or          al, 00000010b
    mov         [Filter], al
    ret

InputFilter:
    mov     dh, [Filter]
    cmp     dh, 0
    je      .Done
    xor     ah, ah
    test    dh, 00000001b
    jz      .NotUppercase
    cmp     ax, 0x61
    jl      .NotUppercase
    cmp     ax, 0x7a
    jg      .NotUppercase
    sub     ax, 0x20
.NotUppercase:
    test    dh, 00000010b
    jz      .NotLowercase
    cmp     ax, 0x41
    jl      .NotLowercase
    cmp     ax, 0x5a
    jg      .NotLowercase
    add     ax, 0x20
.NotLowercase:

.Done:
    ret

HelpSwitchHandler

NoSwitch:
    mov         al, [NextReplace]
    cmp         al, 0x01
    je          SwitchReplace
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
    SwitchData  'S', 1, SwitchS
    SwitchData  'U', 0, SwitchU
    SwitchData  'D', 0, SwitchD
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
    TableEnd

OptionsLines:
    TableData "TOTAL", TotalLines
    TableEnd

NextReplace:
    db 0
SearchFor:
    dw 0
ReplaceWith:
    dw 0
Repeat:
    dw 1
NoNewLine:
    db 0
Filter:
    db 0