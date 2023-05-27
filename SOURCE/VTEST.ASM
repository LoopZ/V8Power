; Copyright (C) 2023 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%idefine DEBUG

%include "COMMON.INC"
%include "INT64.INC"

Main:
	ParseOptions 	Options
;	jnc		.Done
.Done:

	Terminate 	[EXIT_CODE]

	Int64_Procs

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
	clc	; continue processing
	ret
; -----------------------------------------------------------------------------
EXIT_CODE:	db 0