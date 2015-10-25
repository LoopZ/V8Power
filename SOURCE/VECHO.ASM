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

%include "COMMON.INC"

    FrameBounds

    CommandLineParser       ; insert code for command line parsing

    mov         al, [NoNewLine]
    cmp         al, 0
    jne         Done
    mov     cx, [Repeat]
ReturnLoop:
    push    cx
    WriteStr    CRLFString
    pop     cx
    loop    ReturnLoop
Done:
    Terminate 0

NoSwitch:
    xor         al, al
    mov         [si], al
    mov     cx, [Repeat]
.SwitchLoop:
    push    cx
    push    di
    WriteStr    di
    pop     di
    pop     cx
    loop    .SwitchLoop
    inc     cx
    mov     [Repeat], cx
    ret

SwitchN:
    mov         al, 1
    mov         [NoNewLine], al
    ret

SwitchC:
    NumberParam
    mov     cx, [Repeat]
.SwitchLoop:
    push    cx
    WriteChar
    pop     cx
    loop    .SwitchLoop
    inc     cx
    mov     [Repeat], cx
    ret

SwitchI:
    WriteStdIn
    ret

SwitchR:
    NumberParam
    mov         [Repeat], ax
    ret

SwitchE:
    mov         ax, 0x20
    jmp         FillLine

SwitchX:
    NumberParam

FillLine:
    push        ax
    WhereXY
    pop         ax
    mov         cl, [WindMaxX]
    sub         cl, [WindMinX]
    inc         cl
    sub         cl, dl
    xor         ch, ch
    cmp         cx, 0
    je          .Done
.Fill:
    mov         ah, 0x09
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    int         0x10
.Done:
    ret

    ColorSwitchHandlers

SwitchL:
    FrameBounds
    ret

SwitchG:
    xor     ax, ax
    mov     [WindMin], ax
    mov     ax, [ScreenMax]
    mov     [WindMax], ax
    ret

%include "TRANSLAT.INC"

    Translator

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    ColorSwitchData
    SwitchData  'N', 0, SwitchN
    SwitchData  'C', 1, SwitchC
    SwitchData  'R', 1, SwitchR
    SwitchData  'I', 0, SwitchI
    SwitchData  'E', 0, SwitchE
    SwitchData  'X', 1, SwitchX
    SwitchData  'T', 1, SwitchT
    LocalSwitchData
    HelpSwitchData
    SwitchData  0,  0, 0

CRLFString:
    db  CRLF,0

Repeat:
    dw 1
NoNewLine:
    db 0


