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

; set up command line pointer in ParamBlock for later.
LoadCmdLnPtr:
    push    ds
    pop     ax
    mov     [ParamBlock + 4], ax


; Setup pointer to translation file in original command line and append a
; nul character to it's end.
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

; Check if contains a '\', if so don't search current dir and pathspec.
HasDirSlash:
    push    si
.CheckNext:
    lodsb
    cmp     al, 0x00
    je      .NotFound
    cmp     al, 0x20
    je      .NotFound
    cmp     al, 0x0d
    je      .NotFound
    cmp     al, 0x5c
    je      .Found
    jmp     .CheckNext
.Found:
    jmp     .Finished
.NotFound:
.Finished:
    pop     si

; Add expanded filename of command to execute after translation.
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
    mov     al, [si]
    cmp     al, 0x5c
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

; Just copy rest of command line text to buffer
.CopyParams:
    lodsb
    cmp     al, 0x0d
    stosb
    jne     .CopyParams
.NoParams:

; open translation file
    mov     dx, [FileNamePtr]
    mov     ax, 0x3d00
    int     0x21
    jc      ReadError   ; file missing or something
    mov     [FileHandle], ax

ReadLoop:
    ZeroMemory ReadBuffer, ReadBufferEnd - ReadBuffer
    mov     ah, 0x3f
    mov     bx, [FileHandle]
    mov     cx, ReadBufferEnd - ReadBuffer
    mov     dx, ReadBuffer
    int     0x21
    jc      ReadError
    ; ax is bytes read
    StdOutStr ReadBuffer

; temporary development displayed output.
    StdOutStr ExecLine
; Close the file
    call    CloseFile

    Terminate 0

ReadError:
    ; Nothing at present
BadParams:
    call      CloseFile
    StdOutStr CommandLineErrorMsg
    Terminate 100

CloseFile:
    mov     bx, [FileHandle]
    cmp     bx, 0
    je      .NotOpen
    mov     ax, 0x3e
    int     0x21
.NotOpen:
    ret

FileNamePtr:
    dw 0
FileHandle:
    dw 0

ParamBlock:
    .EnvSeg:    dw 0
    .CmdLnPtr:  dw ExecLine,0
    .FCBS:      dw 0,0
ExecLine:       times 127 db 0x0d
    db 0

ReadBuffer:
    times 128 db 0
ReadBufferEnd:
    db 0