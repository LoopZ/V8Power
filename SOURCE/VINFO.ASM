
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

%idefine ASCII_Table

; /D n exit codes
;	0 - A-OK
;   1 - Not First HDD
;   2 - Removable
;   3 - Is CDRom
;   4 - Network
;   5 - Not Formatted / Invalid Format
;	6 - Not Active Partition
;   7 - Not Primary Partition
; 	8 - Not Partitioned
;   9 - Not Readable/Error
;   15 - Not Present

%idefine erNotValid 0x0f
%idefine erNotReadable 0x09
%idefine erNotPartitioned 0x08
%idefine erNotPrimary 0x07
%idefine erNotActive 0x06
%idefine erNotFormatted 0x05
%idefine erIsNetwork 0x04
%idefine erIsCDROM 0x03
%idefine erIsRemovable 0x02
%Idefine erNotFirstHDD 0x01
%idefine erNone 0x00

%include "COMMON.INC"
	
    CommandLineParser       ; insert code for command line parsing

	mov		ax, [OptionProcessed]
	cmp		ax, 0xffff
	jne		Done

	; PlaceHolder 

Done:
	mov			al, [ExitCode]
    Terminate 	al

%include "VDOS.INC"

%ifdef ASCII_Table
ShowAscii:
	mov			al, 0x20
	WriteChar	0x09
	WriteChar	0x09
	WriteChar	0x09
	WriteChar	0x09
	WriteChar	0x09
	mov			bx, 0x30
	
.ShowAscii_1:
	push		bx
	mov			al, 0x20
	WriteChar	0x09
	mov			al, '+'
	WriteChar	0x09
	mov			al, 0x30
	WriteChar	0x09
	pop			bx
	push		bx
	mov			al, bl
	WriteChar	0x09
	pop			bx
	inc			bx
	cmp			bx, 0x3a
	jne			.ShowAscii_2
	add			bx, 0x27
.ShowAscii_2:
	cmp			bx, 0x67
	jne			.ShowAscii_1
	xor			bx, bx
.ShowAscii_3:
	push		bx
	WriteStr	.ShowAscii_CRLF
	pop			bx
	push		bx
	mov			ax, bx
	StdOutHexByte			; Dos output not BIOS output. Don't Care.
	mov			al, 0x20
	WriteChar	0x09
	
	pop			bx
	xor			cx, cx
.ShowAscii_4:
	push		bx
	push		cx
	mov			ax, bx
	add			ax, cx
	push		ax
	mov			al, 0x20
	WriteChar	0x09
	WriteChar	0x09
	WriteChar	0x09
	pop			ax
	WriteChar	0x09
	pop			cx
	pop			bx
	inc			cx
	cmp			cx, 0x10
	jne			.ShowAscii_4
	add			bx, cx
	cmp			bx, 0x100
	jl			.ShowAscii_3
	ret
.ShowAscii_CRLF:
	db  		CRLF,0
%endif

SwitchQ:
	mov			al, 0
	mov			[QueryMode], al
	ret
SwitchV:
	mov			al, 1
	mov			[QueryMode], al
	ret
		
SwitchD:

	mov		al, [di]
	xor		ah, ah
	cmp		ax, 0x5e
	jl		.NotLowercase
	sub		ax, 0x20
.NotLowercase:
	cmp		ax, 0x41
	jl		InvalidOption
	cmp		ax, 0x5a
	jg		InvalidOption
	sub		ax, 0x40
	mov		[Drive], al
	
	cmp		al, 3
	jnl		.NotFloppy
	
	Floppies
	mov		bl, al
	mov		al, [Drive]
	cmp		al, bl
	jg		.BadDriveLetter
.NotFloppy:
	IsValidDrive [Drive]
	; ax = 0, At least it is exists and partitioned
	cmp		ax, 0
	je		.DriveExists
	; Drive not found, so se if a hard drive actually exists
	
	; Test Drive just not partitioned
	
.BadDriveLetter:
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	mov			al, erNotValid
	mov			[ExitCode], al
	WriteStr  	MsgInvalidDrive
	jmp			.Done
.DriveExists:
	IsFormatted	[Drive]
	cmp			ax, 0
	jne			.FormatError
	; Fails if it is partitioned but is not formatted.
	; Check Drive Type
	IsCDROM		[Drive]
	cmp			al, 0x01
	je			.IsCDROM
	IsNetwork	[Drive]
	cmp			al, 0x01
	je			.IsRemote
	IsRemovable	[Drive]
	cmp			al, 0x01
	je			.IsRemovable
	
	; Test Active and Primary
	
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgDriveReady
	jmp			.Done
.IsCDROM:
	mov			al, erIsCDROM
	mov			[ExitCode], al
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgCDROM
	jmp			.Done
.IsRemovable:
	mov			al, erIsRemovable
	mov			[ExitCode], al
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgRemovable
	jmp			.Done
.IsRemote:
	mov			al, erIsNetwork
	mov			[ExitCode], al
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgRemote
	jmp			.Done
.NotPartitioned:
	mov			al, erNotPartitioned
	mov			[ExitCode], al
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgNotPartitioned
	jmp			.Done
.NotPrimary:
	mov			al, erNotPrimary
	mov			[ExitCode], al
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgNotPrimary
	jmp			.Done
.NotActive:
	mov			al, erNotActive
	mov			[ExitCode], al
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgNotActive
	jmp			.Done
.NotReadable:
	mov			al, erNotReadable
	mov			[ExitCode], al
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgNotReadable
	jmp			.Done
.NotFirstHDD:
	mov			al, erNotFirstHDD
	mov			[ExitCode], al
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgNotFirstHDD
	jmp			.Done
.FormatError:
	mov			al, erNotFormatted
	mov			[ExitCode], al
	mov			al, [QueryMode]
	cmp			al, 1
	jne			.Done
	WriteStr	MsgDriveNotFormated
.Done:
	ret
	
NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je	        .NotOption
    mov			[OptionProcessed], ax
	jmp			ax	    

.NotOption:
	NumberParam
	; do something with ax
	
InvalidOption:
	WriteStr	CommandLineErrorMsg
	Terminate	100
    
CommandLineSwitches:
	SwitchData  0,  0, NoSwitch
	SwitchData  'D', 1, SwitchD
	SwitchData  'V', 0, SwitchV
	SwitchData  'Q', 0, SwitchQ
    SwitchData  0,  0, 0
    
OptionsTable:
%ifdef ASCII_Table
	TableData "ASCII", ShowAscii
%endif
	TableEnd
	
MsgInvalidDrive:
	db 'Invalid drive letter',CRLF,0
MsgNotReadable:
	db 'Drive not readable`',CRLF,0
MsgNotPartitioned:
	db 'Drive not partitioned',CRLF,0
MsgNotPrimary:
	db 'Drive not primary',CRLF,0
MsgNotActive:
	db 'Drive not active',CRLF,0
MsgCDROM:
	db	'Drive is CD/DVD-ROM',CRLF,0
MsgRemote:
	db 'Drive is remote',CRLF,0
MsgRemovable:
	db	'Drive is removable',CRLF,0
MsgDriveNotFormated:
	db 'Drive not formatted',CRLF,0
MsgNotFirstHDD:
	db 'Drive is not disk 0',CRLF,0
MsgDriveReady:
	db 'Drive is ready',CRLF,0
	
OptionProcessed:
	dw 0xffff
QueryMode:
	db	0
ExitCode:
	db  0
SavedInt24:
	dw 0, 0	
Drive:
	db 0
	
