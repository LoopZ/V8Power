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

%include "COMMON.INC"

ProgramMain:
	; WhereXY
	; mov			[CurrentXY], dx
	CommandLineParser       ; insert code for command line parsing
	
	mov			cx, [CurrentXY]
	mov			[WindMin], cx
	mov			dx, [CurrentSize]
	push		dx
	add			dx, cx
	mov			[WindMax], dx
	
	mov			di, [BoxStyle]	
	
	mov			dx, 0x0000
	GotoXY		dx
	pop			dx
	
	call		WriteRow
	dec			dh
	add			di, 3
Vertical:
	dec			dh
	cmp			dh, 0
	je			LastRow
    push		dx
    WhereXY
    mov			dl, 0
    inc			dh
    GotoXY		dx
    pop			dx
	call		WriteRow
	jmp			Vertical
LastRow:
	push		dx
    WhereXY
    mov			dl, 0
    inc			dh
    GotoXY		dx
    pop			dx
	add			di, 3
	call		WriteRow
	mov			dx, 0x0101
	GotoXY		dx
		
	Terminate 0

WriteRow:
	push		dx
	; Top left
    mov         ah, 0x09
    mov			al, [di]
    mov         bh, [VideoPage]
    mov         bl, [BoxAttr]
    mov         cx, 0x0001
    int         0x10
    ; Top Bar
    WhereXY
    inc			dx
    GotoXY		dx
    pop			dx
    push		dx
    mov         ah, 0x09
    mov			al, [di+1]
    mov         bh, [VideoPage]
    cmp			al, 0x20
    mov         bl, [BoxAttr]
    jne			.NotCenter
    mov         bl, [TextAttr]
.NotCenter:
    xor			ch, ch
    mov			cl, dl
    sub			cl, 2
    int         0x10
    pop			dx
    push		dx
    push		dx
    WhereXY
    pop			cx
    mov			dl, cl
    dec			dl
    GotoXY		dx
    ; top right
    mov         ah, 0x09
    mov			al, [di+2]
    mov         bh, [VideoPage]
    mov         bl, [BoxAttr]
    mov         cx, 0x0001
    int         0x10
    pop			dx
    ret

	NumberParameters        ; insert code for number based CmdLn Params    
	LookupParameters        ; insert table lookup code for params    

NoSwitch:
    mov         si, ColorTable
    call        LookupParam
    cmp         ax, 0xffff
    je	        .Error
    call        NumberParam
.Found:
	cmp			ax, BoxHidden
	jne			.NotHiddenBox
	mov			al, [TextAttr]
	and			al, 0xf0
	mov			ah, al
	mov			cl, 4
	shr			al, cl
	or			al, ah
	mov			[BoxAttr], al
	mov			ax, BoxSingle
	mov			[BoxStyle], ax
	ret
.NotHiddenBox:
	cmp			ax, BoxSingle
	je			.NormalBox
	cmp			ax, BoxDouble
	je			.NormalBox
	cmp			ax, BoxDoubleSides
	je			.NormalBox
	cmp			ax, BoxSingleSides
	je			.NormalBox
.NormalBox:
	mov			[BoxStyle], ax		
	mov			al, [TextAttr]
	mov			[BoxAttr], al
	ret
.NotBox:
.Error:
    ret
	
SwitchD:
	
	ret

ColorSwitchHandlers
XYSwitchHandlers
SizeSwitchHandlers

BoxSingle: 			db 0xda,0xc4,0xbf,0xb3,0x20,0xb3,0xc0,0xc4,0xd9
BoxSingleSides:		db 0xd5,0xcd,0xb8,0xb3,0x20,0xb3,0xd4,0xcd,0xbe
BoxDoubleSides:		db 0xd6,0xc4,0xb7,0xba,0x20,0xba,0xd3,0xc4,0xbd
BoxDouble:			db 0xc9,0xcd,0xbb,0xba,0x20,0xba,0xc8,0xcd,0xbc

BoxHidden:			; dummy address to trip modification

BoxStyle:
	dw 	BoxDouble
BoxShown:
	db  0
BoxAttr: 
	db 	0
	
BoxStyleTable:
	TableData "Hidden",			BoxSingle
	TableData "Single", 		BoxSingle
	TableData "Double",			BoxDouble
	TableData "SingleSides",	BoxSingleSides
	TableData "DoubleSides",	BoxDoubleSides
	TableEnd
		
CommandLineSwitches:
	SwitchData  0,  0, NoSwitch  
	ColorSwitchData
	XYSwitchData
	SizeSwitchData
    SwitchData  0,  0, 0
    	