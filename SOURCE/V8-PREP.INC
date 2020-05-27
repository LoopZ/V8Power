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

; NASM 2.14rc0 for DOS

use16

cpu 8086

org 0x100

%include 'V8-MACRO.INC'
%include 'V8-STRUC.INC'

%imacro Terminate 0-1 0
    %idefine    Require_Terminate
    mov         al, %1
    jmp         proc_Terminate
%endmacro

%imacro PlaceHolderApplication 0
    %idefine    Require_PlaceHolderApplication
    mov         dx, Message_PlaceHolderApplication
    mov         ah, 0x09
    int         0x21
%endmacro

CODE_SEGMENT