
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

%idefine erNotValid 0x0f
%idefine erNotFormatted 0x05
%idefine erIsNetwork 0x04
%idefine erIsCDROM 0x03
%idefine erIsRemovable 0x02
%idefine erNone 0x00

%imacro FindFirst 2
    push    dx
    push    cx
    mov     ah, 1Ah         ;Set DTA
    lea     dx, %1
    int     21h
    ; xor     cx, cx          ;No attributes.
    mov     cx, 0ffffh
    lea     dx, %2
    mov     ah, 4Eh         ;Find First File
    int     21h
    pop     cx
    pop     dx
%endmacro

%imacro FindNext 0
    push    ax
    mov     ah, 4Fh         ;Find Next File
    int     21h
    pop     ax
%endmacro

%imacro IsValidDrive 1      ; Test is removable, fails if not valid
        mov         ax, 0x4408
        mov         bl, %1
        int         0x21
        jc          %%Error
        xor         ax, ax
        jmp         %%Done
    %%Error:
        mov         al, erNotValid  ; Invalid Drive Number
        mov         [ExitCode], al
    %%Done:
%endmacro

%imacro DiskFree 1          ; Get Disk free space, fails if not formatted
        mov     ah, 0x36
        mov     dl, %1
        int     0x21
        cmp     ax, 0xffff
        je      %%Error
        clc
        jmp     %%Done
    %%Error:
        stc
    %%Done:
%endmacro

%imacro IsFormatted 1
        GetIntVec   0x24, SavedInt24
        push    ds
        cli
        mov     dx, MyInt24
        mov     ax, 0x2524
        int     0x21
        sti
        pop     ds

        xor     al, al
        mov     [ErrorCode], al

        mov     al, %1
        add     al, 0x40
        mov     [%%FileName], al

        FindFirst [%%DTA], [%%FileName]
        jc          %%Error
    %%NoError:
        xor     ax, ax
        jmp     %%Done

    %%FileName:
        DB '?:\*.*',0

    %%DTA:
        times 23 DD 0

    %%Error:
        mov         al, 1
        mov         [ExitCode], al
        mov         ax, erNotFormatted

    %%Done:
        push        ax
        SetIntVec   0x24, SavedInt24
        pop         ax

%endmacro

%imacro GetIntVec 2
    push    es
    mov     al, %1
    mov     ah, 0x35
    int     0x21
    mov     [%2], bx
    mov     bx, es
    mov     [%2 + 2], bx
    pop     es
%endmacro

%imacro SetIntVec 2
    cli
    push    ds
    mov     dx, [cs:%2+2]
    mov     ds, dx
    mov     dx, [cs:%2]
    mov     al, %1
    mov     ah, 0x25
    int     0x21
    pop     ds
    sti
%endmacro

%imacro Floppies 0 ; BIOS Function
        int     0x11
        test    al, 0x01
        jz      %%NoFloppies
        xor     ah, ah
        and     al, 0xc0
        mov     cl, 0x06
        shr     ax, cl
        inc     ax
        jmp     %%Done
    %%NoFloppies:
        xor     ax, ax
    %%Done:
%endmacro

MyInt24:
    push    ax
    mov     ax, di
    mov     [cs:ErrorCode], al
    pop     ax
    mov     al, 0x03
    iret

ErrorCode:
    dw 0

%imacro IsCDROM 1
    mov     ax, 0x1500
    xor     bx, bx
    int     0x2f
    cmp     bx, 0
    je      %%NotCDRom
    xor     ah, ah
    mov     al, %1
    inc     cx
    dec     bx
    cmp     ax, cx
    jl      %%NotCDRom ; less then first cd
    add     cx, bx
    cmp     ax, cx
    jg      %%NotCDRom ; greater then last cd
    mov     al, 0x01
    jmp     %%Done
%%NotInstalled:
%%NotCDRom:
    xor  ax, ax
%%Done:
%endmacro

%imacro IsNetwork 1
    mov     ax, 0x4409
    mov     bl, %1
    int     0x21
    jc      %%Not
    and     dx, 1000000000000b
    cmp     dx, 0
    je      %%Not
    mov     ax, 1
    jmp     %%Done
%%Not:
    xor     ax, ax
%%Done:
%endmacro

%imacro IsRemovable 1
    mov     ax, 0x4408
    mov     bl, %1
    int     0x21
    jc      %%Not
    cmp     ax, 0
    jne      %%Not
    mov     ax, 1
    jmp     %%Done
%%Not:
    xor     ax, ax
%%Done:
%endmacro

%imacro DiskStatus 1
    mov     al, %1
    xor     ah, ah
    mov     [%%Result], ah
    cmp     ax, 0x5e
    jl      %%NotLowercase
    sub     ax, 0x20
%%NotLowercase:
    cmp     ax, 0x41
    jl      InvalidOption
    cmp     ax, 0x5a
    jg      InvalidOption
    sub     ax, 0x40
    mov     [Drive], al

    cmp     al, 3
    jnl     %%NotFloppy

    Floppies
    mov     bl, al
    mov     al, [Drive]
    cmp     al, bl
    jg      %%BadDriveLetter
%%NotFloppy:

    ; CD-ROM Fails Valid Test, Only works with MSCDEX driver.
    IsCDROM     [Drive]
    cmp         al, 0x01
    je          %%IsCDROM

    IsValidDrive [Drive]
    ; ax = 0, At least it is exists and partitioned
    cmp     ax, 0
    je      %%DriveExists
    ; Drive not found, so se if a hard drive actually exists

%%BadDriveLetter:
    mov         al, erNotValid
    mov         [%%Result], al
    jmp         %%Done
%%DriveExists:
    IsFormatted [Drive]
    cmp         ax, 0
    jne         %%FormatError
    ; Fails if it is partitioned but is not formatted
    ; Check Drive Type
    IsNetwork   [Drive]
    cmp         al, 0x01
    je          %%IsRemote
    IsRemovable [Drive]
    cmp         al, 0x01
    je          %%IsRemovable

    xor         al, al
    mov         [%%Result], al
    jmp         %%Done
%%IsCDROM:
    mov         al, erIsCDROM
    mov         [%%Result], al
    jmp         %%Done
%%IsRemovable:
    mov         al, erIsRemovable
    mov         [%%Result], al
    jmp         %%Done
%%IsRemote:
    mov         al, erIsNetwork
    mov         [%%Result], al
    jmp         %%Done
%%FormatError:
    mov         al, erNotFormatted
    mov         [%%Result], al
    jmp         %%Done
%%Result:
    db          0
%%Done:
    mov         al, [%%Result]
%endmacro

%imacro DiskStatusMessage 1
    mov         al, %1
    mov         bx, %%Messages
%%ScanLoop:
    mov         ah, [bx]
    inc         bx
    cmp         al, ah
    je          %%Found
    cmp         ah, 0
    je          %%NotFound
%%ScanNext:
    mov         ah, [bx]
    inc         bx
    cmp         ah, 0
    jne         %%ScanNext
    jmp         %%ScanLoop

%%Found:
    WriteStr    bx
%%NotFound:
    WriteStr    %%MsgCRLF
    jmp         %%Done
%%MsgCRLF:
    db CRLF,0
%%Messages:
    db erNotValid,'Invalid drive letter',0
    db erNotFormatted,'Drive not formatted',0
    db erIsCDROM,'Drive is CD/DVD-ROM',0
    db erIsNetwork,'Drive is remote',0
    db erIsRemovable,'Drive is removable',0
    db erNone,'Drive is ready',0
%%Done:

%endmacro

