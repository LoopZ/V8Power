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

; PROJECTED -- Some options have not been implemented
; Clears screen 
; usage: vcls [options]
; 
; /A nn         Set Text Attribute to hex value. (or no switch)
; /F color      Set Foreground Color.
; /B color      Set Background Color.
; /T            Clear text only, leave colors.
; /P            Only clear current area, not entire screen.


%include "COMMON.INC"


    CommandLineParser       ; insert code for command line parsing
    
    mov         ax, 0x0600
    mov         bh, [TextAttr]
    mov         cx, [WindMin]
    mov         dx, [WindMax]
   	int         0x10
   	GotoXY      cx

    Terminate 0

    NumberParameters        ; insert code for number based CmdLn Params    
  	LookupParameters		; insert table lookup code for params    
     
NoSwitch:
SwitchA:
    call        NumberParam 
    mov         [TextAttr], al
    ret
    
    
SwitchColor:
	mov			si, ColorTable
	call		LookupParam
	cmp			ax, 0xffff
	jne			.Found
	call		NumberParam
.Found:
	ret
	
SwitchF:
	call		SwitchColor
	mov			ah, [TextAttr]
	and			ah, 0xf0
	or			ah, al
	mov			[TextAttr], ah
	ret

SwitchB:
	call		SwitchColor
	mov			ah, [TextAttr]
	mov			cl, 4
	shl			al, cl
	and			ah, 0x0f
	or			ah, al
	mov			[TextAttr], ah
	ret

SwitchP:
SwitchT:
 ;   CommandLineDebug
 	ret
    
ColorTableData      ; insert color name table
    
CommandLineSwitches:
    CmdSwitch  0,  0, NoSwitch  
    CmdSwitch 'A', 1, SwitchA
    CmdSwitch 'F', 1, SwitchF
    CmdSwitch 'B', 1, SwitchB
    CmdSwitch 'T', 0, SwitchT
    CmdSwitch 'P', 0, SwitchP
    CmdSwitch  0,  0, 0
    
    
