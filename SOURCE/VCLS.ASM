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

NoSwitch:
	; NoSwitch falls through to SwitchA
	ColorSwitchHandlers		; Procedures for handling color switches.
	LocalSwitchHandlers		; Procedures for handling local and global relations.
	
SwitchT:
	mov			al, 1
	mov			[TextOnly], al
    ret
        
CommandLineSwitches:
    SwitchData  0,  0, NoSwitch      
    ColorSwitchData
    SwitchData 'T', 0, SwitchT
    LocalSwitchData
    SwitchData  0,  0, 0
    
TextOnly: 
	DB 0
