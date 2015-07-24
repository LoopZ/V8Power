; Copyright ¸ 2015 Jerome Shidel

; NASM for DOS 

use16

cpu 8086

org 0x100

; common macros

; Exit program and return to DOS with or without errorcode
%imacro Terminate 0-1 0
    mov  		ah, 4ch  
    mov  		al, %1
    int  		0x21
%endmacro

%imacro PlaceHolder 0
	push		cs
	pop			ds
	mov			dx, Message
	mov			ah, 0x09
	int			0x21
	jmp			Done
Message:
	DB "This program is only a placeholder executable. "
	DB "It will be replaced by a program",0x0d,0x0a
	DB "that actually does something at a later time.$"
Done:
%endmacro
