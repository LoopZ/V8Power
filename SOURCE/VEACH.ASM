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
%idefine MAX_DATA 0x4000

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

    call        Index

%imacro FindShell 1
    jmp         %%Over
%%COMSPEC:
    db 'COMSPEC',0
%%COMMAND:
    db 'COMMAND.COM',0
%%Over:
    push        ds
    mov         di, %1
    SearchEnv   %%COMSPEC
    jc          %%NotFound
    cld
    mov         cx, 127
%%CopyEnv:
    lodsb
    cmp         al, 0x00
    je          %%EnvCopied
    cs stosb
    cmp         al, 0x20
    je          %%EnvCopied
    loop        %%CopyEnv
%%EnvCopied:
    xor         al, al
    cs stosb
    jmp         %%Done
%%NotFound:
    xor         al, al
    cs stosb
%%Done:
    pop         ds

%endmacro

    FindShell   Shell
    StdOutStr   Shell
    StdOutCRLF
    jmp         Done

    mov         cx, [CommandLength]
    cld
    mov         si, [CommandLine]
Repeater:
    lodsb
    StdOutChar  al
    loop        Repeater
    jmp         Done

    multipush   bx, cx, es, ds, si, di
    push        cs
    pop         es
    ; mov         ax, StackBottom + STACK_SIZE
    ; add         ax, [DataPointer]
    ; add         ax, 2
    mov         ax, [DataTop]
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

    ; ShellExec   Program, Options

Done:
    mov     al, [ExitCode]
    Terminate al

    UseAdvancedStdIn

Out_of_Memory:
    StdOutStr   Out_of_Memory_Message
    Terminate   8

Index:
    xor         ah, ah
    mov         si, [DataStart]
    mov         di, [DataPointer]
    mov         bx, di
    dec         bx
.Repeat:
    cmp         si, bx
    jae         .Done
    mov         al, [si]
;    cmp         al, 0x00
;    je          .Done
    mov         [di], si
    add         ax, 2
    add         si, ax
    add         di, 2
    cmp         di, MAX_DATA
    jae         Out_of_Memory
    jmp         .Repeat
.Done:
    mov         [DataTop], di
    mov         al, [Sorted_Flag]
    cmp         al, 0x00
    jne         SortedIndex
    ret

; Super simple bubble sort
SortedIndex:
    mov         dx, 0
    mov         si, [DataPointer]
    mov         bx, [DataTop]
    dec         bx
.Repeat:
    add         si, 2
    cmp         si, bx
    jae         .Done
    push        si
    mov         di, [si]
    mov         si, [si - 2]
.Check:
    inc         si
    inc         di
    mov         al, [si]
    mov         ah, [di]
    cmp         al, ah
    jb          .LessThan
    ja          .GreaterThan
    cmp         al, 0
    jne         .Check
.Match:
.LessThan:
    pop         si
    jmp         .Repeat
.GreaterThan:
    pop         si
    mov         ax, [si - 2]
    mov         cx, [si]
    mov         [si - 2], cx
    mov         [si], ax
    mov         dx, 1
.Done:
    cmp         dx, 0
    jne         SortedIndex
    ret

SwitchI:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    mov         bx, [DataPointer]
    xor         dx, dx

ReadInput:
    mov         di, bx
    xor         cx, cx
    mov         [di], cl
    inc         bx
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
    mov         [bx], al
    inc         bx
    mov         [di], cl
    xor         cx, cx
    mov         di, bx
    inc         bx
    jmp         .Test
.CHAR_Found:
    cmp         al, 0
    je         .CheckInput
    xor         ah, ah
    mov         [.CRLF_Data], ah
.IsNotNull:
    cmp         cl, 128
    jae         .Test
    mov         [bx], al
    inc         bx
    inc         cx
.Test:
    mov         ax, MAX_DATA
    cmp         bx, ax
    jae         Out_of_Memory
	jmp         .CheckInput

.Buffer:
    dw  0

.ReadFile:
    push        bx
    push        dx
    push        cx
    push        di
    mov         ah, 0x3f
    mov         bx, dx
    mov         cx, 0x0001
    mov         dx, .Buffer
    int         0x21
    pop         di
    pop         cx
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
    mov         dx, [DataPointer]
    mov         ax, bx
    dec         ax
    cmp         ax, dx
    jna         .BackupPointer
    mov         [di], cl
    mov         al, [.CRLF_Data]
    xor         ah, ah
    mov         [.CRLF_Data], ah
    cmp         al, 0x00
    jne         .BackupPointer
    mov         [bx], ah
    inc         bx
    mov         ax, MAX_DATA
    cmp         bx, ax
    jae         Out_of_Memory
    jmp         .SavePointer
.BackupPointer:
    cmp         bx, dx
    jna         .SavePointer
    dec         bx
.SavePointer:
    mov         [DataPointer], bx
    ret

SwitchL:
    call        Index
    cld
    mov         si, [DataPointer]
    mov         cx, [DataTop]
.Loop:
    cmp         si, cx
    jae         .Done
    lodsw
    push        si
    push        cx
    inc         ax
    StdOutStr   ax
    StdOutCRLF
    pop         cx
    pop         si
    jmp         .Loop
.Done:
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

SwitchD:
    mov         bx, [DataPointer]
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    mov         al, [si]
    push        ax
    xor         al, al
    mov         [si], al

    push        bx
    mov         ah, 0x1a            ;Set DTA
    mov         dx, DTA
    int         0x21
    mov         cx, 0xffff          ;File Attribute
    mov         dx, di
    mov         ah, 0x4e            ;Find First File
    int         0x21
    pop         bx
    jc          .NoMatch

.AddItem:
    cld
    mov         si, DTA + 0x1e
    mov         cx, 0x0c
    mov         dx, MAX_DATA
    mov         ax, [si]
    cmp         ax, 0x2e2e
    je          .SkipItem
    cmp         ax, 0x002e
    je          .SkipItem
    mov         al, [AllFiles_Flag]
    cmp         al, 0x01
    je          .Repeat
    mov         al, [DTA + 0x15]
    test        al, 00011110b
    jnz         .SkipItem
    mov         di, bx
    inc         bx
    xor         ah, ah
.Repeat:
    lodsb
    cmp         al, 0x00
    je          .EndOfName
    inc         ah
    mov         [bx], al
    inc         bx
    cmp         bx, dx
    jae         Out_of_Memory
    loop        .Repeat
    xor         al, al
.EndOfName:
    mov         [bx], al
    mov         [di], ah
    inc         bx
    cmp         bx, dx
    jae         Out_of_Memory

.SkipItem:

    push        bx
    mov         ah, 0x4f            ;Find next
    int         0x21
    pop         bx
    jnc         .AddItem

.NoMatch:
    pop         ax
    mov         [si], al
    mov         [DataPointer], bx
    ret

SwitchC:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    inc         al
    mov         [Continue_Flag], al
    ret

SwitchS:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    inc         al
    mov         [Sorted_Flag], al
    ret

SwitchX:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    inc         al
    mov         [Execute_Flag], al
    ret

SwitchA:
    mov         al, [Execute_Flag]
    cmp         al, 0x0
    jne         SwitchError
    xor         al, al
    mov         ah, [di]
    cmp         ah, '-'
    je          .SetFlag
    cmp         ah, '+'
    jne         SwitchError
    mov         al, 0x01
.SetFlag:
    mov         [AllFiles_Flag], al
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

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'I', 0, SwitchI ; StdIO
    SwitchData  'F', 1, SwitchF ; From File
    SwitchData  'A', 1, SwitchA ; All Files and Directories on/off
    SwitchData  'D', 1, SwitchD ; Directory Search
    SwitchData  'L', 0, SwitchL ; Display List
    SwitchData  'X', 0, SwitchX ; Execute
    SwitchData  'C', 0, SwitchC ; Continue despite any errors
    SwitchData  'S', 0, SwitchS ; Sort List
    HelpSwitchData
    SwitchData  0,  0, 0

Memory_Error_Message:
    db  "Memory Error",CRLF,0

Out_of_Memory_Message:
    db  "Out of memory",CRLF,0

File_Not_Found_Message:
    db "File not found",CRLF,0

File_Read_Error_Message:
    db "File read error",CRLF,0

Search:
    db '.COM',0
    db '.EXE',0
    db '.BAT',0

ExitCode:
    db 0

Continue_Flag:
    db 0
Execute_Flag:
    db 0
AllFiles_Flag:
    db 0
Sorted_Flag:
    db 0

DataStart:
    dw 0
DataPointer:
    dw 0
DataTop:
    dw 0
CommandLength:
    dw 0
CommandLine:
    dw 0

Shell:
DTA:
    times 128 db 0
DTAEnd:

StackBottom:
