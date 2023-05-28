; Copyright (C) 2017-2022 Jerome Shidel
; Open source see License file

; NASM 2.14rc0 for DOS

; New Command Line and String Parser

; %define FLEX_QUOTES	; Enable to support Flexible Quotes where text can be
			; encapsulated in one of the three quotation marks to
			; be passed as single parameter. The quotation
			; characters not used to wrap the text may be used
			; inside the quoted text.
			;
			; Leave this disabled to treat all quotation characters
			; as normal text. This will cause text with spaces or
			; SWITCH characters to be sent as individual pieces.
			; Note: Double switch characters will separate options.
			; However, it will be sent as //TEXT and not as switch.


%macro INTERNAL_StringParser 0
; AX, BX, CX, DX, SI, DI registers are either used or destroyed by this macro!
;
; On Entry:
;	Direction Flag must be clear
;	DS:SI->Option string
;	DS:DI->Option Table
;
; Example Table:
;
; SomeOptions:
;	OptTable 	OnText, OnBadOpt
;	OptSwitch	'H', OnShowHelp
;	OptWild		'-', OnDisableThis
;	OptWild		'+', OnEnableThis
;	OptSwitch	'VERSION', OnShowVersion
;	OptSwitch	'a', OnLowerA
;	OptSwitch	'A', OnUpperA
; 	OptEndTable

; When this macro calls a switch function, these registers are passed to the
; function. The macro will always call at least one sub-function. When the
; option string is empty, a single call to OnText will be performed with a
; null string. If there is a requirement to know if the option string is null,
; it may be desirable to test it before calling this macro.

; BX=Address of sub-function, (used for the actual call)
; CX=Param Length
; SI=Param Start
; DI=Next Param

; When calling a Switch Function, the switch character is excluded.

; Except for DS and DI, a sub-function does not need to preserve registers.
; DS must be preserved. DI will be used as the starting point for the next
; option to process. The sub-function can modify DI to skip or further breakup
; the option string text. Use extreme caution when modifying DI. There is no
; verification to prevent a crash or infinite loop.

; On return from the sub-function call:
; 	Direction Flag must be clear.
;	If Carry flag is set, processing stops.
;	Otherwise, processing continues from DS:DI.

; on return from macro, Carry Flag will be clear when all sub-functions were
; processed. Carry Flag will be set if processing was aborted.

PROC_StringParser:
	; cld
	%ifndef SWITCH_CHAR
		%define SWITCH_CHAR '/'
	%endif
	; mov	si, 0x81
	; mov	di, Options
%%MainLoop:

%%SkipSpaces:
	mov	bx, si
	lodsb
	cmp	al, 0x20
	je	%%SkipSpaces
; %%SkipDone:
%ifdef FLEX_QUOTES
	xor	ah, ah
	call	%%CheckQuote
	jnc	%%NotQuoted
%%Quoted:
	mov	bx, si ; move start string
	mov	ah, al
%%QuotedLoop:
	lodsb
	cmp	al, 0x20
	jb	%%QuoteEnd
	cmp	al, ah
	jne	%%QuotedLoop
	jmp	%%QuoteEnd
%endif
%%NotQuoted:
	lodsb
	call	%%CheckEnd
	jnc	%%NotQuoted
	jmp	%%NotQuotedEnd
%%CheckEnd:
	cmp	al, 0x20
	jbe	%%CheckYes
%%CheckSlash:
%ifndef FLEX_QUOTES
	test	ah, ah
	je	%%SkipSwitch
%endif
	cmp	al, SWITCH_CHAR
	je	%%CheckYes
%ifndef FLEX_QUOTES
%%SkipSwitch:
	mov	ah, 1
%endif

	; It can break params on other characters here, next param will be text
	; start with this character. Example:
	; cmp	al, '['
	; je	%%CheckYes
	; cmp	al, ']'
	; je	%%CheckYes

%%CheckQuote:
	cmp	al, 0x22
	je	%%CheckYes
	cmp	al, 0x27
	je	%%CheckYes
	cmp	al, 0x60
	je	%%CheckYes
	clc
	ret
%%CheckYes:
	stc
	ret
%%NotQuotedEnd:
	mov	cx, si
	dec	si
%ifdef FLEX_QUOTES
	jmp 	%%NoBackUp
%%QuoteEnd:
	mov	cx, si
%endif
%%NoBackUp:
	sub	cx, bx
	dec	cx

; Params has been split
; BX->Parameter of CX bytes length, SI->Next Paramemter, DI->Option Table

	test	cx, cx
	jz	%%NullString		; Is a NULL String
	mov	al, SWITCH_CHAR		; Define could be memory address
	cmp	[bx], al
	jne	%%AsString		; Not Starting with /
%ifdef FLEX_QUOTES
	test	ah, ah
	jnz	%%AsString		; Was not Quoted
%else
	cmp	[bx+1], al
	je	%%AsString
%endif
; Look up Option Switch:
	inc	bx			; Drop Switch Character
	dec	cx

%%LookupOpt:
	push	di
	add	di, 4
	call	%%CompareOpt
	pop	di
	test	ax, ax
	jnz	%%MakeCall
	mov	ax, [di+2]		; not valid sub-function handler
%%MakeCall:
	; BX,CX,SI,DI still set from param splitting, AX=Function Call
	; SI can be updated by function call to skip part or all of the
	; remaining command line parameters. Or even backup, for additional
	; splitting. DI must be preserved.

	; preserve and juggle registers
	push	di
	mov	di, si
	mov 	si, bx
	mov	bx, ax

	; BX=Function Call, CX=Param Length, SI=Param Start, DI=Next Param
	clc
	call	bx

	; restore registers
	mov	si, di
	pop	di

	; if carry flag set, abort!
	jc	%%ParseEnd

	; check if processing is done. Terminate on NULL, CR, LF, etc.
	mov	al, [si]		; if next char is less than SPACE, then
	cmp	al, 0x20		; processing is done.
	jae	%%MainLoop		; Repeat for next parameter
	clc
%%ParseEnd:				; All Done, Exit Parsing
	ret

%%NullString:
%%AsString:
	mov	ax, [di]
	jmp	%%MakeCall

%%CompareOpt:
	push	bx
	push	cx
%%Comparing:
	mov	al, [di]
	inc	di
	cmp	al, 0x01
	jb	%%EndOpt
	je	%%WildOpt
	mov	ah, [bx]
	inc	bx
	cmp	ah, al
	je	%%SoFarOpt
	; adjust Options String character to Uppercase and try again.
	cmp	ah, 0x61
	jb	%%NotLower
	cmp	ah, 0x7a
	ja	%%NotLower
	sub	ah, 0x20
%%NotLower:
	cmp	ah, al
	je	%%SoFarOpt
	; mismatch, skip remainder of switch characters
	jmp	%%SkipOpt
%%SoFarOpt:
	loop	%%Comparing
	mov	al, [di]
	cmp	al, 0x01
	ja	%%SkipOpt
	inc	di
%%WildOpt:
	mov	ax, [di]
	add	di, 2
	pop	cx
	pop	bx
	ret
%%SkipOpt:
	mov	al, [di]
	inc	di
	cmp	al, 0x01
	ja	%%SkipOpt
%%EndOpt:
	mov	ax, [di]
	add	di, 2
	pop	cx
	pop	bx
	test	ax, ax
	jnz	%%CompareOpt
	ret
%endmacro

%imacro ParseOptions 1-2
	%ifndef ParseOptions_Declared
		%idefine ParseOptions_Declared
		jmp	%%SkipOver
	%endif
	INTERNAL_StringParser
%%SkipOver:
	%if %0 = 1
		mov	si, 0x81
	%elifnidni %2, si
		mov	si, %2
	%endif
	mov	di, %1
	call	PROC_StringParser
%endmacro

%imacro OptTable 2
	dw %1,%2	; %1=Text call address, %2=Invalid Switch call address
%endmacro

%imacro OptEndTable 0
	db 0,0,0	; Terminate Option Table Data
%endmacro

%idefine OptTableEnd OptEndTable

%imacro OptSwitch   2	; Standard Switch
			; So both UPPER/LOWER case can be used for a switch.
			; UPPER matches UPPER & LOWER, LOWER only matches LOWER
			; If LOWER is used, it should proceed UPPER.
			; If caseless, only use UPPER.
	db %1,0x00	; %1 Switch text, % function call address
	dw %2
%endmacro

%imacro OptWild   2	; Wildcard Switch. Only the first part of an option
			; needs to match the switch.
	db %1,0x01	; %1 Switch text, % function call address
	dw %2
%endmacro

