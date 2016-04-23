; Copyright (C) 2016 Jerome Shidel
;
;	This program is free software; you can redistribute it and/or modify
;	it under the terms of the GNU General Public License as published by
;	the Free Software Foundation; either version 2 of the License, or
;	(at your option) any later version.
;
;	This program is distributed in the hope that it will be useful,
;	but WITHOUT ANY WARRANTY; without even the implied warranty of
;	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;	GNU General Public License for more details.
;
;	You should have received a copy of the GNU General Public License along
;	with this program; if not, write to the Free Software Foundation, Inc.,
;	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

; NASM for DOS

%include "COMMON.INC"

    FrameBounds

MainParsing:

    CommandLineParser       ; insert code for command line parsing

PrepData:
    cld
    ; Null extra buffer past Max input
    mov     di, TextBuffer
    mov     bl, [Max]
    xor     bh, bh
    add     di, bx
    xor     al, al
.Clean:
    cmp     di, TextEnd
    je      .CleanDone
    stosb
    jmp     .Clean
.CleanDone:
    mov     si, TextBuffer
    mov     di, 0x0081
.Clone:
    lodsb
    stosb
    cmp     di, 0x0100
    jne     .Clone

PrepWindow:
    WhereXY
    mov     cx, [WindMax]
    mov     bx, [WindMin]
    add     bh, dh
    add     bl, dl
    mov     ch, bh
    mov     [WindMax], cx
    mov     [WindMin], bx

    mov     al, [Width]
    cmp     al, 0
    ja      .WidthDone

    mov     al, cl
    sub     al, bl
    inc     al
    mov     [Width], al
.WidthDone:
    mov         cx, [TimeOut]
    cmp         cx, 0x0000
    je          .ValidWidth
    call        ShowTimeOut
.ValidWidth:
    mov         al, [Width]
    mov         ah, [Max]
    inc         ah
    cmp         al, ah
    jbe         KeyEnd
    dec         al
    mov         [Width], al
    jmp         .ValidWidth

InputLoop:
    ; Draw the timeout number if used. Timeout, adjusts width if needed.
    call        HideCursor
    mov         cx, [TimeOut]
    push        cx
    cmp         cx, 0x0000
    je          .NoTimeOut
    call        ShowTimeOut
 .NoTimeOut:
    ; Put cursor back and prepare to draw edit text.
    WhereXY
    push        dx
    mov         dl, 0
    mov         ch, dl
    mov         bh, dl
    mov         cl, [Width]
    cld
    mov         si, TextBuffer
    mov         bl, [Start]
    add         si, bx
    ; If offset replace first char with end cap.
    cmp         bl, 0
    je          .TextDisplay
    lodsb
    dec         cl
    mov         al, [EndCaps]
    call        .CharDisplay
.TextDisplay:
    ; Draw the editing text
    lodsb
    cmp         al, 0
    je          .NoCap
    cmp         cl, 1
    je          .EndCap
.NoCap:
    cmp         al, 0
    jne         .NoSpace
    mov         al, 0x20
.NoSpace:
    mov         ah, [PswdMode]
    cmp         ah, 0
    je          .NoPassword
    cmp         al, 0x20
    je          .NoPassword
    mov         al, [PswdChar]
.NoPassword:
    call        .CharDisplay
    loop        .TextDisplay
    ; End of width, but not end of Text
    jmp         .WidthEnd
.EndCap:
    mov         al, [EndCaps + 1]
    call        .CharDisplay
    jmp         .WidthEnd
.TextEnd:
    ; Fill remander with spaces
    mov         al, 0x20
    call        .CharDisplay
    loop        .TextEnd
.WidthEnd:
    ; Put cursor back to it's previous size and shape
    pop         dx
    GotoXY      dx
    call        EditCursor
    pop         cx
    mov         ax, [ExitFlag]
    cmp         ah, 0
    je          KeyBoardLoop
    push        ax
    xor         dx, dx
    GotoXY      dx
    mov         si, TextBuffer
    cld
.TextOut:
    lodsb
    cmp         al, 0
    je          .TextDone
	mov		    dl, al
	mov		    ah, 0x02
	int		    0x21
	jmp         .TextOut
.TextDone:
	mov		    dl, 0x0d
	int		    0x21
	mov		    dl, 0x0a
	int		    0x21
    pop         ax
    Terminate   al

.CharDisplay:
    push        ax
    GotoXY      dx
    pop         ax
    push        ax
    push        bx
    push        cx
    push        dx
    mov         ah, 0x09
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    mov         cx, 0x0001
    int         0x10
    pop         dx
    inc         dl
    pop         cx
    pop         bx
    pop         ax
    ret

KeyBoardLoop:
    push        es
    mov         bx, 0x0040
    mov         es, bx
    mov         bx, 0x006c
    mov         dx, [es:bx]
.WaitLoop:
    IdleCPU
    mov         ax, [TimeOut]
    cmp         ax, 0
    je          .NoTimeOut
    cmp         cx, 0
    jne         .NotTimedOut
    pop         es
    jmp         TimedOut
.NotTimedOut:
    mov         ax, [es:bx]
    cmp         ax, dx
    je          .NoTimeOut
    dec         cx
    mov         dx, ax
    call        ShowTimeOut
.NoTimeOut:
    mov         ax, 0x0100
    int         0x16
    jz          .WaitLoop
    pop         es

    mov         ax, 0x0000
    int         0x16

    mov         cx, ax
    cld
    mov         si, KeyTable
.Lookup:
    lodsw
    cmp         ax, 0
;    je          KeyDisplay
    je          KeyNormal
    mov         dx, ax
    lodsw
    cmp         dx, cx
    jne         .Lookup
    call        ax
    jmp         InputLoop

;KeyDisplay:
;    push        cx
;    mov         ax, 0x0600
;    mov         bh, [TextAttr]
;    mov         cx, [WindMin]
;    mov         dx, [WindMax]
;    int         0x10
;    xor         dx, dx
;    GotoXY      dx
;    pop         ax
;    StdOutHexWord
;    Terminate   0

KeyTable:
    dw      0x2e03, KeyCtrlC
    dw      0x1c0d, KeyReturn
    dw      0x1c0a, KeyReturn   ; Ctrl+Return
    dw      0x4b00, KeyLeft
    dw      0x4d00, KeyRight
    dw      0x4800, KeyUp
    dw      0x5000, KeyDown
    dw      0x4700, KeyHome
    dw      0x4f00, KeyEnd
    dw      0x4900, KeyPgUp
    dw      0x5100, KeyPgDown
    dw      0x0e08, KeyBackSpace
    dw      0x5300, KeyDelete
    dw      0x011b, KeyEscape
    dw      0x0000

KeyNormal:
    push    cx
    WhereXY
    pop     ax
    mov     bx, TextBuffer
    xor     ch, ch
    mov     cl, [Max]
    add     bx, cx
    dec     bx
    mov     cl, [bx]
    mov     di, bx
    cmp     cl, 0
    jne     InputLoop
    mov     bx, TextBuffer
    xor     ch, ch
    mov     cl, [Start]
    add     bx, cx
    xor     dh,dh
    add     bx, dx
    mov     ah, [EditMode]
    cmp     ah, 0
    jne     .Overtype
.Insert:
    cmp     bx, di
    jnb     .Overtype
    dec     di
    mov     ah, [di]
    mov     [di+1], ah
    jmp     .Insert
.Overtype:
    mov     [bx], al
    jmp     KeyRight

KeyBackSpace:
    WhereXY
    xor     cx,cx
    xor     dh, dh
    mov     cl, [Start]
    add     dx, cx
    cmp     dl, 0
    je      InputLoop
    call    MoveLeft
    jmp     KeyDelete

KeyDelete:
    WhereXY
    mov     bx, TextBuffer
    xor     dh,dh
    xor     ch,ch
    mov     cl, [Start]
    add     bx, cx
    add     bx, dx
    cld
    mov     di, bx
    mov     si, bx
    lodsb
.Removing:
    cmp     si, TextEnd + 1
    je      InputLoop
    lodsb
    stosb
    jmp     .Removing

KeyLeft:
    call    MoveLeft
    jmp     InputLoop

KeyRight:
    call    MoveRight
    jmp     InputLoop

KeyUp:
    WhereXY
    mov     bl, [Width]
    dec     bl
    cmp     bl, dl
    jbe     .DontShift
    mov     al, [Start]
    push    ax
    call    ScrollLeft
    pop     ax
    mov     ah, [Start]
    cmp     al, ah
    je      .DontShift
    jmp     InputLoop
.DontShift:
    call    MoveLeft
    jmp     InputLoop

KeyDown:
    WhereXY
    cmp     dl, 0
    je      .DontShift
    mov     al, [Start]
    push    ax
    call    ScrollRight
    pop     ax
    mov     ah, [Start]
    cmp     al, ah
    je      .DontShift
    jmp     InputLoop
.DontShift:
    call    MoveRight
    jmp     InputLoop

KeyHome:
    call    MoveHome
    jmp     InputLoop

KeyEnd:
    call    MoveEnd
    jmp     InputLoop

KeyEscape:
    call    DataReset
    jmp     KeyEnd

KeyPgUp:
    mov     cl, [Width]
    cmp     cl, 2
    jna     InputLoop
    xor     ch, ch
    sub     cx, 2
.Moving:
    push    cx
    call    MoveLeft
    pop     cx
    loop    .Moving
    jmp     InputLoop

KeyPgDown:
    mov     cl, [Width]
    cmp     cl, 2
    jna     InputLoop
    xor     ch, ch
    sub     cx, 2
.Moving:
    push    cx
    call    MoveRight
    pop     cx
    loop    .Moving
    jmp     InputLoop

KeyReturn:
    mov         ax, 0x0100
    mov         [ExitFlag], ax
    jmp         InputLoop

KeyCtrlC:
    mov         al, [ControlC]
    cmp         al, 0
    je          InputLoop
    call        DataReset
    mov         ax, 0x01c8
    mov         [ExitFlag], ax
    jmp         InputLoop

DataReset:
    call    MoveHome
    mov     di, TextBuffer
    mov     si, 0x0081
.Clone:
    lodsb
    stosb
    cmp     si, 0x0100
    jne     .Clone
    call    MoveEnd
    ret

ScrollLeft:
    mov     al, [Start]
    cmp     al, 0
    je      .Ignore
    dec     al
    mov     [Start], al
.Ignore:
    ret

ScrollRight:
    mov     al, [Start]
    mov     bl, [Width]
    mov     cl, [Max]
    sub     cl, bl
    cmp     al, cl
    ja      .Ignore
    xor     bh, bh
    add     bl, al
    dec     bl
    mov     ah, [TextBuffer + bx]
    cmp     ah, 0
    je      .Ignore
    inc     al
    mov     [Start], al
.Ignore:
    ret

MoveLeft:
    WhereXY
    cmp     dl, 1
    ja      .Moving
    mov     bl, [Start]
    cmp     bl, 0
    jne     ScrollLeft
.Moving:
    cmp     dl, 0
    je      .DontMove
    dec     dl
    GotoXY  dx
.DontMove:
    ret

MoveRight:
    WhereXY
    mov     al, [Start]
    mov     bl, [Width]
    mov     cl, [Max]
    sub     cl, bl
    cmp     al, cl
    ja      .OnlyMove
    xor     bh, bh
    add     bl, al
    dec     bl
    mov     ah, [TextBuffer + bx]
    cmp     ah, 0
    je      .OnlyMove
    mov     bl, [Width]
    dec     bl
    dec     bl
    cmp     dl, bl
    jnb     ScrollRight
.OnlyMove:
    inc     dl
    mov     bl, [Width]
    cmp     dl, bl
    jnb     .DontMove
    xor     bh, bh
    mov     bl, [Start]
    add     bl, dl
    dec     bl
    mov     al, [bx + TextBuffer]
    cmp     al, 0
    je      .DontMove
    GotoXY  dx
.DontMove:
    ret

MoveHome:
    mov     cl, [Max]
    xor     ch, ch
.Moving:
    push    cx
    call    MoveLeft
    pop     cx
    loop    .Moving
    ret

MoveEnd:
    mov     cl, [Max]
    xor     ch, ch
.Moving:
    push    cx
    call    MoveRight
    pop     cx
    loop    .Moving
    ret

TimedOut:
    call        DataReset
    mov         ax, 0x0101
    mov         [ExitFlag], ax
    jmp         InputLoop

HideCursor:
    push        dx
    mov         cx, 0x2000
    mov         ah, 0x01
    int         0x10
    pop         dx
    ret

EditCursor:
    push        dx
    xor         ah, ah
    mov         al, [EditMode]
    mov         bx, 0x0040
    push        es
    mov         es, bx
    mov         cl, [es:0x0085]
    pop         es
    cmp         ax, 0
    jne         .NotSmall
    mov         al, cl
    mov         ah, al
    sub         ah, 2
    jmp         .Done
.NotSmall:
    cmp         ax, 1
    jne         .NotHalf
    mov         al, cl
    mov         ah, al
    shr         ah, 1
    jmp         .Done
.NotHalf:
    mov         al, cl
    mov         ah, 0
.Done:
    mov         cx, ax
    mov         ah, 0x01
    int         0x10
    pop         dx
    ret

ShowTimeOut:
    push        cx
    push        bx
    push        dx

    mov         ax, dx
    xor         dx, dx
    mov         ax, 11
    xchg        ax, cx
    mul         cx
    mov         cx, 200
    div         cx

    mov         dx, [TimeOutMax]
    cmp         ax, dx
    jb          .Smaller
    mov         ax, dx
.Smaller:

    mov         dl, [WindMax]
    mov         bl, [WindMin]
    xor         dh, dh
    sub         dl, bl
    dec         dl
    cmp         ax, 10
    jb         .SetPosition
    dec         dl
    cmp         ax, 100
    jb         .SetPosition
    dec         dl
    cmp         ax, 1000
    jb         .SetPosition
    dec         dl
 .SetPosition:
    mov         bh, [Width]
    cmp         bh, dl
    jb          .WidthOk
    mov         [Width], dl
.WidthOk:
    push        ax
    push        dx
    WhereXY
    pop         cx
    pop         ax
    push        dx
    push        ax
    GotoXY      cx
    mov         al, 0x20
    WriteChar   0x0A
    pop         ax
    WriteIntSys ax
    pop         dx
    GotoXY      dx
    pop         dx
    pop         bx
    pop         cx
    ret

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je	        .NotOption
	jmp			ax

.NotOption:
    mov         bx, TextBuffer
.BufferSearch:
    mov         al, [bx]
    cmp         al, 0
    je          .BufferEnd
    inc         bx
    jmp         .BufferSearch
.BufferEnd:
    cmp         bx, TextBuffer
    je          .BufferLoop
    mov         al, 0x20
    jmp         .BufferStore
.BufferLoop:
    cmp         di, si
    je          .BufferDone
    cmp         bx, TextEnd
    je          SwitchError
    mov         al, [di]
    inc         di
.BufferStore:
    mov         [bx], al
    inc         bx
    jmp         .BufferLoop
.BufferDone:
	ret

SwitchW:
    NumberParam
    cmp     ax, 5
    jl      SwitchError
    cmp     ax, 0x00ff
    jg      SwitchError
    push    ax
    WhereXY
    pop     ax
    mov     cl, [WindMaxX]
    mov     ch, [WindMinX]
    sub     cl, ch
    sub     cl, dl
    inc     cl
    xor     ah, ah
    xor     ch, ch
    cmp     ax, cx
    jg      SwitchError
    mov     [Width], al
    ret

SwitchD:
    NumberParam
    mov         [TimeOutMax], ax
    cmp         ax, 0
    je          .SwitchOff
    cmp         ax, 3600
    jle         .SwitchOK
    mov         ax, 3600
.SwitchOK:
    inc         ax
    mov         cx, 200
    mul         cx
    mov         cx, 11
    div         cx
    inc         ax
.SwitchOff:
    mov         [TimeOut], ax
    ret

SwitchM:
    NumberParam
    mov     cx, TextEnd - TextBuffer
    cmp     ax, cx
    ja      SwitchError
    cmp     ax, 0
    je      SwitchError
    mov     [Max], ax
    ret

SwitchC:
    mov     al, 1
    mov     [ControlC], al
    ret

SwitchP:
    mov     al, 1
    mov     [PswdMode], al
    ret

%include "TRANSLAT.INC"

SwitchT:
    Translator MainParsing

    LocalSwitchHandlers
    ColorSwitchHandlers
	HelpSwitchHandler

CommandLineSwitches:
	SwitchData  0,  0, NoSwitch
    ColorSwitchData
 	HelpSwitchData
    LocalSwitchData
    SwitchData 'W', 1, SwitchW
    SwitchData 'D', 1, SwitchD
    SwitchData 'M', 1, SwitchM
    SwitchData 'C', 0, SwitchC
    SwitchData 'P', 0, SwitchP
    SwitchData 'T', 1, SwitchT
    SwitchData  0,  0, 0

OptionsTable:
	TableEnd

TextBuffer:    times 0x0100 - 0x0081 db 0
TextEnd:       db 0

ExitFlag:      dw 0x0000
EndCaps:       dw 0x1011
PswdChar:      db '*'
TimeOut:       dw 0
TimeOutMax:    dw 0
ControlC:      db 0
PswdMode:      db 0
EditMode:      dw 0 ; 0 insert mode, 1&2 overtype cursor size.
Start:         db 0
Width:         db 0
Max:           db TextEnd - TextBuffer
