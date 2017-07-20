; Copyright (C) 2017 Jerome Shidel
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

%idefine NoVideoOutput

%include "COMMON.INC"

%idefine STACK_SIZE 0x0200
%idefine MAX_DATA 0x1000

    mov         sp, StackBottom + STACK_SIZE
    mov         ax, sp
    add         ax, 2
    mov         [DataStart], ax
    mov         [DataPointer], ax

MainParsing:

    CommandLineParser       ; insert code for command line parsing

    multipush   bx, cx, es, ds, si, di
    push        cs
    pop         es
    ; mov         ax, StackBottom + STACK_SIZE
    ; add         ax, [DataPointer]
    ; add         ax, 2
    mov         ax, [DataPointer]
    inc         ax

    mov         cl, 4
    shr         ax, cl
    inc         ax
    mov         bx, ax
    mov         ax, 0x4a00
    int         0x21
    jnc         .Reduced
    multipop    bx, cx, es, ds, si, di
    StdOutStr   Memory_Error_Message
    Terminate   8
.Reduced:
    multipop    bx, cx, es, ds, si, di

    mov     al, [ExitCode]
    Terminate al

    UseAdvancedStdIn

Out_of_Memory:
    StdOutStr   Out_of_Memory_Message
    Terminate   8


SwitchI:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    push        bx
    mov         bx, [DataPointer]
.CheckInput:
	StdIn
	jnc			.Done
.Ready:
	cmp			al, 0x0d
	je			.CRLF_Found
	cmp			al, 0x0a
	jne			.CHAR_Found
.CRLF_Found:
    mov         ah, [.CRLF_Data]
    cmp         ah, 0
    jne         .CheckInput
    inc         ah
    mov         [.CRLF_Data], ah
    xor         al, al
    jmp         .IsNotNull
.CHAR_Found:
    cmp         al, 0
    je         .CheckInput
    xor         ah, ah
    mov         [.CRLF_Data], ah
.IsNotNull:
    mov         [bx], al

    inc         bx
    mov         ax, MAX_DATA
    cmp         bx, ax
    jae         Out_of_Memory
	jmp         .CheckInput

.CRLF_Data:
    db          0

.Done:
    xor         al, al
    mov         [.CRLF_Data], al
    mov         [DataPointer], bx
    pop         bx
    ret


SwitchL:
    push        bx
    push        cx
    mov         cx, [DataPointer]
    mov         bx, [DataStart]
.Loop:
    cmp         bx, cx
    jae         .Done
    mov         dl, [bx]
    inc         bx
    cmp         dl, 0
    jne         .Normal
    StdOutCRLF
    jmp         .Loop
.Normal:
    StdOutChar  dl
    jmp         .Loop
.Done:
    pop         cx
    pop         bx
    ret

SwitchF:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    ret
SwitchS:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    ret

SwitchX:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    inc         al
    mov         [Execute_Flag], al
    ret

ShellExec   .Program, .Options

ret
.Program:
    db "C:\FDOS\BIN\MEM.EXE",0
.Options:
    db "/c/p",0

NoSwitch:
    mov         al, [Execute_Flag]
    cmp         al, 0x01
    jne         SwitchError
    inc         al
    mov         [Execute_Flag], al
    mov         [CommandLine], di
    mov         [CommandLength], cx
    ret

    HelpSwitchHandler

%include "TRANSLAT.INC"

;SwitchT:
;    Translator MainParsing

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'I', 0, SwitchI
    SwitchData  'F', 1, SwitchF
    SwitchData  'S', 1, SwitchS
    SwitchData  'L', 0, SwitchL
    SwitchData  'X', 0, SwitchX

    HelpSwitchData
    SwitchData  0,  0, 0

Memory_Error_Message:
    db  "Memory Error",CRLF,0

Out_of_Memory_Message:
    db  "Out of memory",CRLF,0

File_Not_Found_Message:
    db "File not found",CRLF,0

ExitCode:
    db 0

Execute_Flag:
    db 0

DataStart:
    dw 0
DataPointer:
    dw 0
CommandLength:
    dw 0
CommandLine:
    dw 0


StackBottom:
