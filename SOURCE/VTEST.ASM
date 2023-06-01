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
%idefine sfExpFirst	0000000000000001b ; 0x0001
%idefine sfExpSecond	0000000000000010b ; 0x0002

%idefine sfExpOR	0000000000000100b ; 0x0004
%idefine sfExpAND	0000000000001000b ; 0x0008
%idefine sfExpCMP	0000000000010000b ; 0x0010

%idefine sfCaseSpecific 0000000000100000b ; 0x0020
%idefine sfCaseLess 	0000000001000000b ; 0x0040
%idefine sfNOT		0000000010000000b ; 0x0080

%idefine sfPending	0000000100000000b ; 0x0100

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
	; call		ProcessOpt

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
		Debug_Text	'EXIT:'
		Debug_Word	[STATUS]
		Debug_Char	','
		Debug_Byte	[RESULT.FINAL]
		Debug_CRLF
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
	; options that can call "DoFuntions"
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
	; Options without "DoFunctions"
	OptSwitch 	'AND',	OnExpEval
	OptSwitch 	'OR',	OnExpEval
	OptSwitch 	'C',	OnExpCase
	OptSwitch 	'I',	OnExpIgnore
	OptSwitch 	'NOT',	OnExpNOT
	OptSwitch 	'H',	SwitchHelp
	OptSwitch 	'TF',	OnTrueFalse
	OptTableEnd

DoFunctions:
	; must maintain option index order, position and count of subfunctions
	; in OptionTable that may call these "Do Compare" functions.
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
; Debug stuff to be removed later

%imacro	Debug_Status 0
%ifdef DEBUG
	pushf
	Debug_Text '{ LAST='
	Debug_Word [LAST_OPT]
	Debug_Text '; '

	test	[STATUS], byte sfExpFirst
	jz	%%NotExpFirst
	Debug_Text 'sfExpFirst '
%%NotExpFirst:
	test	[STATUS], byte sfExpSecond
	jz	%%NotExpSecond
	Debug_Text 'sfExpSecond '
%%NotExpSecond:

	test	[STATUS], byte sfExpOR
	jz	%%NotExpOR
	Debug_Text 'sfExpOR '
%%NotExpOR:
	test	[STATUS], byte sfExpAND
	jz	%%NotExpAND
	Debug_Text 'sfExpAND '
%%NotExpAND:
	test	[STATUS], byte sfExpCMP
	jz	%%NotExpCMP
	Debug_Text 'sfExpCMP '
%%NotExpCMP:

	test	[STATUS], byte sfCaseSpecific
	jz	%%NotCaseSpecific
	Debug_Text 'CaseSpecific '
%%NotCaseSpecific:
	test	[STATUS], byte sfCaseLess
	jz	%%NotCaseLess
	Debug_Text 'CaseLess '
%%NotCaseLess:

	test	[STATUS], byte sfNOT
	jz	%%NotNOT
	Debug_Text 'NOT '
%%NotNOT:

	Debug_Char '}'
	Debug_CRLF
	popf
%endif
%endmacro

%imacro Debug_Strings 0
%ifdef DEBUG
	pushf
	push		dx
	push		bx
	push		ax
	push		cx
	xor		cx, cx
	call		%%Show
	call		%%Show
	jmp		%%Done

%%Show:
	mov		ax, cx
	call		VALUE_OFFSET
	mov		ax, [bx+TVALUE.DTYPE]
	test		ax, ax
	je		%%DoneShow

	Debug_Text 	'{ '
	test		ax, stDir
	jz		%%NotDir
	Debug_Text 	'Dir, '
%%NotDir:
	test		ax, stFile
	jz		%%NotFile
	Debug_Text 	'File, '
%%NotFile:
	test		ax, stNumber
	jz		%%NotNumber
	Debug_Text 	'Value:0x'
	Debug_Word 	[bx+TVALUE.NUMBER+6]
	Debug_Word 	[bx+TVALUE.NUMBER+4]
	Debug_Word 	[bx+TVALUE.NUMBER+2]
	Debug_Word 	[bx+TVALUE.NUMBER+0]
	Debug_Text	', '
%%NotNumber:
	Debug_Text 	'String:"'
	Debug_ASCIIZ	bx
	Debug_Text	'" }', 0x0d,0x0a
%%DoneShow:
	inc		cx
	ret

%%Done:
	pop		cx
	pop		ax
	pop		bx
	pop		dx
	popf
%endif
%endmacro

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
	Debug_Status
	mov		ax, 0	; String 0

	call		VALUE_CLEAR	; IN: AX=String number, out BX=Offset
	call		STORE_STRING	; copies SI->BX, updates DI for Parser
	test		cx, cx		; Char Count updated by STORE_STRING
	jz		.NoValue
	call		NUMBER_VALUE

.NoValue:
	Debug_Strings

; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------

OnDoneSwitch:
	mov		[LAST_OPT], dx
	clc
	ret

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

OnTrueFalse:
	; does not set ANY_OPTS
	mov	[SHOW_RESULT], byte TRUE
	ret

; -----------------------------------------------------------------------------

OnTest:
	jmp	OnDoneSwitch

; -----------------------------------------------------------------------------

OnExpCase:
	test	[STATUS], byte sfExpFirst + sfExpSecond
	jz	OnExpModError
	test	[STATUS], byte sfCaseLess
	jnz	OnExpModError
	or	[STATUS], byte sfCaseSpecific
	xor	dx, dx
	jmp	OnDoneSwitch

OnExpIgnore:
	test	[STATUS], byte sfExpFirst + sfExpSecond
	jz	OnExpModError
	test	[STATUS], byte sfCaseSpecific
	jnz	OnExpModError

	or	[STATUS], byte sfCaseless
	xor	dx, dx
	jmp	OnDoneSwitch

OnExpNOT:
	test	[STATUS], byte sfExpFirst + sfExpSecond
	jz	OnExpModError
	xor	[STATUS], byte sfNOT
	xor	dx, dx
	jmp	OnDoneSwitch

OnExpModError:
	mov	dx, MESSAGE.SYNTAX
	jmp	OnError

; -----------------------------------------------------------------------------

OnExpEval:
	jmp	OnDoneSwitch

; -----------------------------------------------------------------------------

OnCompare:
	jmp	OnDoneSwitch


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
	push		dx
	mov		bx, TVALUE_size
	mul		bx
	add		ax, VALUES
	mov		bx, ax
	pop		dx
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
; copy string from SI to BX. Single / or < space terminates copy. Double / is
; copied as single /. On return: DI updated to new next position for parser. SI
; is end of saved string. CX is new length
	mov		di, bx
	mov		[di+TVALUE.DTYPE], byte stText
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
.Done:
	pop		di
	ret

; -----------------------------------------------------------------------------

	Int64_Procs
	HelpSwitchHandler 'vtest'

; -----------------------------------------------------------------------------

section .data

; -----------------------------------------------------------------------------

LAST_OPT:		dw 0

STATUS:			dw sfExpOR + sfExpFirst

RESULT:
	.FINAL:		db FALSE
	.PENDING:	db FALSE

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
	.ITEM0:		resb TVALUE_size
	.ITEM1:		resb TVALUE_size

BSS_END:
	resw 1