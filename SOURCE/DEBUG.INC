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

; debugging macros

; macro to print a character for debugging
%imacro DebugChar 0-1 al
    pushf
    push    ax
    push    bx
    push    cx
    push    dx
    push    di
    push    si
    mov     al, %1
    WriteChar
    pop     si
    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
%endmacro

; macro to print a character for debugging
%imacro DebugInt 0-1 ax
    pushf
    push    ax
    push    bx
    push    cx
    push    dx
    push    di
    push    si
    WriteInt %1
    pop     si
    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
%endmacro
 
 ; macro that shows command line switch and data, mostly for debuging the
; command line parser
%imacro DebugCmdLn 0
    push        cx
    push        dx
    mov         al, ' '
    WriteChar
    pop         dx
    cmp         dl, 0
    je          %%NoSwitch
    push        dx
    mov         al, SwitchChar
    WriteChar
    pop         dx
    mov         al, dl
    WriteChar
    pop         cx
    push        cx
    cmp         cx, 0
    jne         %%NoSwitch
    pop         cx
    ret
%%NoSwitch:
    mov         al, '('
    WriteChar
    pop         cx
    cmp         cx, 0
    je          %%NoText
%%Repeat:
    push        cx
    mov         al, [di]
    WriteChar
    pop         cx
    inc         di
    loop        %%Repeat
%%NoText:
    mov         al, ')'
    WriteChar
    ret
%endmacro

