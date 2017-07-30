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
%include "FIND.INC"

%idefine SIZEOF_STACK   0x0100  ; Required Stack bytes, don't need this much.
%idefine SIZEOF_MEMORY  0x4000  ; Maximum bytes of memory program can use.
%idefine SIZEOF_BUFFER  2       ; Size of StdIn/File buffer. Should increase
                                ; this and do some buffer caching reads to
                                ; increase performance.

struc tDATABLOCK

    .EXITCODE   resb 1  ; Stored Exitcode
    .CONTINUE   resb 1  ; Continue despite errors
    .EXECUTE    resb 1  ; execute mode flag
    .ALLFILES   resb 1  ; include dir,sys and hidden files
    .SORTED     resb 1  ; sort list

    .RELATIVE   resw 1  ; relative path search only Colon/Slash
    .WATCHCRLF  resb 1  ; cr/lf input tracking

    .MEMSTART   resw 1  ; start of heap
    .MEMPTR     resw 1  ; first free heap byte, sometimes destroyable temp
                        ; data exists above MEMPTR. like, sorted list index.
    .MEMTOP     resw 1  ; end of heap. All memory above here can be freed when
                        ; doing the Shell Execute.

    .CMDLEN     resw 1  ; Length of Command Line
    .CMDLN      resw 1  ; ASCIIZ Command Line

    .BUFFER     resb SIZEOF_BUFFER ; Standard Input Buffer

    .DTA        resb 128 ; Directory searching buffer
    .COMSPEC    resb 128 ; Stored COMSPEC or location of COMMAND.COM
    .SEARCHNAME resb 128 ; Temporary Fully qualified Search Filename
    .SEARCHPATH resb 128 ; Path to search for executables.
    .RELNAME    resb 128 ; Reformatted name for relative path search only

    .TEMPNAME   resb 128 ; Remove when W switch is removed

    .ZERO       resb 0   ; Unused at present

    .STACK      resb SIZEOF_STACK

    .HEAP       resb 0

endstruc

%idefine DATABLOCK(x) DATA_START + tDATABLOCK. %+ x

    ; Wipe data area with zeros
    push        cx
    push        di
    xor         al, al
    mov         cx, DATABLOCK(STACK) - DATA_START
    mov         di, DATA_START
    cld
ClearDataArea:
    stosb
    loop        ClearDataArea
    pop         di
    pop         cx

    ; Move stack and setup memory pointers
    mov         sp, DATABLOCK(STACK) + SIZEOF_STACK
    mov         ax, sp
    add         ax, 0x0002
    mov         [DATABLOCK(MEMSTART)], ax
    mov         [DATABLOCK(MEMPTR)], ax

MainParsing:

    CommandLineParser       ; insert code for command line parsing

    mov         al, [DATABLOCK(EXECUTE)]
    cmp         al, 0x00
    je          Done

    call        Index


    FindComspec DATABLOCK(COMSPEC)
    StdOutStr   DATABLOCK(COMSPEC)
    StdOutCRLF
    jmp         Done

    mov         cx, [DATABLOCK(CMDLEN)]
    cld
    mov         si, [DATABLOCK(CMDLN)]
Repeater:
    lodsb
    StdOutChar  al
    loop        Repeater
    jmp         Done

    multipush   bx, cx, es, ds, si, di
    push        cs
    pop         es
    mov         ax, [DATABLOCK(MEMTOP)]

    mov         cl, 4
    shr         ax, cl
    inc         ax
    mov         bx, ax
    mov         ax, 0x4a00
    int         0x21
    multipop    bx, cx, es, ds, si, di
    jnc         .Reduced
    StdOutStr   Memory_Error_Message
    Terminate   8
.Reduced:

    ; ShellExec   Program, Options

Done:
    mov     al, [DATABLOCK(EXITCODE)]
    Terminate al

    UseAdvancedStdIn

Out_of_Memory:
    StdOutStr   Out_of_Memory_Message
    Terminate   8

Index:
    xor         ah, ah
    mov         si, [DATABLOCK(MEMSTART)]
    mov         di, [DATABLOCK(MEMPTR)]
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
    cmp         di, SIZEOF_MEMORY
    jae         Out_of_Memory
    jmp         .Repeat
.Done:
    mov         [DATABLOCK(MEMTOP)], di
    mov         al, [DATABLOCK(SORTED)]
    cmp         al, 0x00
    jne         SortedIndex
    ret

; Super simple bubble sort
SortedIndex:
    mov         dx, 0
    mov         si, [DATABLOCK(MEMPTR)]
    mov         bx, [DATABLOCK(MEMTOP)]
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
    mov         al, [DATABLOCK(EXECUTE)]
    cmp         al, 0x0
    jne         SwitchError
    mov         bx, [DATABLOCK(MEMPTR)]
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
    mov         ah, [DATABLOCK(WATCHCRLF)]
    cmp         ah, 0
    jne         .CheckInput
    inc         ah
    mov         [DATABLOCK(WATCHCRLF)], ah
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
    mov         [DATABLOCK(WATCHCRLF)], ah
.IsNotNull:
    cmp         cl, 128
    jae         .Test
    mov         [bx], al
    inc         bx
    inc         cx
.Test:
    mov         ax, SIZEOF_MEMORY
    cmp         bx, ax
    jae         Out_of_Memory
	jmp         .CheckInput

.ReadFile:
    push        bx
    push        dx
    push        cx
    push        di
    mov         ah, 0x3f
    mov         bx, dx
    mov         cx, 0x0001  ; SIZEOF_BUFFER to accelerate
    mov         dx, DATABLOCK(BUFFER)
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
    mov         al, [DATABLOCK(BUFFER)]
    jmp         .Ready

.Done:
    mov         dx, [DATABLOCK(MEMPTR)]
    mov         ax, bx
    dec         ax
    cmp         ax, dx
    jna         .BackupPointer
    mov         [di], cl
    mov         al, [DATABLOCK(WATCHCRLF)]
    xor         ah, ah
    mov         [DATABLOCK(WATCHCRLF)], ah
    cmp         al, 0x00
    jne         .BackupPointer
    mov         [bx], ah
    inc         bx
    mov         ax, SIZEOF_MEMORY
    cmp         bx, ax
    jae         Out_of_Memory
    jmp         .SavePointer
.BackupPointer:
    cmp         bx, dx
    jna         .SavePointer
    dec         bx
.SavePointer:
    mov         [DATABLOCK(MEMPTR)], bx
    ret

SwitchL:
    call        Index
    cld
    mov         si, [DATABLOCK(MEMPTR)]
    mov         cx, [DATABLOCK(MEMTOP)]
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
    mov         bx, [DATABLOCK(MEMPTR)]
    mov         al, [DATABLOCK(EXECUTE)]
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
    mov         ah, [DATABLOCK(CONTINUE)]
    cmp         ah, 0x00
    je          .DieNow
    ret
.DieNow:
    StdOutStr   File_Read_Error_Message
    mov         [DATABLOCK(EXITCODE)], al
    Terminate   al

SwitchD:
    mov         bx, [DATABLOCK(MEMPTR)]
    mov         al, [DATABLOCK(EXECUTE)]
    cmp         al, 0x0
    jne         SwitchError
    mov         al, [si]
    push        ax
    xor         al, al
    mov         [si], al

    push        bx
    mov         ah, 0x1a            ;Set DTA
    mov         dx, DATABLOCK(DTA)
    int         0x21
    mov         cx, 0xffff          ;File Attribute
    mov         dx, di
    mov         ah, 0x4e            ;Find First File
    int         0x21
    pop         bx
    jc          .NoMatch

.AddItem:
    cld
    mov         si, DATABLOCK(DTA) + 0x1e
    mov         cx, 0x0c
    mov         dx, SIZEOF_MEMORY
    mov         ax, [si]
    cmp         ax, 0x2e2e
    je          .SkipItem
    cmp         ax, 0x002e
    je          .SkipItem
    mov         al, [DATABLOCK(ALLFILES)]
    cmp         al, 0x01
    je          .Repeat
    mov         al, [DATABLOCK(DTA) + 0x15]
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
    mov         [DATABLOCK(MEMPTR)], bx
    ret

SwitchC:
    mov         al, [DATABLOCK(EXECUTE)]
    cmp         al, 0x0
    jne         SwitchError
    inc         al
    mov         [DATABLOCK(CONTINUE)], al
    ret

SwitchS:
    mov         al, [DATABLOCK(EXECUTE)]
    cmp         al, 0x0
    jne         SwitchError
    inc         al
    mov         [DATABLOCK(SORTED)], al
    ret

SwitchX:
    mov         al, [DATABLOCK(EXECUTE)]
    cmp         al, 0x0
    jne         SwitchError
    inc         al
    mov         [DATABLOCK(EXECUTE)], al
    ret

SwitchA:
    mov         al, [DATABLOCK(EXECUTE)]
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
    mov         [DATABLOCK(ALLFILES)], al
    ret

NoSwitch:
    mov         al, [DATABLOCK(EXECUTE)]
    cmp         al, 0x01
    jne         SwitchError
    inc         al
    mov         [DATABLOCK(EXECUTE)], al
    mov         [DATABLOCK(CMDLN)], di
    mov         [DATABLOCK(CMDLEN)], cx
    ret

SwitchW:
    xor         ah, ah
    mov         [si], ah
    FindExec    di, DATABLOCK(TEMPNAME)
    StdOutStr   DATABLOCK(TEMPNAME)
    StdOutCRLF
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
    SwitchData  'W', 1, SwitchW ; Temp Switch for testing FindExec
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

DATA_START:

