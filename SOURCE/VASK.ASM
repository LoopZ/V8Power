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

    Terminate 0

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je	        .NotOption
	jmp			ax

.NotOption:
	NumberParam
	; do something with ax
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
    SwitchData  0,  0, 0

OptionsTable:
	TableEnd

Width:
    db 0
