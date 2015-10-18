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

%idefine NoVideoOutput

%include "COMMON.INC"

LoadCmdLnPtr:
    push    ds
    pop     ax
    mov     [ParamBlock + 4], ax

SetFileNamePtr:
    cld
.Looping:
    lodsb
    cmp     al, 0x0d
    je      BadParams
    cmp     al, 0x20
    je      .DoneYet
    mov     ax, [FileNamePtr]
    cmp     ax, 0
    jne     .Looping
    dec     si
    mov     [FileNamePtr], si
    ; inc si not needed, it won't get here twice
    jmp     .Looping
.DoneYet:
    mov     ax, [FileNamePtr]
    cmp     ax, 0
    je      .Looping
    dec     si
    xor     al, al
    mov     [si], al

    inc     si
    mov     ax, ExecLine
    mov     di, ax

AddExpandedFilename:
    mov     bx, di
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
.DriveAdded:
;    cmp     al, 0
;    je      .NoPath
    mov     al, [si]
    cmp     al, 0x5c        ; '\'
    je      .CopyData
.NoPath:
    mov     al, 0x5c
    stosb
    mov     dl, [bx]
    sub     dl, 0x40
    push    si
    mov     si, di
    mov     ah, 0x47
    int     0x21
    cld
    pop     si
.FindEnd:
    mov     al, [di]
    cmp     al, 0x00
    je      .FoundEnd
    inc     di
    jmp     .FindEnd
.FoundEnd:
    mov     al, 0x5c
    stosb
.CopyData:
.CopyLoop:
    lodsb
    cmp     al, 0x00
    je      .Done
    cmp     al, 0x0d
    je      .Done
    cmp     al, 0x20
    je      .Done
    cmp     al, 0x61
    jl      .NotLower
    cmp     al, 0x7a
    jg      .NotLower
    sub     al, 0x20
.NotLower:
    stosb
    jmp    .CopyLoop
.Done:
    cmp     al, 0x0d
    je      .NoParams
    mov     al, 0x20
    stosb

.CopyParams:
    lodsb
    cmp     al, 0x0d
    stosb
    jne     .CopyParams
.NoParams:

    StdOutStr ExecLine

    Terminate 0

BadParams:
    StdOutStr CommandLineErrorMsg
    Terminate 100

FileNamePtr:
    dw 0

ParamBlock:
    .EnvSeg:    dw 0
    .CmdLnPtr:  dw ExecLine,0
    .FCBS:      dw 0,0
ExecLine:       times 127 db 0x0d
    db 0