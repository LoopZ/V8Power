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
%idefine sfHaveString	00000001b ; String is pending
%idefine sfHaveNumber	00000010b ; String can be processed as a number

%idefine sfCmdLnOpts	10000000b ; Any option or text processed


; -----------------------------------------------------------------------------

Main:
	ParseOptions 	Options
	jc		.Done
	xor		[EXIT_CODE], byte 1
	%ifdef DEBUG
		mov	dx, .TrueStr
		test	[EXIT_CODE], byte 1
		jz	.PrintResult
		mov	dx, .FalseStr
		jmp	.PrintResult
	.TrueStr:
		db 	'TRUE',0x0d,0x0a,'$'
	.FalseStr:
		db 	'TRUE',0x0d,0x0a,'$'
	.PrintResult:
		mov	ah, 0x09
		int	0x21
	%endif
.Done:
	%ifdef DEBUG
		StdOutHexByte   [EXIT_CODE]
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
	OptTableEnd

; -----------------------------------------------------------------------------
HelpSwitchHandler 'vtest'

; -----------------------------------------------------------------------------
OnInvalid:	; not a valid switch
	mov		ah, 0x09
	mov		dx, .Message1
	int		0x21
	mov		ah, 0x02
.Printing:
	lodsb
	mov		dl, al
	int		0x21
	loop		.Printing
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
OnText:

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

; -----------------------------------------------------------------------------
OptionDone:
	or		[STATUS+1], byte sfCmdLnOpts 	; something happened
	clc 						; continue processing
	ret
; -----------------------------------------------------------------------------
EXIT_CODE:	db 0
STATUS:		db 0