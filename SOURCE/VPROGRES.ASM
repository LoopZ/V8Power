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

    FrameBounds

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
    jg      WidthKnown

    mov     al, cl
    sub     al, bl
    inc     al

WidthKnown:
    mov     ah, [Position]
    cmp     ah, 0
    je      .NoNumberPad
    cmp     ah, 2
    je      .NoNumberPad
    cmp     al, 10
    jge     .WithNumbers
    mov     ah, [Percent]
    cmp     ah, 100
    jge     .WithNumbers
    xor     ah, ah
    mov     [Position], ah
    jmp     .NoNumberPad
.WithNumbers:
    sub     al, 5
.NoNumberPad:
    mov     [Width], al
    xor     ah, ah
    mov     al, [Position]
    cmp     al, 1
    jne     .NotLeftNumber
    call    WriteNumber
    call    WritePadding
    mov     dx, 0x0005
    GotoXY  dx
.NotLeftNumber:
    xor     dx, dx
    xor     ah, ah
    mov     al, [Percent]
    mov     cl, [Width]
    xor     ch, ch
    mul     cx
    mov     cx, 100
    div     cx
    mov     [Partial], dl
    mov     cl, [Width]
    xor     ch, ch
    cmp     ax, cx
    jl      .WriteBar
    mov     ax, cx
.WriteBar:
    mov         [Used], al
    mov         cx, ax
    mov         ah, 0x09
    mov         al, 0xb2
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    int         0x10
    push        cx
    xor         ch, ch
    mov         cl, [Percent]
    cmp         cx, 100
    pop         cx
    jge         .NoPartial
    mov         dl, [Partial]
    cmp         dl, 25
    jl          .NoPartial
    mov         al, [Used]
    inc         al
    mov         [Used], al
    xor         dx, dx
    mov         dl, al
    dec         dl
    mov         al, [Position]
    cmp         al, 1
    jne         .NotLeft1
    add         dx, 5
.NotLeft1:
    GotoXY      dx
    mov         cx, 1
    mov         ah, 0x09
    mov         al, 0xb1
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    int         0x10
.NoPartial:
    mov         al, [Used]
    xor         dx, dx
    mov         dl, al
    mov         al, [Position]
    cmp         al, 1
    jne         .NotLeft2
    add         dx, 5
.NotLeft2:
    GotoXY      dx
    mov         cl, [Width]
    mov         al, [Used]
    xor         ch, ch
    sub         cl, al
    mov         ah, 0x09
    mov         al, 0xb0
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    and         bl, 0x77
    int         0x10
    mov         al, [Position]
    cmp         al, 3
    jne         .NotRight
    xor         dx, dx
    mov         dl, [Width]
    push        dx
    GotoXY      dx
    call        WritePadding
    pop         dx
    add         dx, cx
    GotoXY      dx
    xor         ax, ax
    mov         al, [Percent]
    call        WriteNumber
    jmp         Done
.NotRight:
    cmp         al, 2
    jne         Done
    xor         ah, ah
    mov         al, [Width]
    shr         al, 1
    dec         al
    GotoXY      ax
    xor         ah, ah
    mov         al, [Percent]
    WriteIntNoAttr ax
    mov         al, '%'
    WriteChar   0x0a

Done:
    xor         dx, dx
    GotoXY      dx
    Terminate   0

WritePadding:
    mov     cx, 0x0001
    xor     ah, ah
    mov     al, [Percent]
    cmp     ax, 100
    jge     .Writing
    inc     cx
    cmp     ax, 10
    jge     .Writing
    inc     cx
.Writing:
    push        cx
    mov         ah, 0x09
    mov         al, 0x20
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    int         0x10
    pop         cx
    ret

WriteNumber:
    xor         ah, ah
    mov         al, [Percent]
    WriteInt    ax
    mov         ah, 0x09
    mov         al, '%'
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    mov         cx, 0x0001
    int         0x10
    mov         al, [Position]
    cmp         al, 1
    jne         .Done
    GotoNextXY
.Done:
    ret

SwitchOF:
    mov     al, 1
    mov     [NextOF], al
    ret

NoSwitch:
    LookupParam OptionTable
    cmp     ax, 0xffff
    je      .NotOption
    cmp     ax, SwitchOF
    je      SwitchOF
    mov     [Position], al
    ret

.NotOption:
    NumberParam
    mov     bl, [NextOF]
    xor     bh, bh
    mov     [NextOF], bh
    cmp     bl, 1
    je      .Calculate
    mov     [Percent], ax
    ret

.Calculate:

    push    ax
    xor     dx, dx
    mov     cx, 100
    mov     ax, [Percent]
    mul     cx
    pop     cx
    cmp     cx, 0
    je      .Zero
    div     cx
    jmp     .SetPercent
.Zero:
    xor     ax, ax
.SetPercent:
    mov     [Percent], ax
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

    ColorSwitchHandlers
    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    ColorSwitchData
    SwitchData 'W', 1, SwitchW
    HelpSwitchData
    SwitchData  0,  0, 0

OptionTable:
    TableData   "OF", SwitchOF
    TableData   "OFF", 0
    TableData   "LEFT", 1
    TableData   "CENTER", 2
    TableData   "RIGHT", 3
    TableEnd

Width:
    db 0
Position:
    db 2
Percent:
    dw 0
Partial:
    db 0
Used:
    db 0
NextOF:
    db 0