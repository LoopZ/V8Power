; Copyright (C) 2016 Jerome Shidel
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

    push        si
    push        ds
    SearchEnv   PathStr
    pop         ds
    jnc         NoPathFound
    mov         [PathData], si
NoPathFound:
    pop         si

    CommandLineParser       ; insert code for command line parsing

    Terminate 0

%include "DSKTLS.INC"

ExpandFileName:
    push    si
    push    di
    ZeroMemory Buffer, BufferEnd - Buffer
    xchg    si, di
    mov     di, Buffer
    mov     al, [si+1]
    cmp     al, 0x3a
    je      .HasDriveLetter
    mov     ah, 0x19
    int     0x21
    add     al, 0x41
    stosb
    mov     al, 0x3a
    stosb
    jmp     .DriveAdded
.HasDriveLetter:
    lodsb
    cmp     al, 0x60
    jle     .NotLower1
    cmp     al, 0x7a
    jg      .NotLower1
    sub     al, 0x20
.NotLower1:
    stosb
    lodsb
    cmp     al, 0x60
    jle     .NotLower2
    cmp     al, 0x7a
    jg      .NotLower2
    sub     al, 0x20
.NotLower2:
    stosb
    sub     cx, 2
.DriveAdded:
    cmp     cx, 0
    je      .NoPath
    mov     al, [si]
    cmp     al, 0x5c        ; '\'
    je      .CopyData
.NoPath:
    mov     al, 0x5c
    stosb
    mov     dl, [Buffer]
    sub     dl, 0x40
    push    si
    push    cx
    mov     si, di
    mov     ah, 0x47
    int     0x21
    cld
    pop     cx
    pop     si
.FindEnd:
    mov     al, [di]
    cmp     al, 0x00
    je      .FoundEnd
    inc     di
    jmp     .FindEnd
.FoundEnd:
    mov     al, [di-1]
    cmp     al, 0x5c
    je      .EndSlash
    mov     al, 0x5c
    stosb
.EndSlash:
    cmp     cx, 0
    je      .Done
.CopyData:
    lodsb
    mov     ah, [si]
    cmp     al, ah
    jne     .UseChar
    cmp     al, 0x5c
    je      .SkipChar
.UseChar:
    cmp     al, 0x61
    jl      .NotLower
    cmp     al, 0x7a
    jg      .NotLower
    sub     al, 0x20
.NotLower:
    stosb
.SkipChar:
    loop    .CopyData
.Done:
    pop     di
    pop     si
    ret

DoPrint:
    StdOutStr Buffer
DoPrint2:
    StdOutCRLF
    xor     al, al
    mov     [ChangeFlag], al
    ret

SwitchC:
    mov     al, 1
    mov     [ChangeFlag], al
    ret

SwitchX:
    mov     al, 1
    mov     [ExitFlag], al
    ret

SwitchD:
    call    ExpandFileName
    xor     al, al
    mov     [Buffer+2], al
    mov     al, [Buffer]
    mov     ah, [ExitFlag]
    cmp     ah, 1
    je      DoExitCode
    mov     ah, [ChangeFlag]
    cmp     ah, 1
    jne     DoPrint
    sub     al, 0x41
    mov     ah, 0x0e
    mov     dl, al
    int     0x21
    ret

SwitchP:
    call    ExpandFileName
    mov     ax, BufferEnd
    mov     di, ax
.Search:
    dec     di
    mov     al, [di]
    cmp     al, 0x5c
    jne     .Search
    cmp     di, Buffer + 2
    jg      .NotFirst
    inc     di
.NotFirst:
    xor     al, al
    mov     [di], al
    mov     al, [Buffer]
    mov     ah, [ExitFlag]
    cmp     ah, 1
    je      DoExitCode
    mov     ah, [ChangeFlag]
    cmp     ah, 1
    jne     DoPrint
    sub     al, 0x41
    mov     ah, 0x0e
    mov     dl, al
    int     0x21
    mov     dx, Buffer
    mov     ah, 0x3b
    int     0x21
    ret

DoExitCode:
    mov         al, [Buffer]
    xor         ah, ah
    cmp         al, 0x41
    jb          .InvalidDrive
    cmp         al, 0x5a
    ja          .InvalidDrive
    sub         ax, 0x0040
    jmp         ProgramTerminate
.InvalidDrive:
    mov         al, ah
    jmp         ProgramTerminate


SwitchF:
    call    ExpandFileName
    jmp     DoPrint

SwitchN:
    call    ExpandFileName
    mov     ax, BufferEnd
    mov     di, ax
    mov     ah, 1
.Search1:
    dec     di
    mov     al, [di]
    cmp     ah, 1
    jne     .Search2
    cmp     al, 0x2e        ; '.'
    jne     .Search2
    xor     ax, ax
    mov     [di], al
    jmp     .Search1
.Search2:
    cmp     al, 0x5c        ; '\'
    jne     .Search1
    inc     di
    StdOutStr di
    jmp     DoPrint2

SwitchE:
    call    ExpandFileName
    mov     ax, BufferEnd
    mov     di, ax
    mov     ah, 1
.Search1:
    dec     di
    mov     al, [di]
    cmp     ah, 1
    jne     .Search2
    cmp     al, 0x2e        ; '.'
    jne     .Search2
    inc     di
    StdOutStr di
    jmp     DoPrint2
.Search2:
    cmp     al, 0x5c        ; '\'
    jne     .Search1
    jmp     DoPrint2

SwitchU:
    GetIntVec   0x24, SavedInt24
    push    ds
    cli
    mov     dx, MyInt24
    mov     ax, 0x2524
    int     0x21
    sti
    pop     ds
    call    ExpandFileName
    mov     al, [Unique]
    cmp     al, 0x00
    jne     .SwitchFailed
    xor     cx, cx
.Searching:
    push    cx              ; warning if leave func before .CWasPopped you must
                            ; pop it!
    CopyMemory Buffer, Unique, UniqueEnd - Unique
    mov     si, UniqueEnd
    std
.NextQuest:
    lodsb
    cmp     si, Unique
    je      .DoneFill
    cmp     al, 0x3f    ; '?'
    jne      .NextQuest
    xor     dx, dx
    mov     ax, 0x000a
    xchg    ax, cx
    div     cx
    xchg    cx, ax
    add     dx, 0x0030
    mov     [si+1], dl
    jmp     .NextQuest
.DoneFill:
    cmp     cx, 0
    jne     .NumbOverflow
    pop     cx
.CWasPopped:

    push    dx
    push    cx
    mov     ah, 1Ah          ;Set DTA
    mov     dx, DTA
    int     0x21
    mov     cx, 0xffff
    mov     dx, Unique
    mov     ah, 0x4E         ;Find First File
    int     0x21
    pop     cx
    pop     dx
    jnc      .Exists          ; File was found
    cmp     ax, 0x0012        ; No Matching files
    je      .NotFound
    jmp     .OutOfNumbs
.Exists:
    inc     cx
    cmp     cx, 0x0000
    je      .OutOfNumbs
    jmp     .Searching
.NotFound:
    StdOutStr Unique
    StdOutCRLF
    SetIntVec 0x24, SavedInt24
    jmp    DoPrint2
.NumbOverflow:
    pop     cx
.OutOfNumbs:
    StdOutCRLF
    SetIntVec 0x24, SavedInt24
    Terminate 101

.SwitchFailed:
    SetIntVec 0x24, SavedInt24
    jmp       InvalidOption

PathIsSet:
    push    ax
    mov     ax, [PathData]
    cmp     ax, 0
    pop     ax
    je      .NoPathVar
    ret
.NoPathVar:
;    mov     al, [Quite]
;    cmp     al, 1
;    je      .NoMessage
    StdOutStr MsgNoPath
.NoMessage:
    Terminate 1

%ifdef PathPrint
; Display PATH Variable
SwitchW:
    call    PathIsSet
    pushf
    push    ds
    push    si
    push    dx
    mov     dx, [PSP_ENV]
    push    dx
    mov     si, [PathData]
    pop     ds
    cld
.Printing:
    lodsb
    cmp     al, ';'
    je      .Return
    cmp     al, 0x00
    je      .Return
    StdOutChar al
    jmp     .Printing
.Return:
    push    ax
    StdOutCRLF
    pop     ax
    cmp     al, 0x00
    jne      .Printing
    pop     dx
    pop     si
    pop     ds
    popf
    ret
%endif

SwitchS:
    xor     al, al
    mov     [TestFlag], al
    jmp     Searching
SwitchT:
    mov     al, 1
    mov     [TestFlag], al
Searching:
    xor     al, al
    mov     [FoundFlag], al
    call    PathIsSet
    push    ds
    mov     ax, si
    mov     dx, [PSP_ENV]
    push    si
    mov     si, [PathData]
    push    dx
    pop     ds
    mov     dx, ax
    cld
.CopyEnvPath:
    mov     bx, Buffer
.CopyRepeat:
    lodsb
    cmp     al, ';'
    je      .AddItem
    cmp     al, 0x00
    je      .AddItem
    mov     [cs:bx], al
    inc     bx
    jmp     .CopyRepeat
.AddItem:
    mov     cl, [cs:bx - 1]
    mov     ah, '\'
    cmp     cl, ah
    je      .NoSlash
    mov     [cs:bx], ah
    inc     bx
.NoSlash:
    push    bx
    push    di
.AddLoop:
    cmp     di, dx
    je      .AddDone
    mov     ah, [cs:di]
    cmp     ah, 0x61
    jb      .NotLower
    cmp     ah, 0x7a
    ja      .NotLower
    sub     ah, 0x20
.NotLower:
    mov     [cs:bx], ah
    inc     di
    inc     bx
    jmp     .AddLoop
.AddDone:
    pop     di
    xor     ah, ah
    mov     [cs:bx], ah
    pop     bx
    push    ds
    push    cs
    pop     ds
    pushall
    mov     ah, 1Ah          ;Set DTA
    mov     dx, DTA
    int     0x21
    mov     cx, 0xffff
    mov     dx, Buffer
    mov     ah, 0x4E         ;Find First File
    int     0x21
    jc      .NoMatch
    xor     ah, ah
    mov     [bx], ah
    inc     ah
    mov     [FoundFlag], ah
    mov     ah, [TestFlag]
    cmp     ah, 0
    jne     .NoMatch
.Display:
    push    dx
    StdOutStr Buffer
    StdOutStr DTA + 0x1e
    StdOutCRLF
    pop     dx
    mov     ah, 0x4f         ;Find next
    int     0x21
    jnc      .Display
.NoMatch:
    popall
    pop     ds
    cmp     al, 0x00
    jne      .CopyEnvPath
    pop     si
    pop     ds
    mov     ah, [FoundFlag]
    cmp     ah, 0
    je      .NotFound
    ret
.NotFound:
    Terminate 1

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          InvalidOption
    jmp         ax

InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    HelpSwitchData
    SwitchData 'C', 0, SwitchC
    SwitchData 'F', 1, SwitchF
    SwitchData 'D', 1, SwitchD
    SwitchData 'X', 0, SwitchX
    SwitchData 'P', 1, SwitchP
    SwitchData 'N', 1, SwitchN
    SwitchData 'E', 1, SwitchE
    SwitchData 'U', 1, SwitchU
    SwitchData 'S', 1, SwitchS
    SwitchData 'T', 1, SwitchT
%ifdef PathPrint
    SwitchData 'W', 0, SwitchW
%endif
    SwitchData  0,  0, 0

OptionsTable:
    TableEnd

Buffer:
    times 128 db 0
BufferEnd:
Unique:
    times 128 db 0  ; extra padding to prevent overflow if bad data is
                    ; entered from command line.
UniqueEnd:
DTA:
    times 128 db 0
DTAEnd:
ChangeFlag:
    db 0
FoundFlag:
    db 0
TestFlag:
    db 0
ExitFlag:
    db 0
SavedInt24:
    dw 0, 0
PathData:
    dw 0
PathStr:
    db "PATH",0
MsgNoPath:
    db "Environment PATH not set",CRLF,0
