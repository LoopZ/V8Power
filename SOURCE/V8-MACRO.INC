; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file
; NASM 2.14rc0

; 8086 language extensions

%imacro retz 0
        jnz     %%Skip
        ret
    %%Skip:
%endmacro

%imacro retnz 0
        jz      %%Skip
        ret
    %%Skip:
%endmacro

%imacro retc 0
        jnc     %%Skip
        ret
    %%Skip:
%endmacro

%imacro retnc 0
        jc      %%Skip
        ret
    %%Skip:
%endmacro

%imacro pushall 0
	pushf
	push	    ax
	push 	    bx
	push	    cx
	push	    dx
	push	    si
	push	    di
	push	    es
	push	    ds
	push        bp
%endmacro

%imacro popall 0
    pop         bp
	pop 	    ds
	pop		    es
	pop		    di
	pop		    si
	pop		    dx
	pop		    cx
	pop		    bx
	pop		    ax
	popf
%endmacro

%imacro pushx 0-*
    %ifidni %0, 0
        pushall
    %elifidni %1, all
        pushall
    %else
        %rep %0
            push    %1
        %rotate 1
        %endrep
    %endif
%endmacro

%imacro popx 1-*
    %ifidni %0, 0
        popall
    %elifidni %1, all
        popall
    %else
        %rep %0
        ; %rotate -1 reverse order
            pop     %1
        %rotate 1
        %endrep
    %endif
%endmacro

; NASM Extensions
%imacro Declare 1
    %ifndef Delcared_%1
        %idefine Delcared_%1
        %1:
    %endif
%endmacro

%imacro CODE_SEGMENT 0
    section Section_CODE
    Declare Application_Start
%endmacro

%imacro DATA_SEGMENT 0
    section Section_DATA
    Declare Application_Data
%endmacro

%imacro SHARED_SEGMENT 0
    section Section_SHARED
    Declare Application_Shared
%endmacro

%imacro BSS_SEGMENT 0
    section Section_BSS
    Declare Application_BSS
%endmacro 0

%imacro HEAP_SEGMENT 0
    section Section_BSS
    Declare Application_Heap
%endmacro 0


