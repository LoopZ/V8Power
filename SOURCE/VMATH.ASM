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

%include "COMMON.INC"

    %idefine SwitchChar '^'

    CommandLineParser       ; insert code for command line parsing

    mov     al, [OutStyle]
    cmp     al, 1
    je      OutHex
    StdOutIntWord [OutResult]
    jmp     Done
OutHex:
    mov     ax, [OutResult]
    StdOutHexWord
Done:
    StdOutCRLF
    Terminate 0

ClearLastOpt:
    mov     ax, OptNone
    mov     [LastOpt], ax
    ret

OptNone:
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptPlus:
    mov     cx, [OutResult]
    add     cx, ax
    mov     [OutResult], cx
    jmp     ClearLastOpt

OptMinus:
    mov     cx, [OutResult]
    sub     cx, ax
    mov     [OutResult], cx
    jmp     ClearLastOpt

OptMultiply:
    xor     dx, dx
    mov     cx, [OutResult]
    mul     cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptDivide:
    xor     dx, dx
    mov     cx, [OutResult]
    xchg    ax, cx
    div     cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptMod:
    xor     dx, dx
    mov     cx, [OutResult]
    xchg    ax, cx
    div     cx
    mov     [OutResult], dx
    jmp     ClearLastOpt

OptShr:
    xor     dx, dx
    mov     cx, [OutResult]
    xchg    ax, cx
    shr     ax, cl
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptShl:
    xor     dx, dx
    mov     cx, [OutResult]
    xchg    ax, cx
    shl     ax, cl
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptAnd:
    xor     dx, dx
    mov     cx, [OutResult]
    and     ax, cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptOr:
    xor     dx, dx
    mov     cx, [OutResult]
    or      ax, cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptXor:
    xor     dx, dx
    mov     cx, [OutResult]
    xor     ax, cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

RealSwitches:

SwitchH:
    mov     al, 1
    mov     [OutStyle], al
    ret

SwitchD:
    mov     al, 0
    mov     [OutStyle], al
    ret

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    cmp         ax, RealSwitches
    jl          .NotSwitch
    jmp         ax
.NotSwitch:
    mov         [LastOpt], ax
    ret

.NotOption:
    NumberParam
    jmp         [LastOpt]

.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

LastOpt:
    dw OptNone

OutResult:
    dw 0

OutStyle:
    db 0

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
    TableData '/H', SwitchH
    TableData '/D', SwitchD
    TableData 'ADD', OptPlus
    TableData '+', OptPlus
    TableData 'ADD', OptPlus
    TableData '-', OptMinus
    TableData 'SUB', OptMinus
    TableData '*', OptMultiply
    TableData 'MUL', OptMultiply
    TableData '/', OptDivide
    TableData 'DIV', OptDivide
    TableData '\', OptMod
    TableData 'MOD', OptMod
    TableData 'SHR', OptShr
    TableData 'SHL', OptShl
    TableData 'AND', OptAnd
    TableData 'OR', OptOr
    TableData 'XOR', OptXor
    TableEnd
