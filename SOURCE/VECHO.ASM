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

    CommandLineParser       ; insert code for command line parsing

ProgramMain:
	mov			al, [NoNewLine]
	cmp			al, 0
	jne			Done
	WriteStr 	CRLFString
Done:
    Terminate 0
    
    NumberParameters        ; insert code for number based CmdLn Params    
    LookupParameters        ; insert table lookup code for params    
     
NoSwitch:
	xor 		al, al
	mov			[si], al
	WriteStr	di
	ret

SwitchN:
	mov			al, 1
	mov			[NoNewLine], al
	ret

	ColorSwitchHandlers
    
CommandLineSwitches:
	SwitchData  0,  0, NoSwitch  
	ColorSwitchData
	SwitchData	'N', 0, SwitchN
    SwitchData  0,  0, 0

CRLFString:
	db	CRLF,0
	
NoNewLine:
	db 0