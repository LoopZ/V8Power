
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

%imacro FindFirst 2
	push   	dx
	push	cx
	mov     ah, 1Ah         ;Set DTA
	lea     dx, %1
	int     21h
	; xor     cx, cx          ;No attributes.
	mov		cx, 0ffffh
	lea     dx, %2
	mov     ah, 4Eh         ;Find First File
	int     21h
	pop   	cx
	pop		dx
%endmacro

%imacro FindNext 0
	push 	ax
	mov     ah, 4Fh         ;Find Next File
	int     21h
	pop  	ax
%endmacro

%imacro IsValidDrive 1		; Test is removable, fails if not valid
		mov  		ax, 0x4408
		mov			bl, %1
		int			0x21
		jc			%%Error
		xor			ax, ax
		jmp			%%Done
    %%Error:
		mov			al, erNotValid	; Invalid Drive Number
		mov			[ExitCode], al		
    %%Done:
%endmacro

%imacro DiskFree 1			; Get Disk free space, fails if not formatted
		mov		ah, 0x36
		mov		dl, %1
		int		0x21
		cmp		ax, 0xffff
		je		%%Error
		clc
		jmp		%%Done
	%%Error:
		stc
	%%Done:
%endmacro

%imacro IsFormatted 1
		GetIntVec	0x24, SavedInt24
		push	ds
		mov		dx, MyInt24
		mov		ax, 0x2524
		int		0x21
		pop		ds
		
		xor		al, al
		mov		[ErrorCode], al
		
		mov		al, %1
		add		al, 0x40
		mov		[%%FileName], al
 
		FindFirst [%%DTA], [%%FileName]
        jc      	%%Error
    %%NoError:
		xor		ax, ax
		jmp		%%Done
        
	%%FileName: 
		DB '?:\*.*',0

	%%DTA: 
		times 23 DD 0

    %%Error:
		mov			al, 1
		mov			[ExitCode], al
    	mov			ax, erNotPartitioned
 
	%%Done:
		push		ax
		SetIntVec 0x24, SavedInt24
		pop			ax

%endmacro

%imacro GetIntVec 2
	push	es
	mov		al, %1
	mov		ah, 0x35
	int		0x21
	mov		[%2], bx
	mov		bx, es
	mov		[%2 + 2], bx
	pop		es
%endmacro

%imacro SetIntVec 2
	push	ds
	mov		dx, [cs:%2+2]
	mov		ds, dx
	mov		dx, [cs:%2]
	mov		al, %1
	mov		ah, 0x25
	int		0x21
	pop		ds
%endmacro

%imacro Floppies 0 ; BIOS Function
		int		0x11
		test	al, 0x01
		jz   	%%NoFloppies
		xor		ah, ah
		and		al, 0xc0
		mov		cl, 0x06
		shr		ax, cl
		inc		ax
		jmp		%%Done
    %%NoFloppies:
		xor		ax, ax
    @@Done:
%endmacro

MyInt24:
	push	ax
	mov		ax, di
	mov		[cs:ErrorCode], al
	pop		ax
	mov		al, 0x03		
	iret
	
ErrorCode:
	dw 0