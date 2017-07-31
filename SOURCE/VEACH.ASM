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
%idefine CommandLineParseAbort
%idefine NoWhereIs

%idefine SIZEOF_STACK   0x0100  ; Required Stack bytes, don't need this much.
%idefine SIZEOF_MEMORY  0x4000  ; Maximum bytes of memory program can use.
%idefine SIZEOF_BUFFER  2       ; Size of StdIn/File buffer. Should increase
                                ; this and do some buffer caching reads to
                                ; increase performance.

%include "COMMON.INC"

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
    .MEMCOUNT   resw 1  ; Count of items in list

    SHELLEXECBLOCK

    .CMDLEN     resw 1  ; Length of Command Line
    .CMDLN      resw 1  ; ASCIIZ Command Line

    .BUFFER     resb SIZEOF_BUFFER ; Standard Input Buffer

    .DTA        resb 128 ; Directory searching buffer
    .COMSPEC    resb 128 ; Stored COMSPEC or location of COMMAND.COM
    .SEARCHNAME resb 128 ; Temporary Fully qualified Search Filename
    .SEARCHPATH resb 128 ; Path to search for executables.
    .RELNAME    resb 128 ; Reformatted name for relative path search only
    .EXECBUF    resb 256 ; Execution Data Expansion String
    .CMDBUF     resb 128 ; Executed command buffer

    %ifndef NoWhereIS
    .WHERENAME  resb 128 ; Remove when W switch is removed
    %endif

    .ZERO       resb 0   ; Unused at present

    .STACK      resb SIZEOF_STACK

    .HEAP       resb 0

endstruc

%idefine DATABLOCK(x) DATA_START + tDATABLOCK. %+ x

%include "FIND.INC"
%include 'EXEC.INC'

%imacro CriticalError 1
    mov         si, %1
    jmp         CriticalDeath
%endmacro

    PrepareMemory

MainParsing:

    CommandLineParser       ; insert code for command line parsing

    mov         al, [DATABLOCK(EXECUTE)]
    cmp         al, 0x00
    je          Done

    call        Index

    ShrinkMemory  [DATABLOCK(MEMTOP)]
    jnc         .Reduced
    CriticalError ERR_General_Memory
.Reduced:

    FindComspec DATABLOCK(COMSPEC)

; Run through list
    cld
    mov         si, [DATABLOCK(MEMPTR)]
    mov         di, DATABLOCK(EXECBUF)
    mov         dx, [DATABLOCK(MEMTOP)]
    xor         bx, bx
.RunLoop:
    inc         bx
    cmp         si, dx
    jae         .RunDone
    lodsw
    inc         ax          ; ignore size of string
    mov         cx, ax
    multipush   si, di
    mov         si, [DATABLOCK(CMDLN)]
.CloneOptions:
    lodsb
    cmp         al, '*'
    je          .AddItem
    cmp         al, '@'
    je          .AddIndex
    cmp         al, '#'
    je          .AddCount
    stosb
    cmp         al, 0
    jne         .CloneOptions
    jmp         .CloneDone
.AddItem:
    push        si
    mov         si, cx
.AddItemLoop:
    lodsb
    cmp         al, 0
    je          .AddItemDone
    stosb
    jmp         .AddItemLoop
.AddItemDone:
    pop         si
    jmp         .CloneOptions
.AddIndex:
    mov         ax, bx
    jmp         .AddNumber
.AddCount:
    mov         ax, [DATABLOCK(MEMCOUNT)]
.AddNumber:
    multipush   ax, bx, cx, dx
    mov         bx, 0x000A
    mov         cx, 0x0001
.AddNumberLoop:
    cmp         ax, bx
    jge         .AddNumberTooBig
    push        ax
.AddNumberOK:
    pop         ax
    add         ax, 0x0030
    stosb
    loop       .AddNumberOK
    jmp        .AddNumberDone
.AddNumberTooBig:
    inc         cx
    xor         dx, dx
    div         bx
    push        dx
    jmp         .AddNumberLoop
.AddNumberDone:
    multipop    ax, bx, cx, dx
    jmp         .CloneOptions
.CloneDone:
    multipop    si, di

    pushall
    mov         si, DATABLOCK(EXECBUF)
.SearchFirst:
    lodsb
    cmp         al, 0x0d
    je          .FoundFirst
    cmp         al, 0x00
    je          .FoundFirst
    cmp         al, 0x20
    je          .FoundFirst
    jmp         .SearchFirst
.FoundFirst:
    dec         si
    xor         ah, ah
    mov         [si], ah
    push        ax
    FindExec    di, DATABLOCK(CMDBUF)
    xor         cx, cx
    pop         ax
    mov         [si], al

.SearchChar:
    lodsb
    cmp         al, 0x0d
    je          .SearchChar
    cmp         al, 0x0
    je          .DoCat
    cmp         al, 0x20
    jne         .DoSpaceCat
    jmp         .SearchChar
.DoSpaceCat:
    dec         si
    mov         dx, 0x01
.DoCat:
    dec         si

    mov         al, [DATABLOCK(CMDBUF)]
    cmp         al, 0
    je          .NotExec

    mov         bx, si
    StrCat      DATABLOCK(CMDBUF), si
    mov         si, ax

    cmp         si, DATABLOCK(EXECBUF) + 4
    jna         .NotExec

    mov         ax, [si - 4]
    cmp         ax, '.B'
    jne         .NotBatch
    mov         ax, [si - 2]
    cmp         ax, 'AT'
    jne         .NotBatch
;    DebugChar   '%'
    mov         ax, '/C'
    mov         bx, 0x0020
    mov         [DATABLOCK(EXECBUF)], ax
    mov         [DATABLOCK(EXECBUF) + 2 ], bx
    StrCat      DATABLOCK(EXECBUF), DATABLOCK(CMDBUF)

    mov         di, DATABLOCK(EXECBUF)
    mov         si, DATABLOCK(COMSPEC)
    jmp         .Execute
.NotBatch:
    mov         ax, [si - 4]
    cmp         ax, '.C'
    jne         .NotCOM
    mov         ax, [si - 2]
    cmp         ax, 'OM'
    jne         .NotCOM
    jmp         .BinaryExec
.NotCOM:
    mov         ax, [si - 4]
    cmp         ax, '.E'
    jne         .NotExec
    mov         ax, [si - 2]
    cmp         ax, 'XE'
    jne         .NotExec
.BinaryExec:
    xor         al, al
    mov         ah, [si]
    mov         [si], al
    cmp         ah, 0
    je          .NullParams
    inc         si
.NullParams:
    mov         di, si
    mov         si, DATABLOCK(CMDBUF)
.Execute:
;    push        di
;    StdOutChar  '!'
;    StdOutStr   si
;    StdOutCRLF
;    StdOutChar  '+'
;    pop         di
;    push        di
;    StdOutStr   di
;    StdOutCRLF
;    pop         di
;    xor         ax, ax

    call        RunProgram
    cmp         ax, 0
    je          .NoExecError
    mov         [cs:DATABLOCK(EXITCODE)], al
.NoExecError:
    popall
    mov         al, [DATABLOCK(EXITCODE)]
    cmp         al, 0
    jne         .ExecError
    jmp         .RunLoop
.ExecError:
    mov         ah, [DATABLOCK(CONTINUE)]
    cmp         ah, 1
    je          .RunLoop
    CriticalError ERR_Child
.NotExec:
    popall
    mov         al, [DATABLOCK(CONTINUE)]
    cmp         al, 0
    jne         .RunLoop
    CriticalError ERR_Invalid_Format
.RunDone:
    jmp         Done

RunProgram:
    ShellExec   si, di ; Program, Options
    ret

ShowError:
    cld
    mov         ah, al
    lodsb
    cmp         al, 0
    jne         .ErrorOverride
    mov         al, ah
.ErrorOverride:
    cmp         al, 0
    jne         .SetError
    mov         al, 1
.SetError:
    mov         [DATABLOCK(EXITCODE)], al
    xor         ah, ah
    push        ax
    StdOutStr   ERR_Message
    inc         di
    pop         ax
    StdOutIntWord ax
    StdOutStr   di
    inc         di
    push        di
    StdOutStr   si
    pop         di
    StdOutStr   di
    ret

CriticalDeath:
    call    ShowError

Done:
    mov     al, [DATABLOCK(EXITCODE)]
    Terminate al

Out_of_Memory:
    CriticalError ERR_Out_Of_Memory

    UseAdvancedStdIn


Index:
    push        cx
    xor         cx, cx
    xor         ah, ah
    mov         si, [DATABLOCK(MEMSTART)]
    mov         di, [DATABLOCK(MEMPTR)]
    mov         bx, di
    dec         bx
.Repeat:
    cmp         si, bx
    jae         .Done
    inc         cx
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
    mov         [DATABLOCK(MEMCOUNT)], cx
    pop         cx
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
    CriticalError  ERR_File_Read

SwitchD:
    mov         bx, [DATABLOCK(MEMPTR)]
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
    mov         al, 0x01
    mov         [DATABLOCK(CONTINUE)], al
    ret

SwitchS:
    mov         al, 0x01
    mov         [DATABLOCK(SORTED)], al
    ret

SwitchX:
    mov         al, 0x01
    mov         [DATABLOCK(EXECUTE)], al
    mov         [CommandLineParseAbortFlag], al
    inc         di
    xor         cx, cx
.Strip:
    mov         al, [di]
    cmp         al, 0x20
    jne         .Measure
    inc         di
    jmp         .Strip
.Measure:
    mov         [DATABLOCK(CMDLN)], di
.MeasureLoop:
    mov         al, [di]
    inc         di
    cmp         al, 0x00
    je          .Measured
    cmp         al, 0x0d
    je          .Measured
    inc         cx
    jmp         .MeasureLoop
.Measured:
    cmp         cx, 0x000
    jne         .HasOptions
    mov         di, DefaultExecuteOptions
    jmp         .Measure
.HasOptions:
    mov         [DATABLOCK(CMDLEN)], cx
    ret

SwitchA:
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
    jmp         SwitchError
    ret

%ifndef NoWhereIs
SwitchW:
    xor         ah, ah
    mov         [si], ah
    FindExec    di, DATABLOCK(TEMPNAME)
    StdOutStr   DATABLOCK(TEMPNAME)
    StdOutCRLF
    ret
%endif

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'I', 0, SwitchI ; List From StdIn
    SwitchData  'F', 1, SwitchF ; List From File
    SwitchData  'A', 1, SwitchA ; All Files and Directories on/off
    SwitchData  'D', 1, SwitchD ; Directory Search
    SwitchData  'L', 0, SwitchL ; Display List
    SwitchData  'X', 0, SwitchX ; Execute
    SwitchData  'C', 0, SwitchC ; Continue despite any exec errorlevels
    SwitchData  'S', 0, SwitchS ; Sort List
%ifndef NoWhereIs
    SwitchData  'W', 1, SwitchW ; Temp Switch for testing FindExec
%endif
    HelpSwitchData
    SwitchData  0,  0, 0

DefaultExecuteOptions:
    db  "*",0

ERR_Message:
    db  "ERROR #",0,", ",0," error",CRLF,0

ERR_General_Memory:
    db 9,"Memory allocation",0

ERR_Out_Of_Memory:
    db 8,"Out of memory",0

ERR_File_Not_Found:
    db 2,"File not",0

ERR_File_Read:
    db 0,"File read",0

ERR_Child:
    db 0,"Subprocess",0

ERR_Invalid_Format:
    db 11,"Invalid file format",0

DATA_START:

