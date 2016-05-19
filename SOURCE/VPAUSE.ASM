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

%include "COMMON.INC"

    DumpKeystrokes

    WhereXY
    mov     [Position], dx

    CommandLineParser       ; insert code for command line parsing

KeyBoardLoop:
    mov         cx, [TimeOut]
    push        es
    mov         bx, 0x0040
    mov         es, bx
    mov         bx, 0x006c
    mov         dx, [es:bx]
.WaitLoop:
    IdleCPU
    mov         ax, [TimeOut]
    cmp         ax, 0
    je          .NoTimeOut
    cmp         cx, 0
    je          TimedOut
    mov         ax, [es:bx]
    cmp         ax, dx
    je          .NoTimeOut
    dec         cx
    mov         dx, ax
    call        ShowTimeOut
.NoTimeOut:
    mov         ax, 0x0100
    int         0x16
    jz          .WaitLoop
    pop         es

    mov         ax, 0x0000
    int         0x16

    push		ax
    mov			ah, [ControlC]
    cmp			ax, 0x0103
    pop			ax
    je			ControlCQuit
    mov         al, [Postal]
    cmp         al, 1
    je          DoPostal
    mov         dx, [Position]
    GotoXY      dx
    Terminate 0

TimedOut:
    mov         al, [Postal]
    cmp         al, 1
    je          DoPostal
    mov         dx, [Position]
    GotoXY      dx
    Terminate 1

DoPostal:
    GoPostal

ControlCQuit:
    mov			al, 200
    Terminate   al

ShowTimeOut:
    push        cx
    push        bx
    push        dx

    xor         dx, dx
    mov         ax, 11
    xchg        ax, cx
    mul         cx
    mov         cx, 200
    div         cx

    push        ax
;    mov            cx, 0
;   cmp         ax, 1000
;   jge         .SetWidth
;   inc         cx
;   cmp         ax, 100
;   jge         .SetWidth
;   inc         cx
;   cmp         ax, 10
;   jge         .SetWidth
;   inc         cx
; .SetWidth:
    mov         bl, [TextAttr]
    mov         bh, [VideoPage]
    mov         dx, [Position]
    mov         ah, 0x02
    int         0x10
;    cmp            cx, 0
;    je         .NoSpace
;    mov            ax, 0x0920
;    int            0x10
;    add            dl, cl
; .NoSpace:
    mov         ah, 0x02
    int         0x10

    pop         ax
    WriteInt    ax
    mov         al, 0x20
    WriteChar   0x09
NoDisplayTimeOut:
    pop         dx
    pop         bx
    pop         cx
    ret

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

OptCtrlC:
    mov         al, 1
    mov         [ControlC], al
    ret

OptPostal:
    mov         al, 1
    mov         [Postal], al
    ret

SwitchT:
    NumberParam
    cmp         ax, 0
    je          .SwitchOff
    cmp         ax, 3600
    jle         .SwitchOK
    mov         ax, 3600
.SwitchOK:
    inc         ax
    mov         cx, 200
    mul         cx
    mov         cx, 11
    div         cx
    inc         ax
.SwitchOff:
    mov         [TimeOut], ax
    ret

    ColorSwitchHandlers

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'D',  1, SwitchT
    SwitchData  'T',  1, SwitchT
    ColorSwitchData
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
    TableData 'CTRL-C', OptCtrlC
    TableData 'CTRL+C', OptCtrlC
    TableData 'POSTAL', OptPostal
    TableEnd

TimeOut:
    dw 0
Position:
    dw 0
ControlC:
	db 0
Postal:
    db 0