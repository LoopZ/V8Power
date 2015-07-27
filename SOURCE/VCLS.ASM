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


    CommandLineParser		; insert code for command line parsing
    
    mov         ax, 0x0600
    mov         bh, [TextAttr]
    mov         cx, [WindMin]
    mov         dx, [WindMax]
    int         0x10
    GotoXY      cx
    mov			al, [TextAttr]
    xor			ah, ah

    Terminate 0

	NumberParameters		; insert code for number based CmdLn Params    
     
NoSwitch:
SwitchA:
	call		NumberParam	
	mov         [TextAttr], al
	ret
    
SwitchB:
SwitchF:
SwitchP:
SwitchT:
    CommandLineDebug
    
ColorTableData		; insert color name table
    
CommandLineSwitches:
    CmdSwitch  0,  0, NoSwitch  
    CmdSwitch 'A', 1, SwitchA
    CmdSwitch 'F', 1, SwitchF
    CmdSwitch 'B', 1, SwitchB
    CmdSwitch 'T', 0, SwitchT
    CmdSwitch 'P', 0, SwitchP
    CmdSwitch  0,  0, 0
    
    
