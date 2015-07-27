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

; PROJECTED -- Some options have not been implemented
; Clears screen 
; usage: vcls [options]
; 
; /A nn			Set Text Attribute to hex value.
; /F color		Set Foreground Color.
; /B color		Set Background Color.
; /T			Clear text only, leave colors.
; /P			Only clear current area, not entire screen.


%include "COMMON.INC"

; Command line parser
; CommandLineSwitches label must exit
; it will call functions listed as DB Character, 0/1 Needs Param; DW Address
; first is no switch, last is 0,0,0
; on call dl is switch character, cx is data length, di is start of data, 
; si is end of data.
%imacro CommandLine 0
	cld
	xor			bx, bx
	mov			di, si
%%Loop:
	lodsb
	cmp			al, 0x0d
	je			%%Next
	cmp			al, 0x22
	je			%%Quote
	cmp			al, 0x27
	je			%%Quote
	cmp			al, 0x60
	je			%%Quote	
	cmp			al, 0x20
	je			%%Next
	cmp			al, "/"
	je			%%Switch
	jmp			%%Loop
%%Quote:
	mov			ah, al
%%QuoteLoop:
	lodsb
	cmp			al, 0x0d
	je			%%Error
	cmp			al, ah
	jne			%%QuoteLoop
	jmp			%%Loop
%%Next:
	push		ax
	mov			cx, si
	sub			cx, di
	cmp			cx, 1
	push		cx
	jle			%%Skip
	cmp			al, 0x0d
	jne			%%NotEnd
	dec			si
	dec			cx
%%NotEnd:
	push 		si
	cmp			al, 0x20
	jne			%%NotSpace
	dec			si
	dec			cx
%%NotSpace:
	cmp			bx, 0
	jne			%%NotDefault
	mov	 		bx, [CommandLineSwitches + 2]
	xor			dl, dl
%%NotDefault:
	call 		bx
	pop  		si
%%Skip:
	pop			cx
	pop			ax
	cmp			al, 0x0d
	je			%%Done
	cmp			al, 0x20
	jne			%%ResetBX
	cmp			cx, 1
	push		cx
	jle			%%KeepBX
%%ResetBX:	
	xor			bx, bx
%%KeepBX:
	mov			di, si
	jmp			%%Loop
%%Switch:
	mov			di, si
	lodsb
	cmp			al, '/'
	jl			%%Error
	cmp			al, 0x61
	jl			%%CaseOK
	cmp			al,	0x7a
	jg			%%CaseOK
	sub			al, 0x20
%%CaseOK:
	mov	 		bx, CommandLineSwitches
%%Lookup:
	add			bx, 4
	mov			cx, [bx]
	cmp			cl, 0
	je			%%Error
	cmp			cl, al
	jne			%%Lookup
	mov			dx, [bx + 2]
	mov			bx, dx
	cmp			ch, 0
	jne			%%NeedsParam
	xor 		cx, cx
	push		si
	mov			dl, al
	call		[bx]
	xor			bx,bx	
	pop			si
	mov			di, si
	jmp			%%Loop
%%NeedsParam:
	mov			dl, al
	mov			di, si
	jmp			%%Loop
%%ErrorMsg:	
	DB 			"Error parsing command-line options.",CRLF,0
%%Error:
	WriteStr	%%ErrorMsg
	Terminate	100
%%Done:
	cmp			bx, 0
	jne			%%Error
%endmacro

 CommandLine
	
	mov			ax, 0x0600
	mov			bh, [TextAttr]
	mov			cx, [WindMin]
	mov			dx, [WindMax]
;	int			0x10
;	GotoXY		cx

	Terminate 0
	
NoSwitch:
SwitchA:
SwitchB:
SwitchF:
SwitchP:
SwitchT:
	push 	cx
	cmp		dl, 0
	je		.NoSwitch
	push	dx
	mov		al, '-'
	WriteChar
	pop		dx
	mov		al, dl
	WriteChar
.NoSwitch:
	mov		al, '('
	WriteChar
	pop		cx
.Repeat:
	push	cx
	mov		al, [di]
	WriteChar
	pop		cx
	inc		di
	loop	.Repeat
	mov		al, ')'
	WriteChar
	ret

NoSwitchMsg:
	DB	"Plain Text"
NewLine:
	DB	CRLF,0
	
CommandLineSwitches:
	CmdSwitch  0,  0, NoSwitch	
	CmdSwitch 'A', 1, SwitchA
	CmdSwitch 'F', 1, SwitchF
	CmdSwitch 'B', 1, SwitchB
	CmdSwitch 'T', 0, SwitchT
	CmdSwitch 'P', 0, SwitchP
	CmdSwitch  0,  0, 0
