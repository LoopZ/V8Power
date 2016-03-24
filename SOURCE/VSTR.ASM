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

%idefine NoVideoOutput
%idefine StdOutAllChars

%include "COMMON.INC"

%imacro GetStdIn 0
%%Sticky:
    StdIn
    jnc     %%Done
    call    InputFilter
    jnc     %%Sticky
%%Done:
%endmacro

%imacro NextSpecial 1
    push    ax
    mov     ax, %1
    mov     [MultiOptionSwitch], ax
    pop     ax
%endmacro

    CommandLineParser       ; insert code for command line parsing

    UseAdvancedStdIn

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
    NextSpecial SwitchReplace
    mov         [SearchFor], di
    xor         al, al
    mov         [si], al
    ret

SwitchReplace:
    xor         al, al
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

SwitchF:
    NextSpecial SwitchFields
    mov         [SearchFor], di
    xor         al, al
    mov         [si], al
    ret

SwitchT:
    mov         ax, TabSearch
    mov         [SearchFor], ax

SwitchFields:
    push        cx
    push        di
    mov         bx, di
.FindDash:
    cmp         cx, 0
    je          .FindEnd
    mov         al, [bx]
    cmp         al, '-'
    je          .FindEnd
    inc         bx
    loop        .FindDash
    jmp         .NoDash
.FindEnd:
    cmp         cx, 0x0001
    je          .NoHighNumber
    dec         cx
    push        di
    mov         di, bx
    inc         di
    push        bx
    NumberParam
    pop         bx
    pop         di
    mov         [Fields + 2], ax
.NoHighNumber:
    cmp         bx, di
    je          .NoLowNumber
    sub         bx, di
    mov         cx, bx
    NumberParam
    mov         [Fields], ax
.NoLowNumber:
    pop         di
    pop         cx
    jmp         .Process
.NoDash:
    pop         di
    pop         cx
    NumberParam
    mov         [Fields], ax
    mov         [Fields + 2], ax
.Process:
    mov         si, [SearchFor]
    xor         cx, cx
    mov         ax, 0x0001
    mov         [FieldPos], ax
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
    je          .FieldIDMatch
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
    call        .MaybeCharOut
    loop        .BufferedOut
.NoBuffered:
    pop         dx
    popf
    jnc         .Done
    call        .MaybeCharOut
.Continued:
    xor         cx, cx
    mov         si, [SearchFor]
    jmp         .Looping
.MaybeCharOut:
    cmp         dl, 0x0d
    je          .CRLFReset
    cmp         dl, 0x0a
    je          .CRLFReset
    mov         bx, [FieldPos]
    mov         ax, [Fields]
    cmp         bx, ax
    jb          .NotThisField
    mov         ax, [Fields+2]
    cmp         bx, ax
    ja          .NotThisField
    jmp         .SendCharOut
.CRLFReset:
    mov         bx, 0x0001
    mov         [FieldPos], bx
.SendCharOut:
	StdOutChar
.NotThisField:
    ret
.FieldIDMatch:
    mov         bx, [FieldPos]
    inc         bx
    mov         [FieldPos], bx

    push        dx
    push        ax
    mov         ax, [Fields]
    mov         dx, [Fields+2]
    cmp         dx, ax
    je          .NoShowDelim
    cmp         bx, ax
    jna         .NoShowDelim
    cmp         bx, dx
    ja         .NoShowDelim
    jmp         .ShowDelim
.NoShowDelim:
    pop         ax
    pop         dx

    popf
    jnc         .Done
    jmp         .Continued
.ShowDelim:
    pop         ax
    pop         dx
    dec         cx
    jmp         .Missmatch

.Done:
    ret

SwitchP:
    cmp         di, si
    je          .Done
    mov         al, [di]
    inc         di
    StdOutChar  al
    jmp         SwitchP
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

SwitchB:
    mov         al, [Filter]
    or          al, 00000100b
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
    test    dh, 00000100b
    jz      .NotBlankLines
    cmp     al, 0x0d
    je      .BlankCR
    cmp     al, 0x0a
    je      .BlankLF
    push    ax
    mov     ah, al
    mov     [BlankCRLF], ax
    pop     ax
    jmp     .NotBlankLines
.BlankCR:
    mov     ah, [BlankCRLF]
    cmp     ah, 0
    je      .Ignored
    xor     ah, ah
    mov     [BlankCRLF], ah
    jmp     .NotBlankLines
.BlankLF:
    mov     ah, [BlankCRLF + 1]
    cmp     ah, 0
    je      .Ignored
    xor     ah, ah
    mov     [BlankCRLF + 1], ah
    jmp     .NotBlankLines
.NotBlankLines:
.Done:
    stc
    ret
.Ignored:
    clc
    ret

HelpSwitchHandler

NoSwitch:
    mov         ax, [MultiOptionSwitch]
    cmp         ax, 0x0000
    jne         .Special
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    jmp         ax
.Special:
    push        ax
    xor         ax, ax
    mov         [MultiOptionSwitch], ax
    pop         ax
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
    SwitchData  'B', 0, SwitchB
    SwitchData  'F', 1, SwitchF
    SwitchData  'T', 1, SwitchT
    SwitchData  'P', 1, SwitchP
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
    TableEnd

OptionsLines:
    TableData "TOTAL", TotalLines
    TableEnd

TabSearch:
    db 0x09,0

MultiOptionSwitch:
    dw 0
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
Fields:
    dw 0, 0xffff
FieldPos:
    dw 0
BlankCRLF:
    dw 0