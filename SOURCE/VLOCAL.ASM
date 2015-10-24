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
    je      BadParams
    mov     al, 0x20
    stosb

; open translation file
    mov     dx, [FileNamePtr]
    mov     ax, 0x3d00
    int     0x21
    jc      ReadError   ; file missing or something
    mov     [FileHandle], ax

    ; save output position
    mov     [OutPosition], di
    mov     [ParmPosition], si

; starting searching for string
    ; started new line
    mov     ah, 0x01
    xor     cx, cx

SearchForString:
    mov     di, ReadBuffer
.KeepSearching:
    cmp     cx, 0
    jne     .NotEmpty
    call    ReadMoreData
    jc      ReadError
    cmp     cx, 0
    je      MatchNotFound
.NotEmpty:
    mov     al, [di]
    mov     bl, [si]
    inc     di
    inc     si
    dec     cx
    cmp     al, 0x0d
    je      .NewLine
    cmp     al, 0x0a
    je      .NewLine
    cmp     ah, 0x00
    je      .KeepSearching
    inc     ah
    cmp     al, bl
    je      .KeepSearching
    cmp     bl, 0x20
    je      .TestEqual
    cmp     bl, 0x0d
    jne     .MissMatch
.TestEqual:
    cmp     al, 0x3d  ; '='
    jne     .MissMatch
    mov     [ParmPosition], si
    jmp     ReadString
.MissMatch:
    xor     ah, ah
    jmp     .KeepSearching
.NewLine:
    mov     ah, 0x01
    mov     si, [ParmPosition]
    jmp     .KeepSearching

ReadMoreData:
    push    ax
    push    di
    ZeroMemory ReadBuffer, ReadBufferEnd - ReadBuffer
    pop     di
    mov     ah, 0x3f
    mov     bx, [FileHandle]
    mov     cx, ReadBufferEnd - ReadBuffer
    mov     dx, ReadBuffer
    int     0x21
    mov     di, ReadBuffer
    mov     cx, ax
    pop     ax
    jnc     .ReadOK
    xor     cx, cx
    stc
    ret
.ReadOK:
    clc
    ret

ReadString:
    xor     ah, ah
.KeepReading:
    cmp     cx, 0
    jne     .NotEmpty
    call    ReadMoreData
    jc      ReadError
    cmp     cx, 0
    je      EndofString
.NotEmpty:
    mov     al, [di]
    inc     di
    inc     si
    dec     cx
    cmp     ah, 0x25
    je      .PercentValue
    cmp     al, 0x25    ; '%'
    jne     .NotPercent
    mov     ah, 0x25
    jmp     .KeepReading
.NotPercent:
    cmp     al, 0x0d
    je      EndofString
    cmp     al, 0x0a
    je      EndofString
    call    .PutChar
    jmp     .KeepReading
.PercentValue:
    xor     ah, ah
    cmp     al, 0x25
    je      .NotPercent
    cmp     ax, 0x0031 ; ascii '1'
    jl      .NotValue
    cmp     ax, 0x0039 ; ascii '9'
    jg      .NotValue
    ; insert parameter al
    jmp     .KeepReading
.NotValue:
    push    ax
    mov     al, 0x25
    call    .PutChar
    pop     ax
    call    .PutChar
    jmp     .KeepReading

.PutChar:
    push    di
    mov     di, [OutPosition]
    cmp     di, ExecLineEnd
    je      .OverFlow
    mov     [di], al
    inc     di
    mov     [OutPosition], di
.OverFlow:
    ; Just quit adding output on overflow.
    pop     di
    ret

EndofString:
; temporary development displayed output.
    StdOutStr ExecLine
    StdOutCRLF

    Terminate 0

MatchNotFound:
    ; Nothing at present
ReadError:
    ; Nothing at present
BadParams:
    StdOutStr CommandLineErrorMsg
    StdOutCRLF
ErrorExit:
    call    CloseFile
    Terminate 100

CloseFile:
    mov     bx, [FileHandle]
    cmp     bx, 0
    je      .NotOpen
    mov     ah, 0x3e
    int     0x21
.NotOpen:
    ret

OutPosition:
    dw 0
ParmPosition:
    dw 0

FileNamePtr:
    dw 0
FileHandle:
    dw 0

ParamBlock:
    .EnvSeg:    dw 0
    .CmdLnPtr:  dw ExecLine,0
    .FCBS:      dw 0,0
ExecLine:       times 127 db 0x0d
ExecLineEnd:
    db 0x0d,0

ReadBuffer:
    times 16 db 0
ReadBufferEnd:
    db 0