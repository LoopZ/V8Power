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
    add         ax, 0x0002
    mov         [DataStart], ax
    mov         [DataPointer], ax

MainParsing:

    CommandLineParser       ; insert code for command line parsing

    mov         al, [Execute_Flag]
    cmp         al, 0x00
    je          Done

    multipush   bx, cx, es, ds, si, di
    push        cs
    pop         es
    ; mov         ax, StackBottom + STACK_SIZE
    ; add         ax, [DataPointer]
    ; add         ax, 2
    mov         ax, [DataPointer]
;    inc         ax

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

    ShellExec   Program, Options

Done:
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
    mov         bx, [DataPointer]
    xor         dx, dx

ReadInput:
.CheckInput:
    cmp         dx, 0x0000
    jne         .ReadFile
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

.Buffer:
    dw  0

.ReadFile:
    push        bx
    push        dx
    mov         ah, 0x3f
    mov         bx, dx
    mov         cx, 0x0001
    mov         dx, .Buffer
    int         0x21
    pop         dx
    pop         bx
    jnc         .NoError
    mov         bx, dx
    mov         ah, 0x3e
    int         0x21
    push        dx
    jmp         FileError
.NoError:
    cmp         ax, 0
    je          .Done
    mov         al, [.Buffer]
    jmp         .Ready

.CRLF_Data:
    db          0

.Done:
    mov         al, [.CRLF_Data]
    xor         ah, ah
    mov         [.CRLF_Data], ah
    cmp         al, 0x00
    jne         .SavePointer
    mov         [bx], ah
    inc         bx
    mov         ax, MAX_DATA
    cmp         bx, ax
    jae         Out_of_Memory
.SavePointer:
    mov         [DataPointer], bx
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
    mov         bx, [DataPointer]
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    xor         dl, dl
    mov         dh, [si]
    mov         [si], dl
    push        dx
    mov         dx, di
    mov         ax, 0x3d00
    int         0x21
    jc          FileError
    mov         dx, ax
    call        ReadInput
    mov         bx, dx
    mov         ah, 0x3e
    int         0x21
    pop         dx
    mov         [si], dl
    ret

FileError:
    pop         dx
    mov         ah, [Continue_Flag]
    cmp         ah, 0x00
    je          .DieNow
    ret
.DieNow:
    StdOutStr   File_Read_Error_Message
    mov         [ExitCode], al
    Terminate   al

SwitchS:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    ret

SwitchC:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    inc         al
    mov         [Continue_Flag], al
    ret

SwitchX:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    inc         al
    mov         [Execute_Flag], al
    ret

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
    SwitchData  'I', 0, SwitchI ; StdIO
    SwitchData  'F', 1, SwitchF ; From File
    SwitchData  'S', 1, SwitchS ; Directory Search
    SwitchData  'L', 0, SwitchL ; Display List
    SwitchData  'X', 0, SwitchX ; Execute
    SwitchData  'C', 0, SwitchC ; Continue despite any errors

    HelpSwitchData
    SwitchData  0,  0, 0

Program:
    db "C:\FDOS\BIN\MEM.EXE",0
Options:
    db "/c/p",0

Memory_Error_Message:
    db  "Memory Error",CRLF,0

Out_of_Memory_Message:
    db  "Out of memory",CRLF,0

File_Not_Found_Message:
    db "File not found",CRLF,0

File_Read_Error_Message:
    db "File read error",CRLF,0

ExitCode:
    db 0

Continue_Flag:
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
