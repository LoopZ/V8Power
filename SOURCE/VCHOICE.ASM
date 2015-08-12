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
	WhereXY
    mov			al, [TextAttr]
    or			al, 0x08
    mov			[SelectedAttr], al
    and			al, 0x77
    mov			[NotAttr], al
    mov			al, [TextAttr]
    not			al
    and			al, 0x7f
    mov			[HotAttr], al

	mov			[Position], dx
	mov			ax, [WindMin]
	mov			[OptionBox], ax
	mov			ax, [WindMax]
	mov			[OptionBox + 2], ax
	
	mov			di, CountChoice
	call 		EachChoice
	
    CommandLineParser       ; insert code for command line parsing
    
	AllocTempVideoPage 
	
    mov			al, [TextAttr]
    mov			[SelectedAttr], al
    
KeyBoardLoop:
	mov			di, SelectChoice
	call 		EachChoice
	mov			bl, [Selected]
	mov			[LastSelected], bl
	mov			bl, [HotChoice]
	mov			[LastHot], bl
WaitLoop:
	mov			ax, 0x0100
	int			0x16
	jz			WaitLoop
	mov			ax, 0x0000
	int			0x16
	cmp			ah, 0x48
	je			.GoUp
	cmp			ah, 0x50
	je			.GoDown
	cmp			al, 0x20
	je			.Select
	cmp			al, 0x0d
	je			.Chosen
	xor			ax, ax
	; StdOutHexWord
	jmp			Done
	
.GoUp:
	mov			al, [HotChoice]
	cmp			al, 1
	jle			KeyBoardLoop
	dec			al
	mov			[HotChoice], al
	jmp KeyBoardLoop
	
.GoDown:
	mov			al, [HotChoice]
	mov			ah, [Max]
	cmp			al, ah
	jge			KeyBoardLoop
	inc			al
	mov			[HotChoice], al
	jmp KeyBoardLoop
.Select:
	mov			al, [HotChoice]
	mov			[Selected], al
	jmp KeyBoardLoop
.Chosen:
	mov			al, [HotChoice]
	mov			[Selected], al
	xor			al, al
	mov			[HotChoice], al
	mov			di, SelectChoice
	call 		EachChoice
	mov			al, [Selected]
    
Done:
	push		ax
	mov			dx, [Position]
	GotoXY		dx
	
	FreeTempVideoPage
	pop			ax
	Terminate 	al

EachChoice:
	mov			cl, [OptionBox + 3]
	mov			ch, [OptionBox + 1]
	sub			cl, ch
	inc			cl
	xor			ch, ch
	xor			dx, dx
	xor			bx, bx
.CountLoop:
	push		cx
	push		dx
.CheckLoop:
	push		bx
	GotoXY		dx
	mov			ah, 0x08
	mov			bh, [VideoPage]
	int			0x10
	pop			bx
	xor			ch, ch
	mov			cl, al
	cmp			cx, 0x21
	jl			.Missing
	cmp			cx, 0xad
	jg			.Missing
	inc			bx
	call		di
	jmp			.Found
.Missing:
;	mov			cx, [NotAttr]
;	cmp			ch, 0
;	jne			.NotAttrSet
;	mov			cl, ah
;	inc			ch
;	mov			[NotAttr], cx
;.NotAttrSet:
	inc			dl
	mov			cl, [OptionBox + 2]
	mov			ch, [OptionBox + 0]
	sub			cl, ch
	cmp			dl, cl
	jle			.CheckLoop
.Found:
	pop			dx
	pop			cx
	inc			dh
	loop		.CountLoop
	ret

CountChoice:
	mov			al, [Max]
	inc			al
	mov			[Max], al
	ret

CopyFromTempVideoProc

SelectChoice:
	push		bx
	push		dx
	mov			cl, [OptionBox + 2]
	mov			ch, [OptionBox + 0]
	sub			cl, ch
	inc			cl
	xor			ch, ch

	mov			bh, [VideoPage]
	xor			dl, dl
	mov			al, [HotChoice]
	cmp			al, bl
	je			.IsHot
	mov			al, [Selected]
	cmp			al, bl
	jne			.NotThis
	mov			bl, [SelectedAttr]
	mov			ax, [TempVideoPagePtr]
	cmp			ax, 0
	je			.ChangeLoop
	xor			ah, ah
	mov			al, bl
	mov			bx, [WindMin]
	add			dl, bl
	add			dh, bh
	call		CopyFromTempVideo
	jmp			.Done	
.IsHot:
	mov			bl, [HotAttr]
	mov			ax, [TempVideoPagePtr]
	cmp			ax, 0
	je			.ChangeLoop
	xor			ah, ah
	mov			al, bl
	mov			bx, [WindMin]
	add			dl, bl
	add			dh, bh
	call		CopyFromTempVideo
	jmp			.Done	
.NotThis:
	push		ax
	mov			ax, [TempVideoPagePtr]
	cmp			ax, 0
	pop			ax
	je			.Restore
	mov			al, [LastHot]
	cmp			al, bl
	je			.Restore
	mov			al, [LastSelected]
	cmp			al, bl
	jne			.Done
.Restore:
	mov			bl, [NotAttr]
	mov			ax, [TempVideoPagePtr]
	cmp			ax, 0
	je			.ChangeLoop
	xor			ax, ax
	mov			bx, [WindMin]
	add			dl, bl
	add			dh, bh
	call		CopyFromTempVideo
	jmp			.Done	
.ChangeLoop:
	push		cx
	push		bx
	GotoXY		dx
	pop			bx
	push		bx
	mov			ah, 0x08
	int			0x10
	pop			bx
	mov			ah, 0x09
	mov			cx, 0x0001
	int			0x10
	pop			cx
	inc			dl
	loop		.ChangeLoop
.Done:
	pop			dx
	pop			bx
	ret
	
; Switches
	ColorSwitchHandlers
	
SwitchT:
	NumberParam
	mov			[TimeOut], ax
	ret
SwitchD:
	mov			al, [di]
	cmp         al, 0x61
	jl          .NotLower
	cmp         al, 0x7a
	jg          .NotLower
	sub         al, 0x20
.NotLower:
	cmp         al, 0x41
	jl          .NotUpper
	cmp         al, 0x5a
	jg          .NotUpper
	sub         al, 0x40
	jmp			ValidateD
.NotUpper:	
	NumberParam
ValidateD:
	mov			ah, [Max]
	cmp			al, ah
	jle			.Done
	mov			al, ah
.Done:
	mov			[Selected], al
	ret

OptNone:
	mov			al, 0
	mov			[SelectChars], al
	ret
OptAuto:
	mov			al, 1
	mov			[SelectChars], al
	ret	
OptAlpha:
	mov			al, 2
	mov			[SelectChars], al
	ret
OptNumber:
	mov			al, 3
	mov			[SelectChars], al
	ret
OptYesNo:
	mov			al, 4
	mov			[SelectChars], al
	ret
	ret	

NoSwitch:
	LookupParam StyleTable
	cmp			ax, 0xffff
	je			.Error
	jmp			ax
.Error:
	WriteStr    CommandLineErrorMsg
	Terminate	100
	
CommandLineSwitches:
	SwitchData  0,  0, NoSwitch  
	SwitchData  'D',  1, SwitchD
	SwitchData  'T',  1, SwitchT
	ColorSwitchData
    SwitchData  0,  0, 0

StyleTable:
	TableData 'NONE', OptNone
	TableData 'AUTO', OptAuto
	TableData 'FIRST', OptAuto
	TableData 'ALPHA', OptAlpha
	TableData 'LETTER', OptAlpha
	TableData 'NUMBER', OptNumber
	TableData 'DIGIT', OptNumber
	TableData 'YN', OptYesNo
	TableData 'YES', OptYesNo
	TableData 'YESNO', OptYesNo
	TableEnd

TimeOut:
	dw 0	
SelectChars:
	db 1
Max: 
	db 0
Selected:
	db 1
LastSelected:
	db 0
HotChoice:
	db 0
LastHot:
	db 0
SelectedAttr:
	db 0
HotAttr:
	db 0
NotAttr:
	dw 0
Position:
	dw  0
OptionBox:
	dw 0,0
