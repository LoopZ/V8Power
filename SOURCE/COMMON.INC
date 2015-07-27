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

; common macros

%idefine CRLF 0x0d,0x0a
%idefine SwitchChar '/'
    
; Exit program and return to DOS with or without errorcode
%imacro Terminate 0-1 0
    mov         al, %1
    jmp         ProgramTerminate
%endmacro

; Return a single byte in AL from a memory location
%imacro MemByte 2
    push        es
    push        bx
    mov         bx, %1
    mov         es, bx
    mov         bx, %2
    mov         al, [es:bx]
    pop         bx
    pop         es 
%endmacro

; Return a single word in AX from a memory location
%imacro MemWord 2
    push        es
    push        bx
    mov         bx, %1
    mov         es, bx
    mov         bx, %2
    mov         ax, [es:bx]
    pop         bx
    pop         es 
%endmacro

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

; get cursor position and size
%imacro WhereXY 0
    mov         ah, 0x03
    mov         bh, [VideoPage]
    int         0x10
    ; mov       [CursorXY], dx
%endmacro

; move cursor to absolute position
%imacro GotoXY 1-2
    %if %0 = 2
        mov     dl, %1
        mov     dh, %2
    %elifidni %1 = dx
        ; ok ignore it
    %else
        mov     dx, %1
    %endif
    mov         ah, 0x02
    mov         bh, [VideoPage]
    int         0x10
%endmacro

; Move cursor to next position
%imacro GotoNextXY 0
    WhereXY
    inc         dl
    GotoXY      dx
%endmacro

; Read char/attribute at cursor location
%imacro ReadChar 0
    mov         ah, 0x08
    mov         bh, [VideoPage]
    int         0x10
%endmacro

; Write a single character
%imacro WriteChar 0
    mov         ah, 0x09
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    mov         cx, 0x0001
    int         0x10
    GotoNextXY
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

; Write a ASCIIZ String using control codes
%imacro WriteStr 1
    mov         si, %1
    cld
%%WriteStrLoop:
    lodsb
    cmp         al, 0x00
    je          %%WriteStrDone
    cmp         al, 0x0d
    je          %%Return
    cmp         al, 0x0a
    je          %%LineFeed
;   cmp         al, 0x08
;   je          %%BackSpace
;   cmp         al, 0x09
;   je          %%HTab
;   cmp         al, 0x0b
;   je          %%VTab
;   cmp         al, 0x0c
;   je          %%FormFeed
;   cmp         al, 0x07
;   je          %%Bell
;   cmp         al, 0x7F
;   je          %%Delete
    cmp         al, 0x20
    jl          %%NoChar
    WriteChar
    jmp         %%WriteStrLoop
%%Return:
    WhereXY
    mov         dl, [WindMin]
    GotoXY      dx
    jmp         %%WriteStrLoop
%%LineFeed:
    WhereXY
    inc         dh
    GotoXY      dx
    jmp         %%WriteStrLoop
%%BackSpace:
%%HTab:
%%VTab:
%%FormFeed:
%%Bell:
%%Delete:
%%NoChar:
    jmp         %%WriteStrLoop
%%WriteStrDone:
%endmacro

; Write Word in AX
%imacro WriteInt 1
    mov         ax, %1
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

; simple macro for adding command line switch data
%imacro CmdSwitch 3
    DB  %1
    DB  %2
    DW  %3
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
    je          %%Switch
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
    cmp         al, 0x0d
    je          %%Done
    cmp         al, 0x20
    jne         %%ResetBX
    cmp         cx, 1
    push        cx
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
%%ErrorMsg: 
    DB          "Error parsing command-line options.",CRLF,0
%%Error:
    WriteStr    %%ErrorMsg
    Terminate   100
%%Done:
    cmp         bx, 0
    jne         %%Error
%endmacro

; macro that shows command line switch and data, mostly for debuging the
; command line parser
%imacro CommandLineDebug 0
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

; Common Data Section
SECTION _DATA

VideoMode:      DB 0
VideoPage:      DB 0
ScreenMax:      DW 0
CursorShape:    DW 0
WindMin:        DW 0
WindMax:        DW 0
TextAttr:       DB 0x07


; Just Prefixing Here
SECTION _TEXT

; Terminate with exit code and return to DOS
ProgramTerminate:
    push        ax
    WhereXY     
    cmp         cx, [CursorShape]
    je          .Done
    mov         ah, 0x01
    mov         cx, [CursorShape]
    int         0x10
.Done:
    pop         ax
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

    mov         ah, 0x01
    mov         cx, 0x2000
    int         0x10
            
    pop         es
    
    mov         si, 0x0081
    
    ; CX is Cursor Shape
    ; DX is Cursor Position
    ; BX is Screen Max
    ; SI is Pointed to Command Line
    