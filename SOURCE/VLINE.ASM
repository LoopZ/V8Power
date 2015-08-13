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

    FrameBounds

	SetMaxSize

	WhereXY
	mov		[CurrentXY], dx
    mov		[Position], dx
    xor		dl, dl
    GotoXY  dx
    xor		ax, ax
    mov		[CurrentH], al
    
    CommandLineParser       ; insert code for command line parsing
    
    mov		al, [LineStyle]
    cmp		al, 0
    jne		.NotHidden
    mov		al, [TextAttr]
    and		al, 0xf0
    mov		ah, al
    mov		cl, 4
    shr		al, cl
    or		al, ah
    mov		[TextAttr], al
    
.NotHidden:
    xor		ch, ch
    mov		cl, [CurrentW]
    cmp		cl, 0
    je		Vertical
    
Horizontal:
	push	cx
	mov		bh, [VideoPage]
	mov		dx, [CurrentXY]
	mov		ax, [WindMin]
	add		dh, ah
	add		dl, al
	mov		ah, 0x02
	int		0x10
	mov		ah, 0x09
	mov		bl, [TextAttr]
	mov		al, 0xc4
	int 	0x10	
	pop		cx
    mov		dx, [Position]
    xor		dl, dl
    inc		dh
    mov		cx, [ScreenMax]
    cmp		dh, ch
    jge		Done
    mov		[Position], dx
	jmp		Done
	
Vertical:
    mov		cl, [CurrentH]
    cmp		cl, 0
    je		Done

Done:
    mov		dx, [Position]
    GotoXY	dx
    Terminate 0
    
NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je	        .NotOption
	jmp			ax	    

.NotOption:
	NumberParam
	; do something with ax
	
.InvalidOption:
	WriteStr	CommandLineErrorMsg
	Terminate	100

ColorSwitchHandlers
XYSwitchHandlers
SizeSwitchHandlers

OptHidden:
	mov		al, 0
	mov		[LineStyle], al
	mov		[LineEnds], al
	ret
	
OptSingle:
	mov		al, 1
	mov		[LineStyle], al
	ret
	
OptDouble:
	mov		al, 2
	mov		[LineStyle], al
	ret

OptEnds:
	mov		al, 1
	mov		[LineEnds], al
	ret
OptNoEnds:
	mov		al, 0
	mov		[LineEnds], al
	ret
	   
CommandLineSwitches:
	SwitchData  0,  0, NoSwitch  
	ColorSwitchData
	XYSwitchData
	SizeSwitchData
    SwitchData  0,  0, 0
    
OptionsTable:
	TableData "HIDE",			OptHidden
	TableData "HIDDEN",			OptHidden
	TableData "SINGLE", 		OptSingle
	TableData "DOUBLE",			OptDouble
	TableData "ENDS",			OptEnds
	TableData "NOENDS",			OptNoEnds
	TableEnd
	
Position:
	dw 0
LineStyle:
	db 0
LineEnds:
	db 1