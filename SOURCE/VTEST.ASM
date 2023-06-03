; Copyright (C) 2023 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%define DEBUG

%define INT64_STRICT_ASCII	; non-valid number chars (like SPACE) generate
				; a conversion error.

%define INDEXED_OPTIONS		; automatically created define indexes for
				; parser option switches.

%include "COMMON.INC"
%include "INT64.INC"

; -----------------------------------------------------------------------------
; Operation and processing state flags

; STATUS - Flags
%idefine sfNeedCMP	00000001b ; 0x0001 ; AND,OR or string compare required

%idefine sfExpOR	00000100b ; 0x0004 ; OR expression results
%idefine sfExpAND	00001000b ; 0x0008 ; AND expression results

%idefine sfCaseSpecific 00100000b ; 0x0020 ; string case sensitive compare
%idefine sfCaseLess 	01000000b ; 0x0040 ; string ignore case compare
%idefine sfNOT		10000000b ; 0x0080 ; invert expression result

; String data type
%idefine stText		00000001b ; Text String
%idefine stNumber	00000010b ; Text/Number
%idefine stFile		00000100b ; File name
%idefine stDir		00001000b ; Directory Name
%idefine stFileOrDir	00001100b ; File or Directory name
%idefine stTrue		10000000b ; Evaluated result for string is true

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
	Debug_TextLn	'END'
	jc		.ExitError

	; process pending last command line test, comparison, etc.
	call		OnEvaluate
	call		DoFn_AND_OR
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
		call	EXIT_STATUS_PROC
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
	OptSwitch 	'AND',	OnExpAND
	OptSwitch 	'OR',	OnExpOR
	OptSwitch 	'C',	OnExpCase
	OptSwitch 	'I',	OnExpIgnore
	OptSwitch 	'NOT',	OnExpNOT
	OptSwitch 	'H',	SwitchHelp
	OptSwitch 	'TF',	OnTrueFalse
	OptTableEnd

DoFunctions:
	; must maintain option index order, position and count of sub-functions
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

%ifdef DEBUG

%macro DBGIDXOPT 2
	cmp		[LAST_OPT], word %1
	jne		%%NotThis
	Debug_Text	%2
	jmp		.EndLast
%%NotThis:
%endmacro

DEBUG_STATUS_PROC:
	pushf
	Debug_Text '  { LAST=0x'
	Debug_Word [LAST_OPT]
	Debug_Text 	' ('

	DBGIDXOPT	00, 'null'
	DBGIDXOPT	MAIN_OPTION_EQ, 'EQ'
	DBGIDXOPT	MAIN_OPTION_NE, 'NE'
	DBGIDXOPT	MAIN_OPTION_GE, 'GT'
	DBGIDXOPT	MAIN_OPTION_LE, 'LE'
	DBGIDXOPT	MAIN_OPTION_GT, 'GT'
	DBGIDXOPT	MAIN_OPTION_LT, 'LT'
	DBGIDXOPT	MAIN_OPTION_F,  'F'
	DBGIDXOPT	MAIN_OPTION_D,  'D'
	DBGIDXOPT	MAIN_OPTION_E,  'E'
	DBGIDXOPT	MAIN_OPTION_N,  'N'
	DBGIDXOPT	MAIN_OPTION_Z,  'Z'
	DBGIDXOPT	MAIN_OPTION_V,  'V'
	Debug_Text	'ERROR'

.EndLast:
	Debug_Text 	'); '

	test	[STATUS], byte sfNeedCMP
	jz	.NotNeedCMP
	Debug_Text 'sfNeedCMP '
.NotNeedCMP:

	test	[STATUS], byte sfExpOR
	jz	.NotExpOR
	Debug_Text 'sfExpOR '
.NotExpOR:
	test	[STATUS], byte sfExpAND
	jz	.NotExpAND
	Debug_Text 'sfExpAND '
.NotExpAND:

	test	[STATUS], byte sfCaseSpecific
	jz	.NotCaseSpecific
	Debug_Text 'CaseSpecific '
.NotCaseSpecific:
	test	[STATUS], byte sfCaseLess
	jz	.NotCaseLess
	Debug_Text 'CaseLess '
.NotCaseLess:

	test	[STATUS], byte sfNOT
	jz	.NotNOT
	Debug_Text 'NOT '
.NotNOT:

	Debug_TextLn '}'
	popf
	ret

DEBUG_STRINGS_PROC:
	pushf
	push		dx
	push		bx
	push		ax
	push		cx
	xor		cx, cx
	call		.Show
	call		.Show
	jmp		.Done

.Show:
	mov		ax, cx
	mov		bx, VALUES.ITEM0
	test		ax, ax
	jz		.BXisSet
	mov		bx, VALUES.ITEM1
.BXisSet:
	mov		ax, [bx+TVALUE.DTYPE]
	test		ax, ax
	je		.DoneShow

	Debug_Text 	'  { '
	test		ax, stDir
	jz		.NotDir
	Debug_Text 	'Dir, '
.NotDir:
	test		ax, stFile
	jz		.NotFile
	Debug_Text 	'File, '
.NotFile:
	test		ax, stNumber
	jz		.NotNumber
	Debug_Text 	'Value:0x'
	Debug_Word 	[bx+TVALUE.NUMBER+6]
	Debug_Word 	[bx+TVALUE.NUMBER+4]
	Debug_Word 	[bx+TVALUE.NUMBER+2]
	Debug_Word 	[bx+TVALUE.NUMBER+0]
	Debug_Text	', '
.NotNumber:
	Debug_Text 	'String.'
	Debug_Byte	cl
	Debug_Text	':"'
	Debug_ASCIIZ	bx
	Debug_TextLn	'" }'
.DoneShow:
	inc		cx
	ret

.Done:
	pop		cx
	pop		ax
	pop		bx
	pop		dx
	popf
	ret

EXIT_STATUS_PROC:
	Debug_Text 'EXIT: 0x'
	Debug_Byte [RESULT.FINAL]
	Debug_Text ' ('
	%ifdef DEBUG
		cmp	[RESULT.FINAL], byte 0
		jz	.PrintTrue
		Debug_Text 'false'
		jmp	.Printed
	.PrintTrue:
		Debug_Text 'true'
	.Printed:
	%endif
	Debug_TextLn ')'
	call DEBUG_STRINGS_PROC
	call DEBUG_STATUS_PROC
	ret
%endif

%imacro	Debug_Status 0
	%ifdef DEBUG
		call DEBUG_STATUS_PROC
	%endif
%endmacro

%imacro Debug_Strings 0
	%ifdef DEBUG
		call DEBUG_STRINGS_PROC
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
	Debug_TextLn	'OnText: '


.StringSelected:
	call		SHOVE_VALUE	; ITEM0->ITEM1, ITEM0 Cleared
	call		STORE_VALUE	; copies SI->ITEM0, updates DI for Parser

	cmp		[LAST_OPT], word 0
	jne		OnEvaluate
	mov		[LAST_OPT], word MAIN_OPTION_N	; string not null

OnEvaluate:
	Debug_Strings
	Debug_Status
	Debug_TextLn	'OnEvaluate: '
	mov		bx, [LAST_OPT]
	test		bx, bx
	jz		OnDoneText
	%ifdef DEBUG
		cmp 	bx, MAIN_OPTION_AND
		jb	.OkSubFn
		Debug_TextLn 'ERROR: Sub function value too high!'
		Terminate 101
	.OkSubFn:
	%endif
	add		bx, bx
	mov		bx, [DoFunctions+bx-2]
	xor		dl, dl
	mov		si, VALUES.ITEM0
	call		bx
	mov		[RESULT.PENDING], dl
; -----------------------------------------------------------------------------

OnDoneText:
	xor		dx, dx

; -----------------------------------------------------------------------------

OnDoneSwitch:
	mov		[LAST_OPT], dx
	clc
	Debug_Status
	ret

; -----------------------------------------------------------------------------

CheckMissingText:
	cmp		[LAST_OPT], word 0x00
	jnz		.IsMissing
	ret
.IsMissing:
	Debug_Text	'Assume NULL text:'
	call		SHOVE_VALUE
	mov		[VALUES.ITEM0 + TVALUE.DTYPE], byte stText
	call		OnEvaluate
	ret

; -----------------------------------------------------------------------------

OnSyntaxError:
	mov		dx, MESSAGE.SYNTAX
	jmp		OnError

OnInvalid:		; not a valid switch
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
	Debug_TextLn	'OnTrueFalse:'
	; can be used at any point in the command line to enable display
	; of TRUE/FALSE result
	mov		[SHOW_RESULT], byte TRUE
	ret

; -----------------------------------------------------------------------------

OnTest:
	Debug_TextLn	'OnTest:'
	or		[STATUS], byte sfNeedCMP
	jmp		OnDoneSwitch

; -----------------------------------------------------------------------------

OnExpCase:
	Debug_TextLn	'OnCaseSpecific:'
	test		[STATUS], byte sfNeedCMP
	jnz		OnSyntaxError
	test		[STATUS], byte sfCaseLess
	jnz		OnSyntaxError
	or		[STATUS], byte sfCaseSpecific
	xor		dx, dx
	jmp		OnDoneSwitch

OnExpIgnore:
	Debug_TextLn	'OnCaseIgnore:'
	test		[STATUS], byte sfNeedCMP
	jnz		OnSyntaxError
	test		[STATUS], byte sfCaseSpecific
	jnz		OnSyntaxError
	or		[STATUS], byte sfCaseless
	xor		dx, dx
	jmp		OnDoneSwitch

OnExpNOT:
	Debug_TextLn	'OnNOT:'
	test		[STATUS], byte sfNeedCMP
	jnz		OnSyntaxError
	xor		[STATUS], byte sfNOT
	xor		dx, dx
	jmp		OnDoneSwitch

; -----------------------------------------------------------------------------

OnExpAND:
	call		CheckMissingText
	Debug_TextLn	'OnAND:'
	call		DoFn_AND_OR	; Handle previous AND/OR
	or		[STATUS], byte sfExpAND
	xor		dx, dx
	jmp		OnDoneSwitch

OnExpOR:
	call		CheckMissingText
	Debug_TextLn	'OnOR:'
	call		DoFn_AND_OR	; Handle previous AND/OR
	or		[STATUS], byte sfExpOR
	xor		dx, dx
	jmp		OnDoneSwitch

; -----------------------------------------------------------------------------

OnCompare:
	call		CheckMissingText
	Debug_TextLn	'OnCompare:'
	and 		[STATUS], byte ~sfNeedCMP
	jmp		OnDoneSwitch

; -----------------------------------------------------------------------------
; IN: dl=0, OUT: dl=RESULT.PENDING, SI->VALUES.ITEMS0
DoOptFn_EQ:
	Debug_TextLn	'DoFn_EQ:'
	ret
DoOptFn_NE:
	Debug_TextLn	'DoFn_NE:'
	ret
DoOptFn_GE:
	Debug_TextLn	'DoFN_GE:'
	ret
DoOptFn_LE:
	Debug_TextLn	'DoFn_LE:'
	ret
DoOptFn_GT:
	Debug_TextLn	'DoFn_GT:'
	ret
DoOptFn_LT:
	Debug_TextLn	'DoFn_LT:'
	ret
DoOptFn_F:
	Debug_TextLn	'DoFn_F:'
	ret
DoOptFn_D:
	Debug_TextLn	'DoFn_D:'
	ret
DoOptFn_E:
	Debug_TextLn	'DoFn_E:'
	ret

; -----------------------------------------------------------------------------

DoOptFn_N:	; string is not null
	Debug_TextLn	'DoFn_N:'
	cmp		[si], byte 0
	jne		.NotNull
	ret
.NotNull:
	inc		dl
	ret

; -----------------------------------------------------------------------------

DoOptFn_Z:	; string is null
	Debug_TextLn	'DoFn_Z:'
	cmp		[si], byte 0
	je		.IsNull
	ret
.IsNull:
	inc		dl
	ret

; -----------------------------------------------------------------------------

DoOptFn_V: ; string has number value
	Debug_TextLn	'DoFn_V:'
	test		[si+TVALUE.DTYPE], byte stNumber
	jnz		.IsNumber
	ret
.IsNumber:
	inc		dl
	ret

; -----------------------------------------------------------------------------

DoFn_AND_OR:
	Debug_Text	'  { PREVIOUS: '
	Debug_Byte	[RESULT.FINAL]
	Debug_Text	', PENDING: '
	Debug_Byte	[RESULT.PENDING]

	mov		al, [RESULT.PENDING]
	test		[STATUS], byte sfNOT
	jz		.NotInverted
	Debug_Text	', INVERT'
	xor		al, TRUE
.NotInverted:
	test		[STATUS], byte sfExpAND
	jz		.DoFn_OR

.DoFn_AND:
	Debug_Text	', AND'
	and		[RESULT.FINAL], al
	jmp		.Done_AND_OR

.DoFn_OR:
	Debug_Text	', OR'
	or		[RESULT.FINAL], al

.Done_AND_OR:
	Debug_Text 	', RESULT: '
	Debug_Byte	[RESULT.FINAL]
	Debug_TextLn	' }'
	and		[STATUS], byte ~(sfExpOR + sfExpAND + sfNOT + sfNeedCMP)
	mov		[RESULT.PENDING], byte FALSE
;	call		CLEAR_VALUES
;	ret

; -----------------------------------------------------------------------------

CLEAR_VALUES:
	push		ax
	push		cx
	push		di
	mov		di, VALUES.ITEM0
	mov		cx, TVALUE_size
	xor		ax, ax
	rep		stosw		; TVALUE_size * 2 bytes
	pop		di
	pop		cx
	pop		ax
	ret

; -----------------------------------------------------------------------------

SHOVE_VALUE:
	; ITEM0 to ITEM1, clear ITEM 0
	push		ax
	push		cx
	push		si
	push		di
	mov		si, VALUES.ITEM0
	mov		di, VALUES.ITEM1
	mov		cx, TVALUE_size
	push		si
	push		cx
	rep		movsb		; TVALUE_size bytes
	pop		cx
	pop		di
	xor		ax, ax
	rep		stosb		; TVALUE_size bytes
	pop		di
	pop		si
	pop		cx
	pop		ax
	ret

; -----------------------------------------------------------------------------

STORE_VALUE:
; copy string from SI. Single / or < space terminates copy. Double / is
; copied as single /. On return: DI updated to new next position for parser.
; CX is new length
	mov		di, VALUES.ITEM0
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
	mov		di, si

	push		di
	test		cx, cx
	jz		.Done
	mov		si, VALUES.ITEM0
	mov		di, si
	add		di, TVALUE.NUMBER
	ASCII_sInt64	di, si
	jc		.Done
.Success:
	mov		[si+TVALUE.DTYPE], byte stNumber
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

STATUS:			dw sfExpOR

RESULT:
	.FINAL:		db FALSE
	.PENDING:	db FALSE

SHOW_RESULT:		db FALSE

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