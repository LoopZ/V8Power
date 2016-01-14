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

; Options ComandLine Parser
%imacro Translator 1
; Translator:
    mov     [FileNamePtr], di
    xor     al, al
.SearchStartTag:
    mov     [si], al
    inc     si
    cmp     al, 0x0d
    je      BadParams
    cmp     al, 0x20
    je     .SearchStartTag
    mov     [StrPosition], si
.SearhEndOfTag:
    mov     al, [si]
    inc     si
    cmp     al, 0x0d
    je      .EndOfTag
    cmp     al, 0x20
    jne     .SearhEndOfTag
.EndOfTag:
    mov     di, TransBuf
    mov     [OutPosition], di
    mov     [ParmPosition], si
    mov     si, [StrPosition]

; open translation file
    FileOpen FileNamePtr, FileHandle
    ; save output position

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
    mov     [StrPosition], si
    jmp     ReadString
.MissMatch:
    xor     ah, ah
    jmp     .KeepSearching
.NewLine:
    mov     ah, 0x01
    mov     si, [StrPosition]
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
    mov     ax, 0x0020
    call    .PutChar
.KeepReading:
    cmp     cx, 0
    jne     .NotEmpty
    call    ReadMoreData
    jc      ReadError
    cmp     cx, 0
    je      .EndOfString
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
    je      .EndOfString
    cmp     al, 0x0a
    je      .EndOfString
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
    mov     bh, al
    sub     al, 0x30
    mov     si, [ParmPosition]

.SearchParam:
    mov     ah, [si]
    cmp     ah, 0x20
    jne     .FindParam
    inc     si
    jmp     .SearchParam
.FindParam:
    mov     ah, [si]
    cmp     ah, 0x0d
    je      .NoParam
    cmp     ah, 0x22
    je      .Qouted
    cmp     ah, 0x27
    je      .Qouted
    cmp     ah, 0x60
    je      .Qouted
    mov     bl, 0x20
.CheckParam:
    dec     al
    cmp     al, 0
    je      .FoundParam
.FindParamEnd:
    mov     ah, [si]
    inc     si
    cmp     ah, 0x0d
    je      .NoParam
    cmp     ah, bl
    je      .SearchParam
    jmp     .FindParamEnd
.Qouted:
    mov     bl, ah
    inc     si
    jmp     .CheckParam
.FoundParam:
.AddParam:
    mov     al, [si]
    inc     si
    cmp     al, 0x0d
    je      .KeepReading
    cmp     al, bl
    je      .KeepReading
    call    .PutChar
    jmp     .AddParam
.NoParam:
    mov     al, bh
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
    cmp     di, TransBufEnd
    je      .OverFlow
    mov     [di], al
    inc     di
    mov     [OutPosition], di
.OverFlow:
    ; Just quit adding output on overflow.
    pop     di
    ret
.EndOfString:
    mov     al, 0x0d
    call    .PutChar
    xor     al, al
    call    .PutChar


; temporary development displayed output.
;    StdOutStr TransBuf
;    StdOutCRLF

; Execute Self with new Commands.
    call    CloseFile
    mov     si, TransBuf
    jmp %1

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
    FileClose FileHandle
    ret

StrPosition:
    dw 0
OutPosition:
    dw 0
ParmPosition:
    dw 0

FileNamePtr:
    dw 0
FileHandle:
    dw 0

TransBuf:
    times 256 db 0x0d
TransBufEnd:
    db 0x0d,0

ReadBuffer:
    times 256 db 0
ReadBufferEnd:
    db 0

%endmacro

