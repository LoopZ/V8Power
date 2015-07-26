; Copyright (C) 2015 Jerome Shidel
;
;	This program is free software; you can redistribute it and/or modify
;	it under the terms of the GNU General Public License as published by
;	the Free Software Foundation; either version 2 of the License, or
;	(at your option) any later version.
;
;	This program is distributed in the hope that it will be useful,
;	but WITHOUT ANY WARRANTY; without even the implied warranty of
;	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;	GNU General Public License for more details.
;
;	You should have received a copy of the GNU General Public License along
;	with this program; if not, write to the Free Software Foundation, Inc.,
;	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

; NASM for DOS 

use16

cpu 8086

org 0x100

jmp	BasicInitialize

; common macros

; Exit program and return to DOS with or without errorcode
%imacro Terminate 0-1 0
    mov  		ah, 4ch  
    mov  		al, %1
    int  		0x21
%endmacro

; Return a single byte in AL from a memory location
%imacro MemByte 2
	push 		es
	push 		bx
	mov			bx, %1
	mov			es, bx
	mov			bx, %2
	mov			al, [es:bx]
	pop			bx
	pop			es 
%endmacro

; Return a single word in AX from a memory location
%imacro MemWord 2
	push 		es
	push 		bx
	mov			bx, %1
	mov			es, bx
	mov			bx, %2
	mov			ax, [es:bx]
	pop			bx
	pop			es 
%endmacro

; Macro for Placeholder "dummy" programs not yet developed
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

%imacro WhereXY 0
	mov			ah, 0x03
    mov			bh, al
    int			0x10
	; mov		[CursorXY], dx
%endmacro

%imacro GotoXY 1-2
	mov 	ah, 0x02
	%if %0 = 1
		mov		dl, %1
		mov		dh, %2
	%else
		mov		dx, %1
	%endif
    mov		bh, [VideoPage]
    int		0x10
%endmacro

; Common Data Section
SECTION _DATA

VideoMode:		DB 0
VideoPage:		DB 0
ScreenMax:		DW 0
CursorShape:	DW 0
WindMin:		DW 0
WindMax:		DW 0
TextAttr:		DB 0

; Just Prefixing Here
SECTION _TEXT
BasicInitialize:
	push 		es
	mov			bx, 0x0040
	push		bx
	pop			es
	
	; detect current video mode
	mov			al, [es:0x0049]
	mov			[VideoMode], al
	xor			ah, ah
	
	; detect active video page
	mov			al, [es:0x0062]
	mov			[VideoPage], al
	
	; get current cursor shape and position
	WhereXY
    mov			[CursorShape], cx

	mov			[WindMin], word 0x0000

	mov			bx, [es:0x004A]
	dec			bx
	mov			bh, bl
	mov			bl, [es:0x0084]
	xchg		bl, bh
	mov			[ScreenMax], bx		
	mov			[WindMax], bx
		
	pop			es
	
	; CX is Cursor Shape
	; DX is Cursor Position
	; BX is Screen Max
	