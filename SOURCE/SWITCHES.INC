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

; common code for command line switches

%imacro ColorSwitchHandlers 0
SwitchA:
    call        NumberParam 
    mov         [TextAttr], al
    ret
      
SwitchColor:
    mov         si, ColorTable
    call        LookupParam
    cmp         ax, 0xffff
    jne         .Found
    call        NumberParam
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
%endmacro

%imacro SwitchData 3
	db 			%1
	db 			%2
	dw			%3
%endmacro

%imacro ColorSwitchData 0
	SwitchData 'A', 1, SwitchA
    SwitchData 'F', 1, SwitchF
    SwitchData 'B', 1, SwitchB
%endmacro