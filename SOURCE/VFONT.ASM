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

%define ALPHA_CODE

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
    je          .SetROMFont
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
    mov         bp, DataTemp
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
    DebugInt

V8Font:
    mov         si, DataTemp
    cld
.SkipToData:
    lodsb
    cmp         si, 0
    je          FontError
    cmp         al, 26
    jne         .SkipToData
.ReadBlock:
    lodsb
;    mov         ah, 0
;    DebugInt
;    DebugCRLF
    mov         cx, [si]
    cmp         al, 0
    je          .DoneReading
    cmp         al, 1
    je          .ReadChars
    add         si, cx
    jo          FontError
    jmp         .ReadBlock
.ReadChars:
    mov         ax, [si + 6]
    cmp         ax, 8   ; Check 8 bit width
    jne         FontError

    mov         ax, [si + 8]
    mov         bx, [DataVHeight]
    cmp         bx, 0
    jne         .CheckChars
    mov         bx, ax
    mov         [DataVHeight], bx
    ; Clone BIOS font
    push        ax
    push        bx
    push        cx
    mov         di, [FileSize]
    add         di, DataTemp
    mov         cx, 0x07F
    mov         bh, 0x03
    cmp         al, 8
    je          .Clone8
    mov         cx, 0x0100
    mov         bh, 0x02
    cmp         al, 14
    je          .Clone14
    mov         bh, 0x06
    cmp         al, 16
    je          .Clone16

    ; Unknown So Clear it
    mul         cx
    mov         cx, ax
    xor         al, al
.ClearFontLoop:
    stosb
    loop        .ClearFontLoop
    jmp         .DoneCloneBIOS

.CloneCopy:
    push        es
    push        bp
    push        ax
    push        cx

    mul         cx
    mov         cx, ax
    push        cx
    mov         ax, 0x1130
    int         0x10
    pop         cx
.CloneCopying:
    mov         al, [es:bp]
    mov         [ds:di], al
    inc         bp
    inc         di

    loop        .CloneCopying

    pop         cx
    pop         ax
    pop         bp
    pop         es
    ret

.Clone8:
    call        .CloneCopy
    mov         bh, 0x04
    call        .CloneCopy
    jmp         .DoneCloneBIOS

.Clone14:
.Clone16:
    call        .CloneCopy
    jmp         .DoneCloneBIOS

.DoneCloneBIOS:
    pop         cx
    pop         bx
    pop         ax

.CheckChars:
    cmp         ax, bx   ; Check Height
    jne         FontError
    jne         .IgnoreChars
.CloneChars:
    push        cx
    push        si
    mov         ax, [si + 4] ; count
    mul         bx
    mov         cx, ax
    mov         ax, [si + 2] ; first
    mul         bx
    mov         di, ax
    mov         dx, [FileSize]
    add         di, dx
    add         di, DataTemp
    add         si, 10
.Cloning:
    lodsb
    stosb
    loop        .Cloning
    pop         si
    pop         cx
.IgnoreChars:
    add         si, cx
    jmp         .ReadBlock
.DoneReading:
    mov         bx, [DataVHeight]
    mov         [DataHeight], bl
    cmp         bx, 0
    je          FontError
    mov         ax, 0x0100
    mul         bx
    mov         cx, ax
    mov         di, DataTemp
    mov         si, [FileSize]
    add         si, di
    mov         [FileSize], cx
.Relocate:
    lodsb
    stosb
    loop        .Relocate
;    Terminate   0
    jmp         SetFont

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

%ifndef ALPHA_CODE
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
%endif

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
%ifndef ALPHA_CODE
    SwitchData  'P',  0, SwitchP ; Permanent
    SwitchData  'A',  0, SwitchA ; Force Alternate
    SwitchData  'S',  0, SwitchS ; Store Contents
    SwitchData  'R',  0, SwitchR ; Reset settings
    SwitchData  'X',  0, SwitchX ; Special Effects
    SwitchData  'I',  0, SwitchI ; Initialize Display
    SwitchData  'E',  1, SwitchE ; Export as V8FONT
%endif
    SwitchData  'F',  1, SwitchF ; Font Height
    SwitchData  'D',  0, SwitchD ; Font Default
    HelpSwitchData
    SwitchData  0,  0, 0

FontOptionTable:
    TableData "EGA",14
    TableData "VGA",16
    TableEnd
V8FontID:
    db  'V8FONT',0x0d,0x0a,0
FileHandle:
    dw 0
FileSize:
    dw 0
VideoSize:
    dw 0
DataHeight:
    db 0
DataVHeight:
    dw 0
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

