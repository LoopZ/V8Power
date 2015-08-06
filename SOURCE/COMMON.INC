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

%include "MACROS.INC"
%include "SNIPPETS.INC"
%include "DEBUG.INC"
%include "SWITCHES.INC"
%include "TABLES.INC"

; Write a single character
WriteCharProc:
;    mov         ah, 0x09
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    mov         cx, 0x0001
    int         0x10
    GotoNextXY
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
    