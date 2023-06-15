; Copyright (C) 2023 Jerome Shidel
; Open source see License file

; NASM for DOS

; Known limitations:

%idefine NoVideoOutput

; %define DEBUG

%define MATCH_SYSTEM		; When enabled /F and /D will match system
				; files and dirs. /E always matches any existing
				; file system entry.

%define MATCH_HIDDEN		; When enabled /F and /D will match hidden
				; files and dirs. /E always matches any existing
				; file system entry.

%define DOS_WILDCARDS		; MS-DOS compatible wildcard matching for
				; /F, /D and /E options. For now, required.
				; Maybe later include "smart" wildcards.

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
%idefine sfCaseless 	01000000b ; 0x0040 ; string ignore case compare
%idefine sfNOT		10000000b ; 0x0080 ; invert expression result

; String data type
%idefine stText		00000001b ; Text String
%idefine stNumber	00000010b ; Text/Number
%idefine stFile		00000100b ; File name
%idefine stDir		00001000b ; Directory Name
%idefine stFileOrDir	00001100b ; File or Directory name

; Internal TRUE/FALSE
%idefine TRUE  1
%idefine FALSE 0

; -----------------------------------------------------------------------------

%define MAX_LEN	512	; normally only needs to be 126. But LFN's can be up to
			; 260 characters.

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
; DTA -> PSP:0080

Main:
	; Initialize BSS Data
	mov		cx, (BSS_END - BSS_START + 1) / 2
	mov		di, BSS_START
	xor		ax, ax
	rep		stosw

	; Adjust DOS DTA
	mov		dx, DTA_SEARCH
	mov		ah, 0x1a
	int		0x21

	mov		[INT24+2], cs

	ParseOptions 	Options
	Debug_TextLn	'END COMMAND LINE'
	jc		.ExitError

	; check for dangling comparison
	cmp		[LAST_OPT], word 0
	je		.NotDangling
	Debug_TextLn	'Dangling comparison!'
	call		SHOVE_VALUE	; ITEM0->ITEM1, ITEM0 Cleared

.NotDangling:

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

	; should not need to restore DTA to PSP:0080, but...
	mov		dx, 0x0080
	mov		ah, 0x1a
	int		0x21

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
	OptSwitch	'F',	OnTest		; switch index 7
	OptSwitch 	'D',	OnTest		; switch index 8
	OptSwitch 	'E',	OnTest		; switch index 9
	OptSwitch 	'N',	OnTest		; switch index 10
	OptSwitch 	'Z',	OnTest		; switch index 11
	OptSwitch 	'V',	OnTest		; switch index 12
	; options without "DoFunctions"
	OptSwitch 	'AND',	OnExpAND
	OptSwitch 	'OR',	OnExpOR
	OptSwitch 	'C',	OnExpCase
	OptSwitch 	'I',	OnExpIgnore
	OptSwitch 	'NOT',	OnExpNOT
	; basic non-operator options
	OptSwitch 	'H',	SwitchHelp
	OptSwitch 	'?',	SwitchHelp
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
; Debug stuff probably will be removed later

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

	call		SHOVE_VALUE	; ITEM0->ITEM1, ITEM0 Cleared
	call		STORE_VALUE	; copies SI->ITEM0, updates DI for Parser

	cmp		[LAST_OPT], word 0
	jne		OnEvaluate
	mov		[LAST_OPT], word MAIN_OPTION_N	; string not null

OnEvaluate:
	or		[STATUS], byte sfNeedCMP
	Debug_Strings
	Debug_Status
	Debug_Text	'Evaluate: '
	mov		bx, [LAST_OPT]
	test		bx, bx
	jz		OnDoneText
	%ifdef DEBUG
		cmp 	bx, MAIN_OPTION_AND
		jb	.OkSubFn
		Debug_TextLn 'ERROR: Sub function value too high!'
		mov 	[RESULT.FINAL], byte 101
		stc
		ret
	.OkSubFn:
	%endif
	call		DoCompare
	add		bx, bx
	mov		bx, [DoFunctions+bx-2]
	xor		dl, dl
	mov		si, VALUES.ITEM0
	cmp		[STRCMP], byte 1	; set flags for comparisons
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
	test 		[STATUS], byte sfNeedCMP
	jnz		OnSyntaxError
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
	; and 		[STATUS], byte ~sfNeedCMP
	jmp		OnDoneSwitch

; -----------------------------------------------------------------------------

DoCompare:
	push		si
	push		di
	test 		[STATUS], byte sfCaseSpecific + sfCaseless
	jnz		.AsStrings
	test		[VALUES.ITEM0 + TVALUE.DTYPE], byte stNumber
	jz		.AsStrings
	test		[VALUES.ITEM1 + TVALUE.DTYPE], byte stNumber
	jz		.AsStrings
.AsNumbers:
	Debug_Text	'Compare as Numbers:'
	mov		di, VALUES.ITEM1 + TVALUE.NUMBER ; highest byte
	; ok to destroy 64-bit number at DI
	sInt64_Sub	di, VALUES.ITEM0 + TVALUE.NUMBER
	jc		.SubtractionError
	xor		ax, ax
	test		[di+7], byte 0x80	; if negative, is less than
	jnz		.SaveResult
	mov		cx, 8
.CheckEqual:
	or		ah, [di]
	inc		di
	loop		.CheckEqual
	test		ah, ah
	jz		.Equal			; no bits set, then are equal
	mov		al, 2			; otherwise, it is positive
	jmp		.SaveResult
.UpcaseChar:
	test 		[STATUS], byte sfCaseSpecific
	jnz		.UpcaseDone
	cmp		al, 0x61
	jb		.UpcaseDone
	cmp		al, 0x7a
	ja		.UpcaseDone
	sub		al, 0x20
.UpcaseDone:
	ret
.SubtractionError:
	Debug_Text	'Subtraction Error! '
	pop		di
	pop		si
	push		si
	push		di
.AsStrings:
	Debug_Text	'Compare as Strings:'
	mov		si, VALUES.ITEM1
	mov		di, VALUES.ITEM0
.StrLoop:
	mov		al, [di]
	inc		di
	call		.UpcaseChar
	mov		ah, al
	lodsb
	call		.UpcaseChar
	cmp		al, ah
	jne		.HaveResult
	test		al, al
	jnz		.StrLoop

.HaveResult:
	mov		al, 1
	je		.SaveResult
	mov		al, 2
	ja		.SaveResult
.Equal:
	xor		al, al
.SaveResult:
	mov		[STRCMP], al
	%ifdef DEBUG
		pushf
		Debug_Text	' comparison is '
		cmp	al, 1
		je		.MsgEqual
		jb		.MsgLess
		Debug_Text	'Greater Than >'
		jmp		.MsgDone
	.MsgLess:
		Debug_Text	'Less Than <'
		jmp		.MsgDone
	.MsgEqual:
		Debug_Text	'Equal To ='
		jmp		.MsgDone
	.MsgDone:
		Debug_Text	' (AL='
		Debug_Byte	al
		Debug_TextLn	')'
		popf
	%endif
	pop		di
	pop		si
.Done:
	ret

; -----------------------------------------------------------------------------
; IN: dl=0, Flags=comparison; OUT: dl=RESULT.PENDING, SI->VALUES.ITEMS0
DoOptFn_EQ:
	Debug_TextLn	'DoFn_EQ:'
	je		RetTrue
	ret
DoOptFn_NE:
	Debug_TextLn	'DoFn_NE:'
	jne		RetTrue
	ret
DoOptFn_GE:
	Debug_TextLn	'DoFN_GE:'
	jae		RetTrue
	ret
DoOptFn_LE:
	Debug_TextLn	'DoFn_LE:'
	jbe		RetTrue
	ret
DoOptFn_GT:
	Debug_TextLn	'DoFn_GT:'
	ja		RetTrue
	ret
DoOptFn_LT:
	Debug_TextLn	'DoFn_LT:'
	jb		RetTrue
	ret

; -----------------------------------------------------------------------------

DoOptFn_F:
	Debug_TextLn	'DoFn_F:'
	and		[VALUES.ITEM0 + TVALUE.DTYPE], byte ~stDir
	or		[VALUES.ITEM0 + TVALUE.DTYPE], byte stFile
	jmp		DoOptFn_F_D_E

DoOptFn_D:
	Debug_TextLn	'DoFn_D:'
	and		[VALUES.ITEM0 + TVALUE.DTYPE], byte ~stFile
	or		[VALUES.ITEM0 + TVALUE.DTYPE], byte stDir
	jmp		DoOptFn_F_D_E
DoOptFn_E:
	Debug_TextLn	'DoFn_E:'
	or		[VALUES.ITEM0 + TVALUE.DTYPE], byte stFileOrDir

DoOptFn_F_D_E:
	xor		ah, ah
	mov		si, VALUES.ITEM0
.LastChar:
	lodsb
	test		al, al
	jz		.LastCharDone
	mov		ah, al
	jmp		.LastChar
.LastCharDone:
	cmp		ah, DIRECTORY_SEPARATOR
	jne		.Search
	dec		si
	mov		[si], word 0x2e2a	; '*', '.'
	mov		[si+2], word 0x002a	; '*', 0
.Search:
	call		FILE_EXIST
	Debug_CarryFlag
	ret

; -----------------------------------------------------------------------------

DoOptFn_N:	; string is not null
	Debug_TextLn	'DoFn_N:'
	cmp		[si], byte 0
	jne		RetTrue
	ret

; -----------------------------------------------------------------------------

DoOptFn_Z:	; string is null
	Debug_TextLn	'DoFn_Z:'
	cmp		[si], byte 0
	je		RetTrue
	ret

; -----------------------------------------------------------------------------

DoOptFn_V: ; string has number value
	Debug_TextLn	'DoFn_V:'
	test		[si+TVALUE.DTYPE], byte stNumber
	jnz		RetTrue
	ret

; -----------------------------------------------------------------------------

RetTrue:
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
	and		[STATUS], byte ~(sfExpOR + sfExpAND + sfNOT + \
			sfNeedCMP + sfCaseSpecific + sfCaseless)
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

MAKE_NUMBER:
	; convert to number if possible
	push		di
	test		cx, cx
	jz		.Done
	mov		si, VALUES.ITEM0
	mov		di, si
	add		di, TVALUE.NUMBER
	ASCII_sInt64	di, si
	jc		.Done
.Success:
	or		[si+TVALUE.DTYPE], byte stNumber
.Done:
	pop		di
	ret

; -----------------------------------------------------------------------------

FILE_EXIST:
	call		FIND_FIRST
.CHECK:
	jc		.DONE
	call		FILE_COMPARE_ATTRIB
	jc		.NEXT
	call		FILE_COMPARE_NAME
	jnc		.DONE
.NEXT:
	call		FIND_NEXT
	jmp		.CHECK
.DONE:
	%ifdef DEBUG
		jnc	.found
		Debug_TextLn	'{ no matching files/dirs }'
		jmp	.cleanup
	.found:
		Debug_Text	'{ file/dir match: '
		Debug_AsciiZ	VALUES.ITEM0
		Debug_TextLn	' }'
	.cleanup:

	%endif
	pushf
	call		FIND_CLOSE
	xor		dl, dl
	popf
	jc		.NOTFOUND
	inc		dl
	ret
.NOTFOUND:
	mov		[VALUES.ITEM0], byte 0	; make string null
	ret

FILE_COMPARE_ATTRIB:
	mov		cx, [VALUES.ITEM0 + TVALUE.DTYPE]
	and		cx, stFileOrDir
	mov		al, [DTA_SEARCH + 0x15]	; DOS 8.3 File Attribute Offset (BYTE)
	cmp		[LFN_SUPPORTED], byte 1
	jne		.COMPARE
	mov		al, [DTA_SEARCH + 0x00]	; Long File Attribute Offset (DWORD)
.COMPARE:
	; set attribute bits we care about. Never care about Sharable, Archive,
	; Read-Only or unused bits. ei 11100001b
	%ifdef MATCH_SYSTEM
		%ifdef MATCH_HIDDEN
			; Allow SYSTEM + HIDDEN
			and 	al, 00011000b	; test dir & volume label
		%else
			; Allow SYSTEM ONLY
			and 	al, 00011010b	; test hidden, dir, volume label
		%endif
	%else
		%ifdef MATCH_HIDDEN
			; Allow HIDDEN ONLY
			and 	al, 00011100b	; test system, dir, volume label
		%else
			; Do not allow SYSTEM or HIDDEN
			and 	al, 00011110b	; test system, hidden, dir, volume label
		%endif
	%endif
	cmp		cx, stFile
	je		.FILE_ONLY
	cmp		cx, stDir
	je		.DIR_ONLY
.ANY_EXISTS:
	clc		; something matched search. so return true.
	ret
.FILE_ONLY:
	test		al, al
	jnz		.NOT_MATCHED	; DIR or other special bit is set
	clc
	ret
.DIR_ONLY:
	test		al, 00010000b
	jz		.NOT_MATCHED	; DIR bit is not set
	test		al, 11101111b
	jnz		.NOT_MATCHED	; Special bit is set
	clc
	ret
.NOT_MATCHED:
	stc
	ret

FILE_COMPARE_NAME:
	%ifndef DOS_WILDCARDS
		%fatal SMART_WILDCARDS not implemented. DOS_WILDCARDS is required.
	%endif
	mov		si, DTA_SEARCH + 0x1e	; DOS 8.3 File Name Offset (13 chars)
	cmp		[LFN_SUPPORTED], byte 1
	jne		.COMPARE
	mov		si, DTA_SEARCH + 0x2c	; Long File Name Offset (260 chars)
.COMPARE:
	push		di
	push		si
	mov		di, VALUES.ITEM0
	xchg		si, di
	test		[STATUS], byte sfCaseSpecific
	jz		.MATCHED
.CMPLOOP:
	lodsb
	mov		ah, [di]
	inc		di
	test		al, al
	jz		.CMPEND
	cmp		al, 0x2a	; *
	jne		.NOTSTAR
.SKIPB:
	test		ah, ah
	jz		.SKIPBDONE
	cmp		ah, 0x2e	; .
	je		.SKIPBDONE
	mov		ah, [di]
	inc		di
	jmp		.SKIPB
.SKIPBDONE:
	lodsb
	test		al, al
	jz		.CMPEND
	cmp		al, 0x2e
	jne		.SKIPBDONE
.NOTSTAR:
	cmp		al, 0x3f	; ?
	je		.CMPLOOP
	cmp		al, ah
	jne		.NOMATCH
	jmp		.CMPLOOP
.CMPEND:
	test		ah, ah
	jz		.MATCHED
.NOMATCH:
	pop		si
	pop		di
	stc
	ret
.MATCHED:
	pop		si
	mov		di, VALUES.ITEM0
	mov		cx, MAX_LEN
	rep		movsb
	pop		di
	inc		cx		; CX != 0, attempt convert to number
	call		MAKE_NUMBER
	clc
	ret

; -----------------------------------------------------------------------------

LFN_CALL:
	cmp		[LFN_SUPPORTED], byte 1
	ja		.Unsupported
	je		.Supported
	; Probe for LFN support
	push		ax
	push		dx
	mov		ax, 0x713b		; change to current directory
	mov		dx, LFN_PROBE_DATA 	; Change to directory '.'
	stc
	int		0x21
	pop		dx
	pop		ax
	jc		.NotDetected
	mov		[LFN_SUPPORTED], byte 1
	jmp		.Supported
.NotDetected:
	mov		[LFN_SUPPORTED], byte 2
.Unsupported:
	xchg		al, ah
	jmp		.MakeCall
.Supported:
	mov		ah, 0x71
.MakeCall:
	stc
	int		0x21
	ret

; -----------------------------------------------------------------------------

FIND_FIRST:
	call		SWAP_INTS
	mov		ax, 0x004e		; LFN fn 0x714e, DOS 0x4e00
	mov		dx, VALUES.ITEM0	; ds:dx->ASCIIZ Filespec
	mov		cx, 0x00ff		; any file
	call		.SEARCH
	mov		[SEARCH_HANDLE], ax	; CF, then error code
	ret
.SEARCH:
	push		di
	mov		di, DTA_SEARCH		; es:di->Search record (LFN)
	push		si
	mov		si, 0x0001		; LFN MS-DOS timestamps
	call		LFN_CALL
	pop		si
	pop		di
	ret

FIND_NEXT:
	mov		ax, 0x004f
	mov		bx, [SEARCH_HANDLE]
	jmp		FIND_FIRST.SEARCH

FIND_CLOSE:
	cmp		[LFN_SUPPORTED], byte 2
	jne		.DONE
	mov		ax, 0x71a1
	mov		bx, [SEARCH_HANDLE]
	int		0x21
.DONE:
	call		SWAP_INTS
	ret

; -----------------------------------------------------------------------------

INT24_HANDLER:
	mov		al, 0x03	; fail system call
	iret

; -----------------------------------------------------------------------------

SWAP_INTS:
	pushf
	cli
	push		es
	push		ds
	mov		dx, [INT24]
	mov		ax, [INT24+2]
	push		dx
	push		ax
	mov		ax, 0x3524
	int		0x21
	mov		[INT24], bx
	mov		[INT24+2], es
	mov		ax, 0x2524
	pop		ds
	pop		dx
	int		0x21
	pop		ds
	pop		es
	popf
	ret

; -----------------------------------------------------------------------------

	Int64_Procs
	HelpSwitchHandler 'vtest'

; -----------------------------------------------------------------------------

section .data

; -----------------------------------------------------------------------------

INT24:			dw INT24_HANDLER, 0

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

LFN_PROBE_DATA:
	db 	'.'	; AsciiZ for LFN probe only valid until Probed.
LFN_SUPPORTED:
	db	0 	; 0=unknown test for it, 1=true, 2=false

%ifndef DOS_WILDCARDS
SEARCH_STRING:
	db	'*.*',0
%endif

; -----------------------------------------------------------------------------

section .bss

; -----------------------------------------------------------------------------
BSS_START:

VALUES:
	.ITEM0:		resb TVALUE_size
	.ITEM1:		resb TVALUE_size

STRCMP:		resb	1	; 0 = STR2 < STR1, 1 = Equal, 2 = STR2 > STR1


SEARCH_HANDLE:	resw 	1
DTA_SEARCH:	resb	512	; requires 318 for LFN, 43 for 8.3 filenames

BSS_END:
	resw 1