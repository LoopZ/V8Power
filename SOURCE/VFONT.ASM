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

GetCharHeight:
    push        es
    mov         ax, 0x0040
    mov         es, ax
    mov         ah, [es:0x0085] ; EGA Character Height (word but anything above
                                ; about 30 is never supported by hardware)
    pop         es
    ret

SwitchD:
    call        GetCharHeight
    mov         al, ah
    cmp         al, 8
    je          .KnownValue
    cmp         al, 14
    je          .KnownValue
    mov         al, 16
.KnownValue:
    mov         [DataHeight], al
    xor         ax, ax
    mov         [FileSize], ax
    jmp         SetFont

NoSwitch:
    call        GetCharHeight
    mov         al, [DataHeight]
    cmp         al, 0x00        ; Font Height Not set
    je          LoadFontFile
    cmp         al, ah          ; Font Height Match
    je          LoadFontFile
    xor         al, al          ; Reset For Next
    mov         [DataHeight], al
    ret

LoadFontFile:
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
    CompareMemory DataTemp, V8FontID, 7
    je          V8Font
    ; Validate size is divisible by 256 (characters)
    xor         dx, dx
    mov         ax, [FileSize]
    mov         cx, 0x0100
    div         cx
    cmp         dx, 0x0000
    jne         FontError
    cmp         ax, 30
    ja          FontError
    cmp         ax, 1
    jb          FontError
    mov         [DataHeight], al

SetFont:
    mov         al, [DataSave]
    cmp         al, 0x00
    je          .NoSaveScreen

; Save Screen
    mov         al, [DataEffects]
    cmp         al, 0x00
    je          .NoRestoreScreen
; Special Effects
.NoSaveScreen:

    mov         al, [DataInit]
    cmp         al, 0x00
    je          .NoInit

; Initialize Video
.NoInit:

; Set Font
    mov         bl, 0

    mov         ax, [FileSize]
    cmp         ax, 0
    je          SetROMFont
; Set Custom Font
    mov         al, 0
    mov         bh, [DataHeight]
    mov         cx, 0x0100
    mov         dx, 0x0000
    jmp         .ApplyFont
.SetROMFont:
    mov         ah, [DataHeight]
    mov         al, 0x02
    cmp         ah, 8
    je          .ApplyFont
    mov         al, 0x01
    cmp         ah, 14
    je          .ApplyFont
    mov         al, 0x04
.ApplyFont:
    mov         ah, 0x11
    push        bp
    push        DataTemp
    pop         bp
    int         0x10
    pop         bp
    mov         al, [DataReset]
    cmp         al, 0x00
    je          .NoScreenReset
; Reset Stuff
    jmp         .Done
.NoScreenReset:
    mov         al, [DataSave]
    cmp         al, 0x00
    je          .NoRestoreScreen
; Restore Screen
    mov         al, [DataEffects]
    cmp         al, 0x00
    je          .NoRestoreScreen
; Special Effects
.NoRestoreScreen:

.Done:
    Terminate   0

V8Font:
    jmp         FontError

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

FontErrorMsg:
    db "Invalid font file format",0
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

FontError:
    WriteStr    FontErrorMsg
    Terminate   100
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
    SwitchData  'D',  1, SwitchD ; Font Default
    HelpSwitchData
    SwitchData  0,  0, 0

FontOptionTable:
    TableData "EGA",14
    TableData "VGA",16
    TableEnd
V8FontID:
    db  'V8FONT',0
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

