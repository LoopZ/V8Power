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

CODE_SEGMENT

%ifndef Require_Terminate
    %idefine            Require_Terminate
    mov                 al, 0
%endif

%ifdef Require_Terminate
    proc_Terminate:
        mov             ah, 4ch
        int             0x21
%endif

%ifndef ApplicationDataBlock
    %include 'V8-DATA.INC'
%endif

BSS_SEGMENT

HEAP_SEGMENT