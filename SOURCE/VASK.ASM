; Copyright (C) 2015 Jerome Shidel
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
    ja      InputLoop

    mov     al, cl
    sub     al, bl
    inc     al
    mov     [Width], al

InputLoop:
    ; Draw the timeout number if used. Timeout, adjusts width if needed.
    mov         cx, [TimeOut]
    push        cx
    cmp         cx, 0x0000
    je          .NoTimeOut
    call        ShowTimeOut
 .NoTimeOut:
    ; Put cursor back and prepare to draw edit text.
    call        HideCursor
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
    mov         al, [Max]

.TextDisplay:
    ; Draw the editing text
    lodsb
    cmp         al, 0
    jz          .TextEnd
    call        .CharDisplay
    loop        .TextDisplay
    ; End of width, but not end of Text

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
    jmp         KeyBoardLoop
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
KeyLeft:
KeyRight:
KeyUp:
KeyDown:
KeyHome:
KeyEnd:
KeyBackSpace:
KeyDelete:
KeyEscape:
    jmp     InputLoop

KeyPgUp:
ScrollLeft:
    mov     al, [Start]
    cmp     al, 0
    je      InputLoop
    dec     al
    mov     [Start], al
    jmp     InputLoop

KeyPgDown:
ScrollRight:
    mov     al, [Start]
    mov     bl, [Width]
    mov     cl, [Max]
    sub     cl, bl
    cmp     al, cl
    jae     InputLoop
    xor     bh, bh
    add     bl, al
    dec     bl
    mov     ah, [TextBuffer + bx]
    cmp     ah, 0
    je      InputLoop
    inc     al
    mov     [Start], al
    jmp     InputLoop

KeyReturn:
    Terminate 0

KeyCtrlC:
    Terminate   200

TimedOut:
    Terminate 1

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
    SwitchData  0,  0, 0

OptionsTable:
	TableEnd

TextBuffer:    times 127 db 0
TextEnd:       db 0

EndChars:      dw 0x1011
TimeOut:       dw 0
ControlC:      db 1
EditMode:      dw 0
Start:         db 0
Width:         db 0
Max:           db TextEnd - TextBuffer
