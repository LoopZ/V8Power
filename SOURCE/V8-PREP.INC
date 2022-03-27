; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM 2.14rc0

use16

cpu 8086

org 0x100

%include 'V8-MACRO.INC'
%include 'V8-STRUC.INC'
%include 'V8-DOS.INC'

%imacro Terminate 0-1 0
    %idefine            Require_Terminate
    %ifidni %1, al
    %elif %1 = 0
        xor             al, al
    %else
        mov             al, %1
    %endif
    jmp                 proc_Terminate
%endmacro

%imacro PlaceHolderApplication 0
    %idefine            Require_PlaceHolderApplication
    DOS_PrintString     Message_PlaceHolderApplication
%endmacro

CODE_SEGMENT