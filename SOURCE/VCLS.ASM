; Copyright (C) 2015 Jerome Shidel
;
;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation; either version 2 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License along
;   with this program; if not, write to the Free Software Foundation, Inc.,
;   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

; NASM for DOS

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

MainProgram:
    mov         cx, [WindMin]
    mov         dx, [WindMax]
	mov			al, [TextOnly]
	cmp			al, 1
	je			.ClearTextOnly
    mov         ax, 0x0600
    mov         bh, [TextAttr]
    int         0x10
    jmp			.Done
.ClearTextOnly:
	sub			dh, ch
	sub			dl, cl
	xchg		cx, dx
	inc 		cl
	inc			ch
	xor			dx, dx
.ClearTextLoop:
	GotoXY		dx
	mov			ax, 0x0a20
	mov			bh, [VideoPage]
	xor			bl, bl
	push		cx
	xor			ch, ch
	int			0x10
	pop			cx
	inc			dh
	dec			ch
	cmp			ch, 0
	jne			.ClearTextLoop
    mov         cx, [WindMin]	
		
.Done:
    GotoXY      cx	
    Terminate 0

    NumberParameters        ; insert code for number based CmdLn Params    
    LookupParameters        ; insert table lookup code for params    
     
NoSwitch:
	; NoSwitch falls through to SwitchA
	ColorSwitchHandlers		; Procedures for handling color switches.

SwitchP:
	UseFrameBounds
	ret
	
SwitchT:
	mov			al, 1
	mov			[TextOnly], al
    ret
    
ColorTableData      ; insert color name table
    
CommandLineSwitches:
    SwitchData  0,  0, NoSwitch      
    ColorSwitchData
    SwitchData 'T', 0, SwitchT
    SwitchData 'P', 0, SwitchP
    SwitchData  0,  0, 0
    
TextOnly: 
	DB 0
