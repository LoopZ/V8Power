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


    CommandLineParser
    
    mov         ax, 0x0600
    mov         bh, [TextAttr]
    mov         cx, [WindMin]
    mov         dx, [WindMax]
    int         0x10
    GotoXY      1, 1

    Terminate 0
    
NoSwitch:
SwitchA:
    xor         bh, bh
    xor         ax, ax
    cmp         cx, 0
    je          .BadHex
    cmp         cx, 2
    jle         .MakeHex
.BadHex:
    WriteStr    MsgInvalidHex
    Terminate   100
.MakeHex:
    push        cx
    mov         cl, 4
    shl         ax, cl
    pop         cx
    mov         bl, [di]
    inc         di
    cmp         bl, 0x30
    jl          .BadHex
    cmp         bl, 0x39
    jg          .NotNumber
    sub         bl, 0x30
    jmp         .Adjusted
.NotNumber:
    cmp         bl, 0x41
    jl          .BadHex
    cmp         bl, 0x46 ; 5a is Z
    jg          .NotUpper
    sub         bl, 0x37
    jmp         .Adjusted
.NotUpper:
    cmp         bl, 0x61
    jl          .BadHex
    cmp         bl, 0x66 ; 7a is z
    jg          .BadHex
    sub         bl, 0x57
.Adjusted:
    add         ax, bx
    loop        .MakeHex
    mov         [TextAttr], al
    ret     
    
SwitchB:
SwitchF:
SwitchP:
SwitchT:
    CommandLineDebug
    
NoSwitchMsg:
    DB  "Plain Text"
NewLine:
    DB  CRLF,0
    
CommandLineSwitches:
    CmdSwitch  0,  0, NoSwitch  
    CmdSwitch 'A', 1, SwitchA
    CmdSwitch 'F', 1, SwitchF
    CmdSwitch 'B', 1, SwitchB
    CmdSwitch 'T', 0, SwitchT
    CmdSwitch 'P', 0, SwitchP
    CmdSwitch  0,  0, 0
    
MsgInvalidHex:
    DB  "Invalid hexidecimal number for color attribute.",CRLF,0
