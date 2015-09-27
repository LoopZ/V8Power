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

    CommandLineParser       ; insert code for command line parsing

    Terminate 0

ValidateFilename:
    cmp     cx, 2
    jl      InvalidOption
    mov     ax, [di]
    cmp     ah, 0x3a
    jne     InvalidOption
    cmp     al, 0x41
    jl      InvalidOption
    cmp     al, 0x7a
    jg      InvalidOption
    cmp     al, 0x5a
    jle     .OK_Drive
    cmp     al, 0x61
    jge     .OK_Drive
    jmp     InvalidOption
.OK_Drive:
    ret

ExpandFileName:
    push    si
    push    di
    push    cx
    push    di
    push    ax
    mov     cx, 127
    xor     ax, ax
    mov     di, Buffer
    cld
.ClearBuffer:
    stosb
    loop    .ClearBuffer
    pop     ax
    pop     di
    pop     cx
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
    je .Done
.CopyData:

    lodsb
    cmp     al, 0x61
    jl      .NotLower
    cmp     al, 0x7a
    jg      .NotLower
    sub     al, 0x20
.NotLower:
    stosb
    loop    .CopyData
.Done:
    pop     di
    pop     si
    ret


DoPrint:
    StdOutStr Buffer
    StdOutCRLF
    xor     al, al
    mov     [TextFlag], al
    ret

SwitchT:
    mov     al, 1
    mov     [TextFlag], al
    ret

SwitchD:
    call    ExpandFileName
    mov     al, [Buffer]
    mov     ah, [TextFlag]
    cmp     ah, 0
    jne     .PrintIt
    sub     al, 0x41
    mov     ah, 0x0e
    mov     dl, al
    int     0x21
    ret
.PrintIt:
    call    DoPrint
    ret

SwitchP:
    call    ExpandFileName
    ret

SwitchF:
    call    ExpandFileName
    call    DoPrint
    ret

SwitchN:
    call    ExpandFileName
    ret

SwitchE:
    call    ExpandFileName
    ret

SwitchU:
    call    ExpandFileName
    ret

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
    SwitchData 'T', 0, SwitchT
    SwitchData 'F', 1, SwitchF
    SwitchData 'D', 1, SwitchD
    SwitchData 'P', 1, SwitchP
    SwitchData 'N', 1, SwitchN
    SwitchData 'E', 1, SwitchE
    SwitchData 'U', 1, SwitchU
    SwitchData  0,  0, 0

OptionsTable:
    TableEnd

Buffer:
    times 128 db 0

TextFlag:
    db 0