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

    WhereXY
    mov     [Position], dx
    xor     dl, dl
    GotoXY  dx
    xor     ax, ax

    CommandLineParser       ; insert code for command line parsing

Scrolling:
    mov         cx, [WindMin]
    mov         dx, [Position]
    add         ch, dh
    mov         dx, [WindMax]
    mov         ax, 0x0701
    mov         bh, [TextAttr]
    int         0x10
    mov         cx, [Lines]
    cmp         cx, 0x0001
    jna         Done
    dec         cx
    mov         [Lines], cx
    jmp         Scrolling

Done:
    mov     dx, [Position]
    GotoXY  dx
    Terminate 0

NoSwitch:
;    LookupParam OptionsTable
;    cmp         ax, 0xffff
;    je          .NotOption
;    jmp         ax

;.NotOption:
    NumberParam
    ; do something with ax
    mov  [Lines], ax
    ret

.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

ColorSwitchHandlers
LocalSwitchHandlers
HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    ColorSwitchData
    LocalSwitchData
    HelpSwitchData
    SwitchData  0,  0, 0

Position:
    dw 0
Lines:
    dw 0
