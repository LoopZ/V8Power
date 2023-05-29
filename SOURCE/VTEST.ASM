; Copyright (C) 2023 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%idefine DEBUG

%define INT64_STRICT_ASCII	; non-valid number chars (like SPACE) generate
				; a conversion error.

%include "COMMON.INC"
%include "INT64.INC"

; -----------------------------------------------------------------------------
; Operation and processing state flags

; STATUS - Low Byte
%idefine sfNone		00000000b ; Initial startup state
%idefine sfReqFile	00000001b ; File name required
%idefine sfReqDir	00000010b ; Directory path required
%idefine sfReqFileOrDir 00000011b ; File name or Directory path required
%idefine sfReqString	00000100b ; String required
%idefine sfReqNumber	00001000b ; Number required
%idefine sfReqValue	00001100b ; String or Number required
%idefine sfReqExp	00010000b ; Expression required

; STATUS - High Byte
%idefine sfHaveStrA	00000001b ; String is pending
%idefine sfHaveStrB	00000010b ; String can be processed as a number

; Internal TRUE/FALSE
%idefine TRUE  1
%idefine FALSE 0

; -----------------------------------------------------------------------------

%define MAX_LEN	256	; really only needs to be 126.

struc TVALUE
	.ASCII:		resb MAX_LEN + 1 ; String as ASCIIZ
	.FLAGS:		resw 1		; Value Status Flags
	.NUMBER:	resq 1		; 64-bit value when it is a number
endstruc

; -----------------------------------------------------------------------------
; Under DOS, assume at startup
; MOV 	DS, CS
; MOV	ES, CS
; MOV   SS, CS
; MOV   SP, 0xfffe	(0x0000 is on stack for RET to exit call in PSP)
; CLD

Main:
	; Initialize BSS Data
	mov	cx, (BSS_END - BSS_START + 1) / 2
	mov	di, BSS_START
	xor	ax, ax
	rep	stosw

	ParseOptions 	Options
	jc		.Done
	; no error processing, check if all requirements are satisfied

	; check for missing requirement
	cmp		[STATUS], byte 0
	jz		.Satisfied

.Satisfied:
	%ifdef DEBUG
		mov	dx, .FalseStr
		test	[EXIT_CODE], byte 1
		jz	.PrintResult
		mov	dx, .TrueStr
		jmp	.PrintResult
	.TrueStr:
		db 	'TRUE',0x0d,0x0a,'$'
	.FalseStr:
		db 	'FALSE',0x0d,0x0a,'$'
	.PrintResult:
		mov	ah, 0x09
		int	0x21
	%endif
	; Exit Code 0=True, 1=False. Opposite of internal TRUE/FALSE
	xor		[EXIT_CODE], byte TRUE
.Done:
	%ifdef DEBUG
		mov		ax, [STATUS]
		StdOutHexWord   ax
		mov		al, ','
		StdOutChar	al
		mov		al, [EXIT_CODE]
		StdOutHexByte   al
		StdOutCRLF
	%endif
	Terminate 	[EXIT_CODE]

; -----------------------------------------------------------------------------

Options:
	OptTable 	OnText, OnInvalid
	OptSwitch 	'EQ',	OnCompare	; switch index 1
	OptSwitch 	'NE',	OnCompare	; switch index 2
	OptSwitch 	'GE',	OnCompare	; switch index 3
	OptSwitch 	'LE',	OnCompare	; switch index 4
	OptSwitch 	'GT',	OnCompare	; switch index 5
	OptSwitch 	'LT',	OnCompare	; switch index 6
	OptSwitch 	'H',	SwitchHelp
	OptSwitch	'F',	OnFileExist
	OptSwitch 	'D',	OnDirExist
	OptSwitch 	'E',	OnExists
	OptSwitch 	'N',	OnIsString
	OptSwitch 	'Z',	OnNullString
	OptSwitch 	'V',	OnIsNumber
	OptSwitch 	'C',	OnCaseSpecific
	OptSwitch 	'I',	OnIgnoreCase
	OptSwitch 	'AND',	OnExpressionAND
	OptSwitch 	'OR',	OnExpressionOR
	OptSwitch 	'NOT',	OnExpressionNOT
	; OptSwitch 	SWITCH_CHAR, OnDoubleSwitch
	OptTableEnd

; -----------------------------------------------------------------------------

HelpSwitchHandler 'vtest'

; -----------------------------------------------------------------------------

OnInvalid:	; not a valid switch
	mov		ah, 0x09
	mov		dx, .Message1
	int		0x21
	test		cx, cx
	jz		.PrintDone
	mov		ah, 0x02
.Printing:
	lodsb
	mov		dl, al
	int		0x21
	loop		.Printing
.PrintDone:
	mov		ah, 0x09
	mov		dx, .Message2
	int		0x21
	mov		[EXIT_CODE], byte 100
	stc		; abort processing
	ret
.Message1:
	db	'Invalid option ',0x22,SWITCH_CHAR,'$'
.Message2:
	db	0x22,'.',0x0d,0x0a,'$'

; -----------------------------------------------------------------------------
; Parser calls these sub-functions with the following registers set.
;
; BX=Address of sub-function, (used for the actual call)
; CX=Param Length
; SI=Param Start
; DI=Next Param
; DX=1+ index of switch in table
;
; On return to the parser. DS must be preserved and Direction flag must be
; clear. DI will be used as a "continue from" starting point. Other registers
; may be destroyed. If Carry Flag is set, the parser will abort.
; -----------------------------------------------------------------------------

OnText:
	mov		ax, [VALUES.INDEX]
	call		VALUE_CLEAR
	mov		di, bx
	call		STORE_STRING	; copies SI->DI, updates DI
	%ifdef DEBUG
		Debug_Char	'"'
		Debug_AsciiZ	bx
		Debug_Char	'"'
	%endif
	call		NUMBER_VALUE	; convert record at BX to number

; -----------------------------------------------------------------------------

OnDoneText:
	clc 				; continue processing
	ret

; -----------------------------------------------------------------------------

OnDoneSwitch:
	clc 				; continue processing
	ret

; -----------------------------------------------------------------------------

OnDoubleSwitch:
	; backup one and handle as text
	dec	si
	jmp	OnText

OnFileExist:
OnDirExist:
OnExists:
OnIsString:
OnNullString:
OnIsNumber:
OnCaseSpecific:
OnIgnoreCase:
OnExpressionAND:
OnExpressionOR:
OnExpressionNOT:
OnCompare:
	Debug_Char 	'['
	Debug_Char 	'/'
.PrintSwitch:
	lodsb
	Debug_Char	 al
	loop		.PrintSwitch
	Debug_Char 	':'
	mov		ax, dx
	StdOutHexWord 	ax
	Debug_Char 	']'
	Debug_CRLF
	jmp		OnDoneSwitch

; -----------------------------------------------------------------------------

VALUE_OFFSET:
; Returns offset address of a VALUE buffer
; IN:  AX=Value Buffer Index
; OUT: BX=Value Buffer offset
	push		ax
	mov		bx, TVALUE_size
	mul		bx
	add		ax, VALUES.ARRAY
	mov		bx, ax
	pop		ax
	ret

; -----------------------------------------------------------------------------

VALUE_CLEAR:
; Zeros a VALUE buffer
; IN:  AX=Value Buffer Index
; OUT: BX=Value Buffer offset
	push		ax
	push		cx
	push		di
	call		VALUE_OFFSET
	mov		cx, TVALUE_size
	mov		di, bx
	xor		al, al
	; rep		stosb
	pop		di
	pop		cx
	pop		ax
	ret

; -----------------------------------------------------------------------------

STORE_STRING:
; copy string from SI to DI. Single / or < space terminates copy. Double / is
; copied as single /. On return: DI updated to new next position. SI is end of
; saved string. CX is new length
	jcxz		.CopyDone
	xor		cx, cx
.Copy:
	lodsb
	cmp		al, 0x20
	jb		.Trim
	cmp		al, SWITCH_CHAR
	jne		.NotSwitch
	lodsb
	cmp		al, SWITCH_CHAR
	je		.NotSwitch	; is // so "escaped /"
	dec		si		; back up one char
	jmp		.Trim
.NotSwitch:
	stosb
	inc		cx
	jmp		.Copy
.Trim:
	jcxz		.CopyDone
	cmp		[di-1], byte 0x20
	jne		.CopyDone
	dec		di
	dec		cx
	jmp		.Trim
.CopyDone:
	xor		al, al
	stosb
	dec		si	; back up to termination character
	xchg		di, si
	ret

; -----------------------------------------------------------------------------

NUMBER_VALUE:
	push		di
	mov		si, bx
	mov		di, bx
	add		di, TVALUE.NUMBER
	ASCII_sInt64	di, si
	jc		.Done
.Success:
	mov		[bx+TVALUE.FLAGS], byte 1
	%ifdef DEBUG
		Debug_Char 	':'
		mov		ax, [bx+TVALUE.NUMBER+6]
		StdOutHexWord 	ax
		mov		ax, [bx+TVALUE.NUMBER+4]
		StdOutHexWord 	ax
		mov		ax, [bx+TVALUE.NUMBER+2]
		StdOutHexWord 	ax
		mov		ax, [bx+TVALUE.NUMBER+0]
		StdOutHexWord 	ax
	%endif
.Done:
	%ifdef DEBUG
		Debug_CRLF
	%endif
	pop		di
	ret

; -----------------------------------------------------------------------------

	Int64_Procs

; -----------------------------------------------------------------------------

section .data

; -----------------------------------------------------------------------------

STATUS:		dw sfReqExp

EXIT_CODE:	db FALSE

; -----------------------------------------------------------------------------

section .bss

; -----------------------------------------------------------------------------
BSS_START:

VALUES:
	.INDEX:	resw 1
	.ARRAY:	resb TVALUE_size * 2

BSS_END:
	resw 1