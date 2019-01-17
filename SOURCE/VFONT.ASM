; Copyright (C) 2019 Jerome Shidel
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

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

    Terminate 0

NoSwitch:
    push        es
    mov         ax, 0x0040
    mov         es, ax
    mov         ah, [es:0x0085] ; EGA Character Height (word but anything above
                                ; about 30 is never supported by hardware)
    pop         es
    mov         al, [DataHeight]
    cmp         al, 0x00
    je          ChangeFont
    cmp         al, ah
    je          ChangeFont
    ret

ChangeFont:
    mov         dl, [si]
    xor         al, al
    mov         [si], al
    push        dx
    mov         dx, di
    mov         ax, 0x3d00
    int         0x21
    jc          .FileCleanup
    mov         [FileHandle], ax
.FileCleanup:
    pop         dx
    mov         [si], dl
    jc          FileError
    mov         ax, 0x3f00
    mov         bx, [FileHandle]
    mov         cx, 0x6000
    mov         dx, DataTemp
    int         0x21
    jc          FileError
    mov         [FileSize], ax
    FileClose   FileHandle
    jc          FileError
    ret

SwitchF:
    LookupParam FontOptionTable
    cmp         ax, 0xffff
    je          NotOption
    jmp         SetFontTarget
NotOption:
    NumberParam
    cmp         ax, 30
    ja          ValueOutOfRange
SetFontTarget:
    mov         [DataHeight], al
    ret

SwitchA:
    mov         al, 0x01
    mov         [DataAlternate], al
    ret

SwitchS:
    mov         al, 0x01
    mov         [DataSave], al
    mov         al, 0x00
    mov         [DataReset], al
    ret

SwitchR:
    mov         al, 0x01
    mov         [DataReset], al
    mov         [DataInit], al
    mov         al, 0x00
    mov         [DataSave], al
    ret

SwitchX:
    mov         al, 0x01
    mov         [DataEffects], al
    ret

SwitchI:
    mov         al, 0x01
    mov         [DataInit], al
    ret

SwitchP:
    mov         al, 0x01
    mov         [DataPermanent], al
    ret

FileErrorMsg:
    db 'File Error #',0
FileError:
    push        ax
    push        ax
    StdOutStr   FileErrorMsg
    pop         ax
    StdOutIntWord
    StdOutCRLF
    FileClose   FileHandle
    pop         ax
    Terminate   al

ValueOutOfRange:
InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'P',  0, SwitchP ; Permanent
    SwitchData  'A',  0, SwitchA ; Force Alternate
    SwitchData  'S',  0, SwitchS ; Store Contents
    SwitchData  'R',  0, SwitchR ; Reset settings
    SwitchData  'X',  0, SwitchX ; Special Effects
    SwitchData  'I',  0, SwitchI ; Initialize Display
    SwitchData  'F',  1, SwitchF ; Font Height
    HelpSwitchData
    SwitchData  0,  0, 0

FontOptionTable:
    TableData "EGA",14
    TableData "VGA",16
    TableEnd

FileHandle:
    dw 0
FileSize:
    dw 0
VideoSize:
    dw 0
DataHeight:
    db  0
DataAlternate:
    db 0
DataSave:
    db 0
DataReset:
    db 0
DataEffects:
    db 0
DataInit:
    db 0
DataPermanent:
    db 0

DataTemp:

