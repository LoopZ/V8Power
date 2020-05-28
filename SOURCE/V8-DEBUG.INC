; Copyright (C) 2016-2020 Jerome Shidel
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

; NASM 2.14rc0

; macro to print a character for debugging
%imacro DebugOutput 0
    %ifndef Declared_DebugOutput
        %idefine Declared_DebugOutput
        jmp         %%Over
    ..@proc_DebugOutput:
        push        ax
        mov         ah, 0x02
        int         0x21
        pop         ax
        ret
    %endif
    %%Over:
        call    ..@proc_DebugOutput
%endmacro

%imacro DebugChar 0-1 dl
    %ifnidni %1, dl
        push        dx
        mov         dl, %1
    %endif
    DebugOutput
    %ifnidni %1, dl
        pop         dx
    %endif
%endmacro

%imacro DebugHexNibble 0
    %ifndef Declared_DebugHexNibble
        %idefine Declared_DebugHexNibble
        jmp         %%Over
    ..@proc_DebugHexNibble:
        push        ax
        and         al, 0x0f
        add         al, 0x30
        cmp         al, 0x39
        jbe         %%NotAlpha
        add         al, 0x07
    %%NotAlpha:
        DebugChar   al
        pop         ax
        ret
    %endif
    %%Over:
        call    ..@proc_DebugHexNibble
%endmacro

%imacro DebugHexByte 0-1 al
    %ifndef Declared_DebugHexByte
        %idefine Declared_DebugHexByte
        jmp         %%Over
    ..@proc_DebugHexByte:
        push        cx
        %ifnidni %1, al
            push    ax
            mov     al, %1
        %endif
        push        ax
        mov         cl, 4
        shr         al, cl
        and         al, 0x0f
        DebugHexNibble
        pop         ax
        DebugHexNibble
        %ifnidni %1, al
            pop     ax
        %endif
        pop         cx
        ret
    %endif
    %%Over:
        call    ..@proc_DebugHexByte
%endmacro

%imacro DebugHexWord 0-1
    %ifndef Declared_DebugHexWord
        %idefine Declared_DebugHexWord
        jmp         %%Over
    ..@proc_DebugHexWord:
        xchg        al, ah
        DebugHexByte al
        xchg        al, ah
        DebugHexbyte al
        ret
    %endif
    %%Over:
        %ifnidni %1, ax
            push    ax
            mov     ax, %1
        %endif
        call    ..@proc_DebugHexWord
        %ifnidni %1, ax
            pop     ax
        %endif
%endmacro
