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
	WhereXY
	mov			[CurrentXY], dx
	CommandLineParser       ; insert code for command line parsing
	GotoXY 		[CurrentXY]
	Terminate 0

NoSwitch:	
    LookupParam	OptionalTable
	jmp			DoWhatNow
	
SwitchQ:
    LookupParam	QueryTable

DoWhatNow:
    cmp         ax, 0xffff
    je         	.NotFound
    jmp			ax
.NotFound:
	WriteStr	CommandLineErrorMsg
	Terminate 	100
	ret
	
XYSwitchHandlers
LocalSwitchHandlers

WhereXProc:
	mov			al, [CurrentXY]
	jmp			WhereOutProc
WhereYProc:
	mov			al, [CurrentXY+1]
WhereOutProc:
	inc			al
	StdOutHexByte
	StdOutCRLF
	ret
	
OptionSol:
	mov			al, 0
	mov			[CurrentX], al
	ret
	
OptionEol:
	mov			al, [WindMaxX]
	mov			ah, [WindMinX]
	sub			al, ah
	mov			[CurrentX], al
	ret
		
OptionSop:
	xor			ax, ax
	mov			[CurrentXY], ax
	ret
	
OptionEop:
	mov			ax, [WindMax]
	mov			bx, [WindMin]
	sub			ah, bh
	sub			al, bl
	mov			[CurrentXY], ax
	ret
	
OptionSot:
OptionEot:
	ret
	
OptionUp:
	mov			al, [CurrentY]
	cmp			al, 0
	je			OptionNoMove
	dec			al
	mov			[CurrentY], al
	ret
	
OptionDown:
	mov			ah, [WindMaxY]
	mov			al, [WindMinY]
	sub			ah, al
	mov			al, [CurrentY]
	cmp			al, ah
	jge			OptionNoMove
	inc			al
	mov			[CurrentY], al
	ret

OptionLeft:
	mov			al, [CurrentX]
	cmp			al, 0
	je			OptionNoMove
	dec			al
	mov			[CurrentX], al
	ret

OptionRight:
	mov			ah, [WindMaxX]
	mov			al, [WindMinX]
	sub			ah, al
	mov			al, [CurrentX]
	cmp			al, ah
	jge			OptionNoMove
	inc			al
	mov			[CurrentX], al
	ret
	ret
	
OptionNoMove:
	ret
	
CommandLineSwitches:
	SwitchData  0,  0, NoSwitch  
	SwitchData 'Q', 1, SwitchQ
	XYSwitchData
	LocalSwitchData
    SwitchData  0,  0, 0
    
QueryTable:
	TableData "X", WhereXProc
	TableData "WHEREX", WhereXProc
	TableData "Y", WhereYProc
	TableData "WHEREY", WhereYProc
	TableEnd	

OptionalTable:
    TableData "SOL",OptionSol
    TableData "EOL",OptionEol
    TableData "SOP",OptionSop
    TableData "EOP",OptionEop
    TableData "SOT",OptionSot
    TableData "EOT",OptionEot
    TableData "UP",OptionUp
    TableData "DOWN",OptionDown
    TableData "LEFT",OptionLeft
    TableData "RIGHT",OptionRight
    TableEnd
	