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

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

	mov		ax, [OptionProcessed]
	cmp		ax, 0xffff
	jne		Done

	PlaceHolder 

Done:
    Terminate 0

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
    
NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je	        .NotOption
    mov			[OptionProcessed], ax
	jmp			ax	    

.NotOption:
	NumberParam
	; do something with ax
	
.InvalidOption:
	WriteStr	CommandLineErrorMsg
	Terminate	100
    
CommandLineSwitches:
	SwitchData  0,  0, NoSwitch  
    SwitchData  0,  0, 0
    
OptionsTable:
%ifdef ASCII_Table
	TableData "ASCII", ShowAscii
%endif
	TableEnd
	
OptionProcessed:
	dw 0xffff