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

%idefine ASCII_Table

; /D n exit codes
;	0 - A-OK
;	1 - Not This OS Version (Later)
;   2 - Not This OS (Later)
;   3 - Not Formatted
; 	4 - Not Partitioned
;   5 - Not Readable/Error
;   6 - Not Present

%include "COMMON.INC"
	
    CommandLineParser       ; insert code for command line parsing

	mov		ax, [OptionProcessed]
	cmp		ax, 0xffff
	jne		Done

	PlaceHolder 

Done:
	mov			al, [ExitCode]
    Terminate 	al

%ifdef ASCII_Table    
ShowAscii:
	mov			al, 0x20
	WriteChar	0x09
	WriteChar	0x09
	WriteChar	0x09
	WriteChar	0x09
	WriteChar	0x09
	mov			bx, 0x30
	
.ShowAscii_1:
	push		bx
	mov			al, 0x20
	WriteChar	0x09
	mov			al, '+'
	WriteChar	0x09
	mov			al, 0x30
	WriteChar	0x09
	pop			bx
	push		bx
	mov			al, bl
	WriteChar	0x09
	pop			bx
	inc			bx
	cmp			bx, 0x3a
	jne			.ShowAscii_2
	add			bx, 0x27
.ShowAscii_2:
	cmp			bx, 0x67
	jne			.ShowAscii_1
	xor			bx, bx
.ShowAscii_3:
	push		bx
	WriteStr	.ShowAscii_CRLF
	pop			bx
	push		bx
	mov			ax, bx
	StdOutHexByte			; Dos output not BIOS output. Don't Care.
	mov			al, 0x20
	WriteChar	0x09
	
	pop			bx
	xor			cx, cx
.ShowAscii_4:
	push		bx
	push		cx
	mov			ax, bx
	add			ax, cx
	push		ax
	mov			al, 0x20
	WriteChar	0x09
	WriteChar	0x09
	WriteChar	0x09
	pop			ax
	WriteChar	0x09
	pop			cx
	pop			bx
	inc			cx
	cmp			cx, 0x10
	jne			.ShowAscii_4
	add			bx, cx
	cmp			bx, 0x100
	jl			.ShowAscii_3
	ret
.ShowAscii_CRLF:
	db  		CRLF,0
%endif

ShowQuery:
	mov			al, 1
	mov			[QueryMode], al
	ret
	
%imacro IsValidDrive 1
		mov  		ax, 0x4408
		mov			bl, %1
		int			0x21
		jc			%%Error
		xor			ax, ax
		jmp			%%Done
    %%Error:
		mov			al, 0x0f	; Invalid Drive Number
		mov			[ExitCode], al		
    %%Done:
%endmacro
		
SwitchC:
	ret
	
SwitchD:
	mov		al, [di]
	xor		ah, ah
	cmp		ax, 0x5e
	jl		.NotLowercase
	sub		ax, 0x20
.NotLowercase:
	cmp		ax, 0x41
	jl		InvalidOption
	cmp		ax, 0x5a
	jg		InvalidOption
	sub		ax, 0x40
	mov		[Drive], al
	IsValidDrive [Drive]
	; ax = 0, At least it is exists and partitioned
	cmp		ax, 0
	je		.DriveExists
	; Drive not found, so se if a hard drive actually exists
	
.DriveExists:
	ret
	
NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je	        .NotOption
    mov			[OptionProcessed], ax
	jmp			ax	    

.NotOption:
	NumberParam
	; do something with ax
	
InvalidOption:
	WriteStr	CommandLineErrorMsg
	Terminate	100
    
CommandLineSwitches:
	SwitchData  0,  0, NoSwitch
	SwitchData  'D', 1, SwitchD
	SwitchData  'C', 0, SwitchC
    SwitchData  0,  0, 0
    
OptionsTable:
%ifdef ASCII_Table
	TableData "ASCII", ShowAscii
%endif
	TableData "QUERY", ShowQuery
	TableEnd
	
MsgInvalidDrive:
	db 'Invalid Drive',CRLF,0
	
OptionProcessed:
	dw 0xffff
QueryMode:
	db	0
ExitCode:
	db  0
	
Drive:
	db 0
	
