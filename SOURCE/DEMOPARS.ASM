; Copyright (C) 2023 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%idefine DEBUG

%include "COMMON.INC"
%include "INT64.INC"


	ParseOptions 	Options
	jnc		Done
	Debug_Text 	'Error'
Done:

	Debug_CRLF

	Terminate 0

	Int64_Procs

Options:
	OptTable 	SwitchText, SwitchInvalid
	OptSwitch 	'H',	SwitchHelp
	OptWild		'A',	SwitchA
	OptSwitch 	'B',	SwitchB
	OptTableEnd

HelpSwitchHandler 'vview'

SwitchShow:
	Debug_Char	bl
	test		cx, cx
	jz		.Done
.Printing:
	lodsb
	Debug_Char	al
	loop		.Printing
.Done:
	Debug_Char	bh
	clc
	ret

SwitchInvalid:	; not a valid switch
	mov	bx, '{}'
	call	SwitchShow
	stc
	ret

SwitchText:	; command line text
	mov	bx, 0x2222
	jmp	SwitchShow

SwitchA:
	mov	bx, '[]'
	jmp	SwitchShow

SwitchB:

	mov	bx, '()'
	jmp	SwitchShow
