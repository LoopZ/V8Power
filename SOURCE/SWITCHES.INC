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

; common code for command line switches

%imacro ColorSwitchHandlers 0
SwitchA:
    NumberParam
    mov         [TextAttr], al
    ret

SwitchColor:
    LookupParam ColorTable
    cmp         ax, 0xffff
    jne         .Found
    NumberParam
.Found:
    ret

SwitchF:
    call        SwitchColor
    mov         ah, [TextAttr]
    and         ah, 0xf0
    or          ah, al
    mov         [TextAttr], ah
    ret

SwitchB:
    call        SwitchColor
    mov         ah, [TextAttr]
    mov         cl, 4
    shl         al, cl
    and         ah, 0x0f
    or          ah, al
    mov         [TextAttr], ah
    ret

    ColorTableData      ; insert color name table

%endmacro

%imacro SwitchData 3
    db          %1
    db          %2
    dw          %3
%endmacro

%imacro ColorSwitchData 0
    SwitchData 'A', 1, SwitchA
    SwitchData 'F', 1, SwitchF
    SwitchData 'B', 1, SwitchB
%endmacro

%imacro XYSwitchHandlers 0
SwitchX:
    NumberParam
    dec         al
    mov         [CurrentX], al
    ret

SwitchY:
    call        NumberParam
    dec         al
    mov         [CurrentY], al
    ret

CurrentXY:
    CurrentX:   DB 0
    CurrentY:   DB 0
%endmacro

%imacro SizeSwitchHandlers 0
SwitchW:
    NumberParam
    mov         [CurrentW], al
    ret

SwitchH:
    NumberParam
    mov         [CurrentH], al
    ret

CurrentSize:
    CurrentW:   DB 80
    CurrentH:   DB 25
%endmacro

%imacro SetMaxSize 0
    push        ax
    push        bx
    mov         ax, [WindMax]
    mov         bx, [WindMin]
    sub         ah, bh
    sub         al, bl
    inc         ah
    inc         al
    mov         [CurrentSize], ax
    pop         bx
    pop         ax
%endmacro

%imacro LocalSwitchHandlers 0
    SwitchL:
        FrameBounds
        ret
    SwitchG:
        mov     ax, 0x0000
        mov     [WindMin], ax
        mov     ax, [ScreenMax]
        mov     [WindMax], ax
        ret
%endmacro

%imacro XYSwitchData 0
    SwitchData 'X', 1, SwitchX
    SwitchData 'Y', 1, SwitchY
%endmacro

%imacro SizeSwitchData 0
    SwitchData  'W', 1, SwitchW
    SwitchData  'H', 1, SwitchH
%endmacro

%imacro LocalSwitchData 0
    SwitchData 'L', 0, SwitchL
    SwitchData 'G', 0, SwitchG
%endmacro

%imacro HelpSwitchData 0
    SwitchData '?', 0, SwitchHelp
%endmacro

%imacro NoHelpMessage 0
%ifdef NoVideoOutput
    StdOutStr   %%Message
%else
    WriteStr 	%%Message
%endif
    Terminate 0
    %%Message:
	DB 'See V8Help.bat or V8Power Tools docs.'
    DB CRLF,0
%endmacro

%imacro HelpSwitchHandler 0-1 ''
%ifidni %1, ''
	%undef HelpText
	%idefine NoHelpText
%endif

SwitchHelp:
; %ifdef HelpText
;    StdOutStr   %%Message
;    Terminate 0
; %else
    NoHelpMessage
; %endif
%endmacro