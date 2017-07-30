; Copyright (C) 2017 Jerome Shidel
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

; NASM 2.14rc0 for DOS

%imacro ShellExec 2

        jmp     %%Over

    %ifndef Declared_ShellExec
        %define Declared_ShellExec

    Function_ShellExec:
        pushall
        cld
        xor         cx, cx
        mov         [DATABLOCK(ENVIRONMENT)], cx
        mov         di, DATABLOCK(EXECLINE)
        push        di
        inc         di
    .Copying:
        lodsb
        cmp         al, 0x0d
        je          .Copying
        stosb
        inc         cx
        cmp         al, 0
        jne         .Copying
        mov         ah, 0x0d
        mov         [di], ah
        inc         di
        inc         cx
    .Fill:
        stosb
        cmp         di, DATABLOCK(SAVESTACK)
        jb          .Fill
        pop         di
        mov         [di], cl

        mov         di, DATABLOCK(SAVESTACK)
        mov         [di], ss
        mov         [di + 2], sp
        mov         ax, DATABLOCK(EXECLINE)
        mov         [DATABLOCK(COMMANDPTR)], ax
        mov         [DATABLOCK(STACKPTR)], ss
        mov         [DATABLOCK(STACKPTR) + 2], sp
        mov         ax, %%Return
        mov         [DATABLOCK(CODEPTR)], ax
        mov         ax, cs
        mov         [DATABLOCK(CODEPTR) + 2], ax
        mov         [DATABLOCK(COMMANDPTR) + 2], ax

        ; mov         ds, ax
        ; mov         es, ax
        ; mov         dx, %%Program

        mov         bx, DATABLOCK(ENVIRONMENT)
        mov         ax, 0x4b00
        int         0x21
    %%Return:
        mov         di, DATABLOCK(SAVESTACK)
        mov         ss, [cs:di]
        mov         sp, [cs:di + 2]
        jc          %%ErrorCode
        xor         ax, ax
    %%ErrorCode:
        mov         [DATABLOCK(ENVIRONMENT)], ax
        popall
        mov         ax, [DATABLOCK(ENVIRONMENT)]
        ret

    %endif

    %%Over:
        multipush   bx, dx
        mov         dx, %1
        mov         si, %2
        call        Function_ShellExec
        multipop    bx, dx

%endmacro
