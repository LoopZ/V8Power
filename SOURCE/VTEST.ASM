; Copyright (C) 2023 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%idefine DEBUG

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

	Int64_Procs

; -----------------------------------------------------------------------------

Options:
	OptTable 	OnText, OnInvalid
	OptSwitch 	'H',	SwitchHelp
	OptSwitch	'F',	OnF
	OptSwitch 	'D',	OnD
	OptSwitch 	'E',	OnE
	OptSwitch 	'EQ',	OnEQ
	OptSwitch 	'NE',	OnNE
	OptSwitch 	'GE',	OnGE
	OptSwitch 	'LE',	OnLE
	OptSwitch 	'GT',	OnGT
	OptSwitch 	'LT',	OnLT
	OptSwitch 	'N',	OnN
	OptSwitch 	'Z',	OnZ
	OptSwitch 	'V',	OnV
	OptSwitch 	'C',	OnC
	OptSwitch 	'I',	OnI
	OptSwitch 	'AND',	OnAND
	OptSwitch 	'OR',	OnOR
	OptSwitch 	'NOT',	OnNOT
	OptSwitch 	SWITCH_CHAR, OnDoubleSwitch
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
;
; On return to the parser. DS must be preserved and Direction flag must be
; clear. DI will be used as a "continue from" starting point. Other registers
; may be destroyed. If Carry Flag is set, the parser will abort.
; -----------------------------------------------------------------------------

OnText:
	; Set BX to offset of Active value string buffer
	mov		ax, [VALUES.INDEX]
	call		VALUE_CLEAR
	mov		di, bx
	call		COPY_STRING

; -----------------------------------------------------------------------------

OnDoneText:
	clc 						; continue processing
	ret

; -----------------------------------------------------------------------------

OnDoneSwitch:
	clc 						; continue processing
	ret

; -----------------------------------------------------------------------------

OnDoubleSwitch:
	; backup one and handle as text
	dec	si
	jmp	OnText

OnF:
OnD:
OnE:
OnEQ:
OnNE:
OnGE:
OnLE:
OnGT:
OnLT:
OnN:
OnZ:
OnV:
OnC:
OnI:
OnAND:
OnOR:
OnNOT:
	Debug_Char 	'['
	Debug_Char 	'/'
.PrintSwitch:
	lodsb
	Debug_Char	 al
	loop		.PrintSwitch
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

COPY_STRING:
; copy string from SI to DI. Single / or < space terminates copy. Double / is
; copied as single /. on return: SI & DI updated to new next position.
	test		cx, cx
	jz		.CopyDone
.Copy:
	lodsb
	cmp		al, 0x20
	jb		.CopyDone
	cmp		al, SWITCH_CHAR
	jne		.NotSwitch
	lodsb
	cmp		al, SWITCH_CHAR
	je		.NotSwitch	  ; is // so "escaped /"
	dec		si
	jmp		.CopyDone
.NotSwitch:
	stosb
	Debug_Char	al
	jmp		.Copy
.CopyDone:
	xor		al, al
	stosb
	dec		si	; back up one
	Debug_CRLF
	mov		di, si
	ret

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