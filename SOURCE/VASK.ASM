; Copyright (C) 2015 Jerome Shidel
;
;	This program is free software; you can redistribute it and/or modify
;	it under the terms of the GNU General Public License as published by
;	the Free Software Foundation; either version 2 of the License, or
;	(at your option) any later version.
;
;	This program is distributed in the hope that it will be useful,
;	but WITHOUT ANY WARRANTY; without even the implied warranty of
;	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;	GNU General Public License for more details.
;
;	You should have received a copy of the GNU General Public License along
;	with this program; if not, write to the Free Software Foundation, Inc.,
;	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

; NASM for DOS

%include "COMMON.INC"

    FrameBounds

MainParsing:

    CommandLineParser       ; insert code for command line parsing

    WhereXY
    mov     cx, [WindMax]
    mov     bx, [WindMin]
    add     bh, dh
    add     bl, dl
    mov     ch, bh
    mov     [WindMax], cx
    mov     [WindMin], bx

    mov     al, [Width]
    cmp     al, 0
    ja      InputLoop

    mov     al, cl
    sub     al, bl
    inc     al
    mov     [Width], al

InputLoop:

    call        HideCursor
    WhereXY
    push        dx
    mov         dl, 0
    GotoXY      dx
    WriteRawStr TextBuffer
    pop         dx
    GotoXY      dx
    call        EditCursor

KeyBoardLoop:
    mov         cx, [TimeOut]
    push        es
    mov         bx, 0x0040
    mov         es, bx
    mov         bx, 0x006c
    mov         dx, [es:bx]
.WaitLoop:
    mov         ax, [TimeOut]
    cmp         ax, 0
    je          .NoTimeOut
    cmp         cx, 0
    jne         .NotTimedOut
    pop         es
    jmp         TimedOut
.NotTimedOut:
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

    jmp         InputLoop

    Terminate 0

TimedOut:
    Terminate 1

ControlCQuit:
    Terminate   200

HideCursor:
    push        dx
    mov         cx, 0x2000
    mov         ah, 0x01
    int         0x10
    pop         dx
    ret

EditCursor:
    push        dx
    xor         ah, ah
    mov         al, [EditMode]
    mov         bx, 0x0040
    push        es
    mov         es, bx
    mov         cl, [es:0x0085]
    pop         es
    cmp         ax, 0
    jne         .NotSmall
    mov         al, cl
    mov         ah, al
    sub         ah, 2
    jmp         .Done
.NotSmall:
    cmp         ax, 1
    jne         .NotHalf
    mov         al, cl
    mov         ah, al
    shr         ah, 1
    jmp         .Done
.NotHalf:
    mov         al, cl
    mov         ah, 0
.Done:
    mov         cx, ax
    mov         ah, 0x01
    int         0x10
    pop         dx
    ret

ShowTimeOut:
    push        cx
    push        bx
    push        dx

    mov         ax, dx
    xor         dx, dx
    mov         ax, 11
    xchg        ax, cx
    mul         cx
    mov         cx, 200
    div         cx

    mov         dx, [WindMax]
    mov         bx, [WindMin]
    xor         dh, dh
    sub         dl, bl
    dec         dl
    cmp         ax, 10
    jb         .SetPosition
    dec         dl
    cmp         ax, 100
    jb         .SetPosition
    dec         dl
    cmp         ax, 1000
    jb         .SetPosition
    dec         dl
 .SetPosition:
    push        ax
    push        dx
    WhereXY
    pop         cx
    pop         ax

    push        dx
    push        ax
    GotoXY      cx
    mov         al, 0x20
    WriteChar   0x0A
    pop         ax
    WriteIntSys ax
    pop         dx
    GotoXY      dx
    pop         dx
    pop         bx
    pop         cx
    ret


NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je	        .NotOption
	jmp			ax

.NotOption:
    mov         bx, TextBuffer
.BufferSearch:
    mov         al, [bx]
    cmp         al, 0
    je          .BufferEnd
    inc         bx
    jmp         .BufferSearch
.BufferEnd:
    cmp         bx, TextBuffer
    je          .BufferLoop
    mov         al, 0x20
    jmp         .BufferStore
.BufferLoop:
    cmp         di, si
    je          .BufferDone
    cmp         bx, TextEnd
    je          SwitchError
    mov         al, [di]
    inc         di
.BufferStore:
    mov         [bx], al
    inc         bx
    jmp         .BufferLoop
.BufferDone:
	ret

SwitchW:
    NumberParam
    cmp     ax, 5
    jl      SwitchError
    cmp     ax, 0x00ff
    jg      SwitchError
    push    ax
    WhereXY
    pop     ax
    mov     cl, [WindMaxX]
    mov     ch, [WindMinX]
    sub     cl, ch
    sub     cl, dl
    inc     cl
    xor     ah, ah
    xor     ch, ch
    cmp     ax, cx
    jg      SwitchError
    mov     [Width], al
    ret

SwitchD:
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


%include "TRANSLAT.INC"

SwitchT:
    Translator MainParsing

    LocalSwitchHandlers
    ColorSwitchHandlers
	HelpSwitchHandler

CommandLineSwitches:
	SwitchData  0,  0, NoSwitch
    ColorSwitchData
 	HelpSwitchData
    LocalSwitchData
    SwitchData 'W', 1, SwitchW
    SwitchData 'D', 1, SwitchD
    SwitchData  0,  0, 0

OptionsTable:
	TableEnd

TextBuffer:
    times 127 db 0
TextEnd:
    db 0

TimeOut:
    dw 0
ControlC:
	db 1
EditMode:
    dw 0
Width:
    db 0
Max:
    db TextEnd - TextBuffer
