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

; common macros

; Exit program and return to DOS with or without errorcode
%imacro Terminate 0-1 0
    mov         al, %1
    jmp         ProgramTerminate
%endmacro

%imacro WhereXY 0
    call        WhereXYProc
%endmacro
    
%imacro GotoXY 1-2
    %if %0 = 2
        mov     dl, %1
        mov     dh, %2
    %elif %0 = 1
        mov     dx, %1
    %endif
    call    GotoXYProc
%endmacro

; Move cursor to next position
%imacro GotoNextXY 0
    WhereXY
    inc         dl
    mov			bl, [WindMaxX]
    sub			bl, [WindMinX]
    cmp			dl, bl
    jle			%%Done
    mov			dl, 0
    inc			dh
    mov			bl, [WindMaxY]
    sub			bl, [WindMinY]
    cmp			dh, bl
    jl			%%Done
    dec			dh
	push		ax
	push		dx
	push		cx
	mov			ax, 0x0601
	mov			bh, [TextAttr]
	mov			cx, [WindMin]
	mov			dx, [WindMax]
	int			0x10
    pop			cx
    pop			dx
    pop			ax
%%Done:
    GotoXY      dx
%endmacro

; Read char/attribute at cursor location
%imacro ReadChar 0
    mov         ah, 0x08
    mov         bh, [VideoPage]
    int         0x10
%endmacro
    
%imacro WriteChar 0
    call        WriteCharProc
%endmacro

; Write a ASCIIZ String and display control codes as characters
%imacro WriteRawStr 1
    mov         si, %1
    cld
%%WriteRawLoop:
    lodsb
    cmp         al, 0
    je          %%WriteRawDone
    WriteChar
    jmp         %%WriteRawLoop
%%WriteRawDone:
%endmacro
    
%imacro WriteStr 1
    mov         si, %1
    call        WriteStrProc
%endmacro

