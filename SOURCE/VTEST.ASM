; Copyright (C) 2023 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%idefine DEBUG

%define INT64_STRICT_ASCII	; non-valid number chars (like SPACE) generate
				; a conversion error.

%define INDEXED_OPTIONS		; automatically created define indexes for
				; parser option switches.

%include "COMMON.INC"
%include "INT64.INC"

; -----------------------------------------------------------------------------
; Operation and processing state flags

; STATUS - Flags
%idefine sfExpStart	00000001b

%idefine sfExpOR	00000010b
%idefine sfExpAND	00000100b
%idefine sfExpCMP	00001000b

%idefine sfCaseSpecific 00010000b
%idefine sfCaseLess 	00100000b
%idefine sfNOT		10000000b

; String data type
%idefine stText		00000001b ; Text String
%idefine stNumber	00000010b ; Text/Number
%idefine stFile		00000100b ; File name
%idefine stDir		00001000b ; Directory Name
%idefine stFileOrDir	00001100b ; FIle or Directory name

; Internal TRUE/FALSE
%idefine TRUE  1
%idefine FALSE 0

; -----------------------------------------------------------------------------

%define MAX_LEN	256	; really only needs to be 126.

struc TVALUE
	.ASCII:		resb MAX_LEN + 1 ; String as ASCIIZ
	.DTYPE:		resw 1		; String data type
	.NUMBER:	resq 1		; 64-bit value when it is a number
endstruc

; -----------------------------------------------------------------------------
; Under DOS at startup, assume:
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
	jc		.ExitError

	; no error processing, check if all requirements are satisfied
	cmp		[STATUS], word 0
	jne		.Unhappy
	cmp		[LAST_OPT], word 0
	je		.Satisfied
.Unhappy:
	mov		[RESULT.PENDING], byte FALSE
	call		ProcessOpt

.Satisfied:
	; Exit Code 0=True, 1=False. Opposite of internal TRUE/FALSE
	xor		[RESULT.FINAL], byte TRUE
.ExitError:
	cmp		[SHOW_RESULT], byte 0
	je		.Done
	mov		dx, MESSAGE.FALSE
	cmp		[RESULT.FINAL], byte 1
	je		.ExitMessage
	mov		dx, MESSAGE.TRUE
	jb		.ExitMessage
	mov		dx, MESSAGE.ERROR
.ExitMessage:
	test		dx, dx
	jz		.Done
	mov		ah, 0x09
	int		0x21
	call		NewLine
.Done:
	%ifdef DEBUG
		mov		ax, [STATUS]
		StdOutHexWord   ax
		mov		al, ','
		StdOutChar	al
		mov		al, [RESULT.FINAL]
		StdOutHexByte   al
		StdOutCRLF
	%endif
	Terminate 	[RESULT.FINAL]

; -----------------------------------------------------------------------------

NewLine:
	mov		ah, 0x02
	mov		dl, 0x0d
	int		0x21
	mov		dl, 0x0a
	int		0x21
	ret

; -----------------------------------------------------------------------------

Options:
	OptTable 	OnText, OnInvalid, MAIN
	OptSwitch 	'EQ',	OnCompare	; switch index 1
	OptSwitch 	'NE',	OnCompare	; switch index 2
	OptSwitch 	'GE',	OnCompare	; switch index 3
	OptSwitch 	'LE',	OnCompare	; switch index 4
	OptSwitch 	'GT',	OnCompare	; switch index 5
	OptSwitch 	'LT',	OnCompare	; switch index 6
	OptSwitch	'F',	OnTest
	OptSwitch 	'D',	OnTest
	OptSwitch 	'E',	OnTest
	OptSwitch 	'N',	OnTest
	OptSwitch 	'Z',	OnTest
	OptSwitch 	'V',	OnTest
	OptSwitch 	'AND',	OnExpEval
	OptSwitch 	'OR',	OnExpEval
	OptSwitch 	'C',	OnExpMod
	OptSwitch 	'I',	OnExpMod
	OptSwitch 	'NOT',	OnExpMod
	OptSwitch 	'H',	SwitchHelp
	OptSwitch 	'TF',	OnTrueFalse
	OptTableEnd

Functions:
	; must maintain index order
	dw DoOptFn_EQ
	dw DoOptFn_NE
	dw DoOptFn_GE
	dw DoOptFn_LE
	dw DoOptFn_GT
	dw DoOptFn_LT
	dw DoOptFn_F
	dw DoOptFn_D
	dw DoOptFn_E
	dw DoOptFn_N
	dw DoOptFn_Z
	dw DoOptFn_V

; -----------------------------------------------------------------------------

HelpSwitchHandler 'vtest'

; -----------------------------------------------------------------------------

OnInvalid:	; not a valid switch
	mov		dx, MESSAGE.INVALID

OnError:
	mov		ah, 0x09
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
	mov		dx, MESSAGE.ENDQUOTE
	int		0x21
	mov		[RESULT.FINAL], byte 100
	call		NewLine
	stc		; abort processing
	ret

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
	mov		ax, 0	; String 0
	push		di
	call		VALUE_CLEAR
	mov		di, bx
	call		STORE_STRING	; copies SI->DI, updates DI
	pop		ax		; was di
	; if waiting on string, assume null string
	; do something here
	; if string was null and ends at command line end, ignore blank spaces.
	test		cx, cx
	jnz		.NotNullString
	xchg		ax, di
	%ifdef DEBUG
		Debug_Char	'~'
	%endif
	cmp		[di], byte 0x20
	xchg		ax, di
	jae		.IsNullString
	cmp		[LAST_OPT], word 0
	jne		.IsNullString
	; ignore null string
	clc
	ret
.IsNullString:
	mov		al, FALSE
	jmp		.Convert
.NotNullString:
	mov		al, TRUE

.Convert:
	mov	[RESULT.PENDING], al
	%ifdef DEBUG
		Debug_Char	'"'
		Debug_AsciiZ	bx
		Debug_Char	'"'
	%endif
	call		NUMBER_VALUE	; convert record at BX to number

ProcessOpt:
	%ifdef DEBUG
		Debug_Char '?'
	%endif
	cmp		[LAST_OPT], word 0
	je		OnDoneText
	%ifdef DEBUG
		Debug_Char '*'
		Debug_Word [LAST_OPT]
	%endif

; -----------------------------------------------------------------------------

OnDoneText:
	mov		al, [RESULT.PENDING]
	cmp		[ANY_OPTS], byte TRUE
	je		.PreviousTests
	mov		[RESULT.FINAL], al
	jmp		.Done
.PreviousTests:
.Done:
	xor		dx, dx
	%ifdef DEBUG
		Debug_Char 	'['
		jmp		SetLastOpt.PrintDone
	%endif

; -----------------------------------------------------------------------------

SetLastOpt:
%ifdef DEBUG
	Debug_Char 	'['
	Debug_Char 	'/'
.PrintSwitch:
	lodsb
	Debug_Char	 al
	loop		.PrintSwitch
.PrintDone:
	Debug_Char 	':'
	Debug_Word	dx
.NotOperator:
	Debug_Char 	']'
	Debug_CRLF
%endif

; -----------------------------------------------------------------------------

OnDoneSwitch:
	mov		[LAST_OPT], dx
	mov		[ANY_OPTS], byte TRUE
	clc
	ret
; -----------------------------------------------------------------------------

OnTrueFalse:
	; does not set ANY_OPTS
	mov	[SHOW_RESULT], byte TRUE
	ret

; -----------------------------------------------------------------------------

OnTest:
	jmp	SetLastOpt

; -----------------------------------------------------------------------------

OnExpMod:
	test	[STATUS], byte sfExpStart
	jz	.Error
	mov	al, sfCaseSpecific
	cmp	dx, MAIN_OPTION_C
	je	.SetMod
	mov	al, sfCaseLess
	cmp	dx, MAIN_OPTION_I
	je	.SetMod
	mov	al, sfNOT
	%ifdef DEBUG
		cmp	dx, MAIN_OPTION_NOT
		je	.SetMod
		jmp	OnInvalid
	%endif
.SetMod:
	or	[STATUS], al
;	xor	dx, dx
	jmp	OnDoneSwitch
.Error:
	mov	dx, MESSAGE.SYNTAX
	jmp	OnError

; -----------------------------------------------------------------------------

OnExpEval:
	jmp	SetLastOpt

; -----------------------------------------------------------------------------

OnCompare:
	jmp	SetLastOpt


; -----------------------------------------------------------------------------

DoOptFn_EQ:
DoOptFn_NE:
DoOptFn_GE:
DoOptFn_LE:
DoOptFn_GT:
DoOptFn_LT:
DoOptFn_F:
DoOptFn_D:
DoOptFn_E:
DoOptFn_N:
DoOptFn_Z:
DoOptFn_V:
	ret

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
	rep		stosb
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
	mov		[bx+TVALUE.DTYPE], byte stNumber
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

LAST_OPT:		dw 0

ANY_OPTS:		db FALSE	; True once any command line options
					; are processed.

STATUS:			dw sfExpStart + sfExpOR

RESULT:
	.FINAL:		db FALSE
	.PENDING:	db FALSE
	.WAITING:	db FALSE

SHOW_RESULT:		db TRUE	; FALSE

MESSAGE:
	.TRUE:		db 	'TRUE$'
	.FALSE:		db 	'FALSE$'
	.ERROR:		db	'ERROR$'
	.ENDQUOTE:	db	0x22,'.$'
	.INVALID:	db	'Invalid option ',0x22,SWITCH_CHAR,'$'
	.SYNTAX:	db	'Syntax error ',0x22,SWITCH_CHAR,'$'

; -----------------------------------------------------------------------------

section .bss

; -----------------------------------------------------------------------------
BSS_START:

VALUES:
	.ARRAY:	resb TVALUE_size * 2

BSS_END:
	resw 1