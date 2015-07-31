; Copyright (C) 2015 Jerome Shidel
;
;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation; either version 2 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License along
;   with this program; if not, write to the Free Software Foundation, Inc.,
;   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

; NASM for DOS 

; common code snippet macros

; Macro for Placeholder "dummy" programs not yet developed
%imacro PlaceHolder 0
    push        cs
    pop         ds
    mov         dx, Message
    mov         ah, 0x09
    int         0x21
    jmp         Done
Message:
    DB "This program is only a placeholder executable. "
    DB "It will be replaced by a program",0x0d,0x0a
    DB "that actually does something at a later time.$"
Done:
%endmacro
    
; Write Word in AX
%imacro WriteInt 1
    mov         ax, %1
	call		WriteIntProc    
	%ifndef WriteIntProc_Declared
		%idefine 	WriteIntProc_Declared
		jmp			%%Done
	WriteIntProc:
		mov         bx, 0x000A
		mov         cx, 0x0001
	%%WriteIntLoop:
		cmp         ax, bx
		jge         %%WayTooBig
		push        ax
	%%IsJustRight:
		pop         ax
		add         ax, 0x0030
		push        ax
		push        bx
		push        cx
		WriteChar   
		pop         cx
		pop         bx
		pop         ax
		loop        %%IsJustRight
		jmp         %%WriteIntDone
	%%WayTooBig:   
		inc         cx
		xor         dx, dx
		div         bx
		push        dx
		jmp         %%WriteIntLoop
	%%WriteIntDone:
		ret
	%%Done:
	%endif
%endmacro

; Write AX to standard output as HEX
%imacro StdOutHexByte 0
	push	ax
	mov		ah, 0x02
	mov		dl, '0'
	int		0x21
	mov		dl, 'x'
	int 	0x21
	pop		ax
	mov		cx, 2
%%Loopy:
	push	cx
	push	ax
	dec		cx
	mov		ax, 4
	mul		cx
	mov		cx, ax
	pop		ax
	push	ax
	shr		ax, cl
	and		ax, 0x0f
	cmp		al, 9
	jle		%%Digit
	add		al, 0x57
	jmp		%%Show
%%Digit:
	add		al, 0x30
%%Show:
	mov		ah, 0x02
	mov		dl, al
	int		0x21
	pop		ax
	pop		cx
	loop	%%Loopy
%endmacro

; Write AX to standard output as HEX
%imacro StdOutHexWord 0
	push	ax
	mov		ah, 0x02
	mov		dl, '0'
	int		0x21
	mov		dl, 'x'
	int 	0x21
	pop		ax
	mov		cx, 4
%%Loopy:
	push	cx
	push	ax
	dec		cx
	mov		ax, 4
	mul		cx
	mov		cx, ax
	pop		ax
	push	ax
	shr		ax, cl
	and		ax, 0x0f
	cmp		al, 9
	jle		%%Digit
	add		al, 0x57
	jmp		%%Show
%%Digit:
	add		al, 0x30
%%Show:
	mov		ah, 0x02
	mov		dl, al
	int		0x21
	pop		ax
	pop		cx
	loop	%%Loopy
%endmacro

%imacro StdOutCRLF 0
	mov		ah, 0x02
	mov		dl, 0x0d
	int		0x21
	mov		dl, 0x0a
	int		0x21
%endmacro

; Pre-286 High bits of flags are always set to 1
%imacro Is286 0
    pushf
    pushf
    pop         ax
    and         ax, 0x0fff
    push        ax
    popf
    pushf       
    pop         ax
    and         ax, 0xf000
    cmp         ax, 0xf000
    je          %%IsNot286
    mov         al, 0x01
    jmp         %%Test286Done
%%IsNot286:
    xor         al, al
%%Test286Done:
    popf
%endmacro

%imacro DelayTicks 1
	push		es
	mov			ax, %1
	xor  		dx, dx
	mov  		cx, 55
	div  		cx
	cmp			dx, 23
	jl			%%NoRoundUp
	inc			ax
%%NoRoundUp:	
	cmp			ax, 0
	je			%%Done
	mov			cx, ax
	mov  		dx, 0x0040
	mov			es, dx
	mov			di, 0x006C
%%Loop:
	mov			dx, [es:di]
%%Wait:
	mov			ax, [es:di]
	cmp			dx, ax
	je			%%Wait
	loop		%%Loop
%%Done:
	pop			es
%endmacro

%imacro DelayTimer 1
	mov  		ax, 0x8301
	int  		0x15

	mov			ax, %1
	push		ax
	mov			cl, 0x0a
	shl			ax, cl
	mov			dx, ax
	pop			ax
	mov			cl, 0x06
	shr			ax, cl
	mov			cx, ax	

	mov			bx, %%DelayData
	mov  		ax, 0x8300
	mov  		[%%DelayData], al
	int  		0x15
%%Loop:
	mov  		al, [%%DelayData]
	test 		al, 0x80
	jz   		%%Loop
	jmp			%%Done
%%DelayData:
	DB			0
%%Done:
%endmacro

%imacro Delay 1
	mov  		dx, %1
	cmp			dx, 0x0000
	je			%%NoDelay
	Is286
	cmp			ax, 0x0001
	je			%%Delay286
	DelayTicks	dx
	jmp			%%NoDelay
%%Delay286:
	DelayTimer	dx
%%NoDelay:
%endmacro

; Complex Command line parser
; CommandLineSwitches label must exit
; it will call functions listed as DB Character, 0/1 Needs Param; DW Address
; first is no switch, last is 0,0,0
; on call dl is switch character, cx is data length, di is start of data, 
; si is end of data.
%imacro CommandLineParser 0
    cld
    xor         bx, bx
    mov         di, si
    xor         dh, dh
%%Loop:
    lodsb
    cmp         al, 0x0d
    je          %%Next
    cmp         al, 0x22
    je          %%Quote
    cmp         al, 0x27
    je          %%Quote
    cmp         al, 0x60
    je          %%Quote 
    cmp         al, 0x20
    je          %%Next
    cmp         al, "/"
    je          %%Next
    jmp         %%Loop
%%Quote:
    mov         ah, al
%%QuoteLoop:
    inc         dh
    lodsb
    cmp         al, 0x0d
    je          %%Error
    cmp         al, ah
    jne         %%QuoteLoop
    jmp         %%Loop
%%Next:
    mov         cx, si
    sub         cx, di
    cmp         cx, 1
    push        cx
    jle         %%Skip
    cmp         al, 0x0d
    jne         %%NotEnd
    dec         si
    dec         cx
%%NotEnd:
    push        si
    cmp         al, 0x20
    jne         %%NotSpace
    dec         si
    dec         cx
%%NotSpace:
    cmp         bx, 0
    jne         %%NotDefault
    mov         bx, [CommandLineSwitches + 2]
    xor         dl, dl
%%NotDefault:
    cmp         al, SwitchChar
    jne         %%NotSwitched
    dec         si
    dec         cx
%%NotSwitched:
    push        ax
    cmp         dh, 0
    je          %%NotQuoted
    inc         di
    dec         si
    sub         cx, 2
%%NotQuoted:
    call        bx
    xor         dh, dh
    pop         ax
    xor         bx, bx
    pop         si
%%Skip:
    pop         cx
    cmp         al, SwitchChar
    je          %%Switch
    cmp         al, 0x0d
    je          %%Done
    cmp         al, 0x20
    jne         %%ResetBX
    cmp         cx, 1
    jle         %%KeepBX
%%ResetBX:  
    xor         bx, bx
%%KeepBX:
    mov         di, si
    jmp         %%Loop
%%Switch:
    mov         di, si
    lodsb
    cmp         al, SwitchChar
    jl          %%Error
    cmp         al, 0x61
    jl          %%CaseOK
    cmp         al, 0x7a
    jg          %%CaseOK
    sub         al, 0x20
%%CaseOK:
    mov         bx, CommandLineSwitches
%%Lookup:
    add         bx, 4
    mov         cx, [bx]
    cmp         cl, 0
    je          %%Error
    cmp         cl, al
    jne         %%Lookup
    mov         dx, [bx + 2]
    mov         bx, dx
    cmp         ch, 0
    jne         %%NeedsParam
    xor         cx, cx
    push        si
    mov         dl, al
    call        bx
    xor         dh, dh
    xor         bx,bx   
    pop         si
    mov         di, si
    jmp         %%Loop
%%NeedsParam:
    xor         dh, dh
    mov         dl, al
    mov         di, si
    jmp         %%Loop
%%Error:
    WriteStr    CommandLineErrorMsg
    Terminate   100
%%Done:
    cmp         bx, 0
    jne         %%Error
%endmacro

%imacro NumberParamProc 0
	%ifndef NumberParamProc_Declared
		%idefine NumberParamProc_Declared
		jmp	%%SkipOver

	NumberParam_Proc:
		xor         ax, ax
		push        di
	 %%NumLoop:
		cmp         cx, 0
		je          %%Done
		mov         bl, [di]
		inc         di
		cmp         bl, 'x'
		je          %%ForceHex
		cmp         bl, 'X'
		je          %%ForceHex
	
		cmp         bl, 0x41
		jl          %%NotUpperCase
		cmp         bl, 0x5a
		jg          %%NotUpperCase
		jmp         %%IsHex
	%%NotUpperCase:
		cmp         bl, 0x61
		jl          %%NotLowerCase
		cmp         bl, 0x7a
		jg          %%NotLowerCase
		jmp         %%IsHex
	%%NotLowerCase:
		push        cx
		sub         bl, 0x30
		mov         cx, 10
		mul         cx
		xor         bh, bh
		add         ax, bx
		pop         cx
		loop        %%NumLoop
		jmp         %%Done
	 %%ForceHex:
		pop         bx          ; discard di
		dec         cx
		jmp         %%DoAsHex
	 %%IsHex:
		pop         di
		mov         cx, si
		sub         cx, di
		jmp         %%DoAsHex
	 %%Done:
		pop         di
		ret
	%%DoAsHex:
		xor         ax, ax
		cmp         cx, 0
		je          %%BadHex
		; cmp         cx, 4
		; jle         %%MakeHex
		jmp         %%MakeHex
	%%BadHex:
		WriteStr    CommandLineErrorMsg
		Terminate   100
	%%MakeHex:
		push        cx
		mov         cl, 4
		shl         ax, cl
		pop         cx
		mov         bl, [di]
		inc         di
		cmp         bl, 0x30
		jl          %%BadHex
		cmp         bl, 0x39
		jg          %%NotNumber
		sub         bl, 0x30
		jmp         %%Adjusted
	%%NotNumber:
		cmp         bl, 0x41
		jl          %%BadHex
		cmp         bl, 0x46 ; 5a is Z
		jg          %%NotUpper
		sub         bl, 0x37
		jmp         %%Adjusted
	%%NotUpper:
		cmp         bl, 0x61
		jl          %%BadHex
		cmp         bl, 0x66 ; 7a is z
		jg          %%BadHex
		sub         bl, 0x57
	%%Adjusted:
		xor         bh, bh
		add         ax, bx
		loop        %%MakeHex
		ret     
	%%SkipOver:
	%endif
%endmacro

%imacro NumberParam 0
	NumberParamProc
	call 	NumberParam_Proc
%endmacro

%imacro LookupParamProc 0
	%ifndef LookupParamProc_Declared
		%idefine LookupParamProc_Declared
		jmp	%%SkipOver
	LookupParam_Proc:
		cmp         cx, 0
		je          %%NoValue
	%%Repeating:
		push        cx
		push        di
		cld
	%%Checking:
		lodsb
		cmp         al, 0
		je          %%EndOfKey
		mov         ah, [di]
		inc         di
		cmp         ah, 0x61
		jl          %%NotLowerCase
		cmp         ah, 0x7a
		jg          %%NotLowerCase
		sub         ah, 0x20
	%%NotLowerCase:
		cmp         al, ah
		jne         %%Different
		loop        %%Checking
		lodsb       
		cmp         al, 0
		je          %%EndOfKey
	%%Different:
		cmp         al, 0
		je          %%NotThisOne
		lodsb       
		jmp         %%Different
	%%EndOfKey:
		cmp         cl, 0
		je          %%Matched
	%%NotThisOne:
		pop         di
		pop         cx
		lodsw
		cmp         ax, 0xffff
		jne         %%Repeating
		jmp         %%Done
	%%Matched:
		pop         di
		pop         cx
		lodsw
		jmp         %%Done
	%%NoValue:
		mov         ax, 0xffff
	%%Done:
		ret
	%%SkipOver:
	%endif
%endmacro

%imacro LookupParam 1
	LookupParamProc
	push	si
	mov		si, %1
	call 	LookupParam_Proc
	pop		si
%endmacro

%imacro UseFrameBounds 0
	; current position
	mov				ah,0x03
	mov				bh, [VideoPage]
	int 			0x10
	; Save it for later
	push			dx
%%ScanUp:
	call			%%Check
	jnz				%%FrameTop
	cmp				dh, 0
	je				%%ScanLeft
	dec				dh
	jmp				%%ScanUp
%%FrameTop:	
	inc				dh
%%ScanLeft:
	call			%%Check
	jnz				%%FrameLeft
	cmp				dl, 0
	je				%%StartMaxScan
	dec				dl
	jmp				%%ScanLeft
%%FrameLeft:
	inc				dl
%%StartMaxScan:
	mov				ax, dx
	pop				dx
	push			dx
	mov				cx, dx
	sub				ch, ah
	sub				cl, al
	mov				[WindMin], ax
%%ScanDown:
	call			%%Check
	jnz				%%FrameBottom
	cmp				dh, [ScreenMaxY]
	je				%%ScanRight
	inc				dh
	jmp				%%ScanDown
%%FrameBottom:	
	dec				dh
%%ScanRight:
	call			%%Check
	jnz				%%FrameRight
	cmp				dl, [ScreenMaxX]
	je				%%ScanDone
	inc				dl
	jmp				%%ScanRight
%%FrameRight:
	dec				dl
%%ScanDone:
	mov				[WindMax], dx
	pop				dx
	mov				ah, 0x02
	int				0x10
	
	jmp				%%Done
%%Check:
	mov				ah, 0x02
	int				0x10
	mov				ah, 0x08
	int				0x10

	cmp				al, 0xc4
	je				%%Frame
	cmp				al, 0xcd
	je				%%Frame
	cmp				al, 0xb3
	je				%%Frame
	cmp				al, 0xba
	je				%%Frame

	mov				ah, 0
	cmp				ah, 0
	ret
%%Frame:
	mov				ah, 1
	cmp				ah, 0
	ret

%%Done:
%endmacro
