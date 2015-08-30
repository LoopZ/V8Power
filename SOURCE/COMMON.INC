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

use16

cpu 8086

org 0x100

jmp BasicInitialize

%imacro pushall 0
	pushf
	push	ax
	push 	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	es
	push	ds
%endmacro

%imacro popall 0
	pop 	ds
	pop		es
	pop		bp
	pop		di
	pop		si
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	popf
%endmacro

VersionID:
	dd 0
	
%idefine VideoOutput

%ifdef NoVideoOutput
	%undef VideoOutput
%endif

; Common Data Section
SECTION _DATA

	VideoMode:      DB 0
	VideoPage:      DB 0
	CursorShape:    DW 0
	TextAttr:       DB 0x07
	ScreenMax:
		ScreenMaxX:	DB 0
		ScreenMaxY	DB 0
	WindMin:        
		WindMinX:	DB 0
		WindMinY	DB 0
	WindMax:        
		WindMaxX:	DB 0
		WindMaxY	DB 0

CommandLineErrorMsg:
    DB          "Parameter Error",0

; Just Prefixing Here
SECTION _TEXT

%idefine CRLF 0x0d,0x0a
%idefine SwitchChar '/'
    
; get cursor position and size
WhereXYProc:
    mov         ah, 0x03
    mov         bh, [VideoPage]
    int         0x10
    push		cx
    ; [CursorXY], dx
    mov			cx, [WindMin]
    sub			dl, cl
    sub			dh, ch
    pop			cx
    ret
    
; move cursor to absolute position
GotoXYProc:
    mov         ah, 0x02
    mov         bh, [VideoPage]
    push		dx
    push		cx
    mov			cx, [WindMin]
    add			dh, ch
    add			dl, cl
    pop			cx
    int         0x10
    pop			dx
    ret

; Exit program and return to DOS with or without errorcode
%imacro Terminate 0-1 0
    mov         al, %1
    jmp         ProgramTerminate
%endmacro

%imacro WhereXY 0
    call        WhereXYProc
%endmacro
    
%imacro GotoXY 1-2
    %if %0 = 2
        mov     dl, %1
        mov     dh, %2
    %elif %0 = 1
        mov     dx, %1
    %endif
    call    GotoXYProc
%endmacro

; Move cursor to next position
%imacro GotoNextXY 0
    WhereXY
    inc         dl
    mov			bl, [WindMaxX]
    sub			bl, [WindMinX]
    cmp			dl, bl
    jle			%%Done
    mov			dl, 0
    inc			dh
    mov			bl, [WindMaxY]
    sub			bl, [WindMinY]
    cmp			dh, bl
    jl			%%Done
    dec			dh
	push		ax
	push		dx
	push		cx
	mov			ax, 0x0601
	mov			bh, [TextAttr]
	mov			cx, [WindMin]
	mov			dx, [WindMax]
	int			0x10
    pop			cx
    pop			dx
    pop			ax
%%Done:
    GotoXY      dx
%endmacro

; Read char/attribute at cursor location
%imacro ReadChar 0
    mov         ah, 0x08
    mov         bh, [VideoPage]
    int         0x10
%endmacro
    
%imacro WriteChar 0-1 0x09
	mov			ah, %1
    call        WriteCharProc 
%endmacro

; Write a ASCIIZ String and display control codes as characters
%imacro WriteRawStr 1
    mov         si, %1
    cld
%%WriteRawLoop:
    lodsb
    cmp         al, 0
    je          %%WriteRawDone
    WriteChar
    jmp         %%WriteRawLoop
%%WriteRawDone:
%endmacro
    
%imacro WriteStr 1
    mov         si, %1
    call        WriteStrProc
%endmacro

; Macro for Placeholder "dummy" programs not yet developed
%imacro PlaceHolder 0
    push        cs
    pop         ds
    mov         dx, %%Message
    mov         ah, 0x09
    int         0x21
    jmp         %%Done
%%Message:
    DB "This program is only a placeholder executable. "
    DB "It will be replaced by a program",0x0d,0x0a
    DB "that actually does something at a later time.$"
%%Done:
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
		WriteChar   0x09
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

; Write Word in AX
%imacro WriteIntNoAttr 1
    mov         ax, %1
	call		WriteIntNAProc    
	%ifndef WriteIntNAProc_Declared
		%idefine 	WriteIntNAProc_Declared
		jmp			%%Done
	WriteIntNAProc:
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
		WriteChar   0x0A
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

%imacro StdOutStr 1
	mov		di, %1
%%OutLoop:
	mov		ah, 0x02
	mov		dl, [di]
	cmp		dl, 0
	je		%%Done
	int		0x21
	inc		di
	jmp		%%OutLoop
%%Done:
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

%imacro StdIn 0
	mov		ah, 0x0b
	int		0x21
	cmp		al, 0
	je		%%NoInput
	mov		ah, 0x08
	int		0x21
	stc
	jmp		%%Done
%%NoInput:
	clc
%%Done:
%endmacro

; Very last CR/LF is ignored.
%imacro WriteStdIn 0
%%CheckInput:
	StdIn
	jnc			%%Done	
%%Ready:
	cmp			al, 0x0d
	je			%%CR_Found
	cmp			al, 0x0a
	je			%%LF_Found
	push		ax
%%WriteCR:
	mov			ah, [%%CRLF_Data]
	cmp			ah, 0
	je			%%WriteLF
	dec			ah
	mov			[%%CRLF_Data], ah	
	WriteStr	%%CR_String
	jmp			%%WriteCR
%%WriteLF:
	mov			ah, [%%CRLF_Data + 1]
	cmp			ah, 0
	je			%%WriteChar
	dec			ah
	mov			[%%CRLF_Data + 1], ah	
	WriteStr	%%LF_String
	jmp			%%WriteLF
%%WriteChar:
	pop			ax
	WriteChar  
	jmp			%%CheckInput
%%CR_String:
	db	0x0d,0
%%LF_String:
	db	0x0a,0
%%CRLF_Data:
	dw 0
%%CR_Found:
	mov			ah, [%%CRLF_Data]
	inc			ah
	mov			[%%CRLF_Data], ah	
	jmp			%%CheckInput
%%LF_Found:
	mov			ah, [%%CRLF_Data + 1]
	inc			ah
	mov			[%%CRLF_Data + 1], ah	
	jmp			%%CheckInput
%%Done:
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
    cmp         al, 0x09
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

; di points to start, cx is count of characters
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

%imacro FrameBoundsProc 0
	%ifndef FrameBoundsProc_Declared
		%idefine FrameBoundsProc_Declared
		jmp %%SkipOver
	FrameBounds_Proc:
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
		mov				[WindMinY], dh
		pop				dx
		push			dx
	%%ScanLeftLoop:
		call			%%Check
		jnz				%%FrameLeft
		cmp				dl, 0
		je				%%ScanDown
		dec				dl
		jmp				%%ScanLeftLoop
	%%FrameLeft:
		inc				dl
	%%ScanDown:
		mov				[WindMinX], dl
		pop				dx
		push			dx
	%%ScanDownLoop:
		call			%%Check
		jnz				%%FrameBottom
		cmp				dh, [ScreenMaxY]
		je				%%ScanRight
		inc				dh
		jmp				%%ScanDownLoop
	%%FrameBottom:	
		dec				dh
	%%ScanRight:
		mov				[WindMaxY], dh
		pop				dx
		push			dx
	%%ScanRightLoop:
		call			%%Check
		jnz				%%FrameRight
		cmp				dl, [ScreenMaxX]
		je				%%ScanDone
		inc				dl
		jmp				%%ScanRightLoop
	%%FrameRight:
		dec				dl
	%%ScanDone:
		mov				[WindMaxX], dl
		pop				dx
		mov				ah, 0x02
		int				0x10
	
		jmp				%%Done
	%%Check:
		mov				ah, 0x02
		int				0x10
		mov				ah, 0x08
		int				0x10

		cmp				al, 0xb3
		jl				%%NotFrame
		cmp				al, 0xda
		jg				%%NotFrame

	%%Frame:
		mov				ah, 1
		cmp				ah, 0
		ret
	%%NotFrame:
		mov				ah, 0
		cmp				ah, 0
		ret
	%%Done:
		ret
	%%SkipOver:
	%endif
%endmacro

%imacro FrameBounds 0
	FrameBoundsProc
	call	FrameBounds_Proc
%endmacro

; macro to print a character for debugging
%imacro DebugChar 0-1 al
    pushf
    push    ax
    push    bx
    push    cx
    push    dx
    push    di
    push    si
    mov     al, %1
    WriteChar
    pop     si
    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
%endmacro

; macro to print a character for debugging
%imacro DebugInt 0-1 ax
    pushf
    push    ax
    push    bx
    push    cx
    push    dx
    push    di
    push    si
    WriteInt %1
    pop     si
    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    popf
%endmacro
 
 ; macro that shows command line switch and data, mostly for debuging the
; command line parser
%imacro DebugCmdLn 0
    push        cx
    push        dx
    mov         al, ' '
    WriteChar
    pop         dx
    cmp         dl, 0
    je          %%NoSwitch
    push        dx
    mov         al, SwitchChar
    WriteChar
    pop         dx
    mov         al, dl
    WriteChar
    pop         cx
    push        cx
    cmp         cx, 0
    jne         %%NoSwitch
    pop         cx
    ret
%%NoSwitch:
    mov         al, '('
    WriteChar
    pop         cx
    cmp         cx, 0
    je          %%NoText
%%Repeat:
    push        cx
    mov         al, [di]
    WriteChar
    pop         cx
    inc         di
    loop        %%Repeat
%%NoText:
    mov         al, ')'
    WriteChar
    ret
%endmacro

%imacro AllocMem 1
	%ifnidni %1, bx
		mov		bx, %1
	%endif
	mov		ah, 0x48
	int		0x21
	jc		%%Error
	jmp		%%Done
%%Error:
	xor		ax, ax
%%Done:
	%ifnidni %1, ax
		mov	%1, ax
	%endif
%endmacro

%imacro FreeMem 1
	mov		ah, 0x49
	push	es
	push	%1
	pop		es
	int		0x21
	jc		%%Error
	xor		%1, %1
%%Error:
	pop		es
%endmacro

%imacro AllocTempVideoPage 0
	xor			ax, ax
	mov			cx, ax
	mov			al, [ScreenMaxX]
	inc			al
	mov			cl, [ScreenMaxY]
	inc			cl
	mul			cx
	mov			cl, 2
	mul			cx
	mov			dx, ax
	mov			cl, 4
	shr			ax, cl
	and 		dx, 0x0f
	cmp			dx, 0
	je			%%Even
	inc			ax
%%Even:
	AllocMem	ax
	mov			[TempVideoPagePtr], ax
	CopyToTempVideo
	jmp	%%Done
TempVideoPageSize:
	dw 0
TempVideoPagePtr:
	dw 0
%%Done:	
%endmacro

%imacro FreeTempVideoPage 0
	mov		bx,	[TempVideoPagePtr]
	cmp		bx, 0
	je		%%Done
	FreeMem bx
	mov		[TempVideoPagePtr], bx
%%Done:
%endmacro

%imacro	CopyToTempVideo 0
	mov		bx, [TempVideoPagePtr]
	cmp		bx, 0
	je		%%NoTemp
	push 	es
	push	si
	mov		es, bx
	xor		bx, bx
	mov		si, bx
	mov		bh, [VideoPage]
	mov		cx, [ScreenMax]
	inc		cl
	inc		ch
	xor 	dx, dx
%%CopyLoop:
	push	dx
	push	cx
	push 	bx
	mov		ah, 0x02
	int		0x10
	mov		ah, 0x08
	int		0x10
	mov		[es:si], ax
	add		si, 2
	pop		bx
	pop		cx
	pop		dx
	inc		dl
	dec		cl
	cmp		cl, 0
	jne		%%CopyLoop
	mov		cl, [ScreenMaxX]
	inc		cl
	xor		dl, dl
	dec		ch
	inc		dh
	cmp		ch, 0
	jne		%%CopyLoop
	pop		si
	pop		es
%%NoTemp:	
%endmacro

; CX is count, DX is coordinate, ax is attribute or 00 for restore
%imacro	CopyFromTempVideoProc 0
CopyFromTempVideo:
	mov		bx, [TempVideoPagePtr]
	cmp		bx, 0
	je		%%NoTemp
	push 	es
	push	si
	push	ax
	mov		es, bx
	mov		bh, [VideoPage]
	push	cx
	mov		al, [ScreenMaxX]
	inc		al
	xor		ah, ah
	push	dx
	mov		cl, dh
	push	dx
	mul		cx
	pop		dx
	xor		dh, dh
	add		ax, dx
	mov		cx, 1
	shl 	ax, cl	
	pop		dx
	pop		cx
	mov		si, ax
	pop		ax
%%CopyLoop:
	push	dx
	push	cx
	push 	bx
	push	ax
	mov		ah, 0x02
	int		0x10
	pop		ax
	push	ax
	cmp		ax, 0
	je		%%Restore
	mov		ah, [es:si]
	xchg	al, ah
	jmp		%%Write
%%Restore:
	mov		ax, [es:si]
%%Write:
	add		si, 2
	mov		bl, ah
	mov		cx, 1
	mov		ah, 0x09
	int		0x10
	pop		ax
	pop		bx
	pop		cx
	pop		dx
	inc		dl
	loop	%%CopyLoop
	pop		si
	pop		es
%%NoTemp:
	ret	
%endmacro

%include "SWITCHES.INC"
%include "TABLES.INC"

; Write a single character
WriteCharProc:
	push		ax ; some hardware destroys al (mainly vmware)
;    mov         ah, 0x09
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    mov         cx, 0x0001
    int         0x10
    GotoNextXY
    pop			ax
    ret
    
; Write a ASCIIZ String using control codes
WriteStrProc:
    cld
.WriteStrLoop:
    lodsb
    cmp         al, 0x00
    je          .WriteStrDone
    cmp         al, 0x0d
    je          .Return
    cmp         al, 0x0a
    je          .LineFeed
;   cmp         al, 0x08
;   je          .BackSpace
;   cmp         al, 0x09
;   je          .HTab
;   cmp         al, 0x0b
;   je          .VTab
;   cmp         al, 0x0c
;   je          .FormFeed
;   cmp         al, 0x07
;   je          .Bell
;   cmp         al, 0x7F
;   je          .Delete
    cmp         al, 0x20
    jl          .NoChar
    WriteChar
    jmp         .WriteStrLoop
.Return:
    WhereXY
    mov         dl, 0
    GotoXY      dx
    jmp         .WriteStrLoop
.LineFeed:
    WhereXY
    inc         dh
    mov			bh, [WindMaxY]
    mov			bl, [WindMinY]
    sub			bh, bl
    cmp			dh, bh
    jg			.ScrollUp
    GotoXY      dx
    jmp         .WriteStrLoop
.ScrollUp:
	mov			ax, 0x0601
	mov			bh, [TextAttr]
	mov			cx, [WindMin]
	mov			dx, [WindMax]
	int			0x10
    jmp         .WriteStrLoop
.BackSpace:
.HTab:
.VTab:
.FormFeed:
.Bell:
.Delete:
.NoChar:
    jmp         .WriteStrLoop
.WriteStrDone:
    ret
    
; Terminate with exit code and return to DOS
ProgramTerminate:
	%ifdef VideoOutput
		push        ax
		WhereXY     
		cmp         cx, [CursorShape]
		je          .Done
		mov         ah, 0x01
		mov         cx, [CursorShape]
		int         0x10
	.Done:
		pop         ax
    %endif
    mov         ah, 4ch  
    int         0x21

; Basic Initialization Stuff
BasicInitialize:
    push        es
    mov         bx, 0x0040
    push        bx
    pop         es
    
    ; detect current video mode
    mov         al, [es:0x0049]
    mov         [VideoMode], al
    xor         ah, ah
    cmp         al, 0x03
    jg          .NoTextAttr
    ReadChar    
    mov         [TextAttr], ah
.NoTextAttr:    
    
    ; detect active video page
    mov         al, [es:0x0062]
    mov         [VideoPage], al
    
    ; get current cursor shape and position
    WhereXY
    mov         [CursorShape], cx

    mov         [WindMin], word 0x0000

    mov         bx, [es:0x004A]
    dec         bx
    mov         bh, bl
    mov         bl, [es:0x0084]
    xchg        bl, bh
    mov         [ScreenMax], bx     
    mov         [WindMax], bx

	%ifdef VideoOutput
		; Hide cursor while we run
		mov         ah, 0x01
		mov         cx, 0x2000
		int         0x10
	%endif
            
    pop         es
    
    mov         si, 0x0081
    
    ; CX is Cursor Shape
    ; DX is Cursor Position
    ; BX is Screen Max
    ; SI is Pointed to Command Line
    