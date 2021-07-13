; Copyright (C) 2016-2020 Jerome Shidel
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

    call            GetDriveInfo
    mov             ah, [OperationMode]
    cmp             ah, 0x0
    je              DisplayDrive

Done:
    Terminate 0

DisplayDrive:
    cmp             al, 0x80
    jb              .DisplayFloppy
.DisplayHD:
.DisplayFloppy:
    push            ax
    StdOutStr       Msg_FloppyDrive
    pop             ax
    StdOutIntByte   al
    StdOutCRLF
    push            bx
    StdOutStr       Msg_FloppyDriveType
    pop             bx
    cld
    mov             si, Msg_FloppyDriveTable
.CheckFloppyDriveType:
    lodsb
    cmp             al, bl
    je              .ShowFloppyDriveType
    cmp             al, 0xff
    je              .ShowFloppyDriveType
.NextFloppyDriveType:
    lodsb
    cmp             al,0x00
    je              .CheckFloppyDriveType
    jmp             .NextFloppyDriveType
.ShowFloppyDriveType:
    StdOutStr       si
    StdOutCRLF
    jmp             Done

GetDriveInfo:
    mov             ax, [DriveID]
    cmp             ah, 0
    je              NoDriveAssigned
    mov             ah, 0x08
    push            di
    push            es
    xor             di, di
    mov             es, di
    mov             dl, al
    and             dl, 0x80
    push            ax
    int             0x13
    mov             di, bx
    pop             bx
    mov             al, bl
    mov             bx, di
    pop             es
    pop             di
    jc              NoSuchDrive
    push            ax
    and             al, 0x7f
    cmp             dl, al
    pop             ax
    jna             NoSuchDrive
    ret

ErrorHeader:
    push            ax
    mov             al, [Quite]
    cmp             al, 1
    je              ErrorTerminateNoMsg
    pop             ax
    push            ax
    StdOutStr       Msg_ErrorHeader
    pop             ax
    clc
    ret

NoDriveAssigned:
    call            ErrorHeader
    StdOutStr       Msg_NoDriveAssigned
    jmp             ErrorTerminate

NoSuchDrive:
    call            ErrorHeader
    mov             di, Msg_NoSuchFloppyDrive
    cmp             al, 0x80
    jb              .PrintMsg
    mov             di, Msg_NoSuchHardDrive
    sub             al, 0x80
.PrintMsg:
    push            ax
    call            StdOutStr_Proc
    pop             ax
    StdOutIntByte   al

ErrorTerminate:
    StdOutCRLF
ErrorTerminateNoMsg:
    Terminate       1


%include "DSKTLS.INC"

SwitchV:
    mov         al, 1
    mov         [Verbose], al
    xor         al, al
    mov         [Quite], al
    ret

SwitchQ:
    mov         al, 1
    mov         [Quite], al
    xor         al, al
    mov         [Verbose], al
    ret

SwitchD:
    NumberParam
    add         ax, 0x0080
    mov         ah, 0x01
    mov         [DriveID], ax
    ret

SwitchF:
    NumberParam
    mov         ah, 0x01
    mov         [DriveID], ax
    ret

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          InvalidOption
    jmp         ax

InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

    HelpSwitchHandler 'vhdutil'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    HelpSwitchData
    SwitchData 'Q', 0, SwitchQ
    SwitchData 'V', 0, SwitchV
    SwitchData 'D', 1, SwitchD
    SwitchData 'F', 1, SwitchF
    SwitchData  0,  0, 0

OptionsTable:
    TableEnd

Quite:
    db  0
Verbose:
    db  0
DriveID:
    dw  0
OperationMode:
    db  0

Msg_ErrorHeader:
    db 'Error: ',0
Msg_NoDriveAssigned:
    db "No Drive Specified",0
Msg_NoSuchHardDrive:
    db "No "
Msg_HardDrive:
    db "Hard Drive #",0
Msg_NoSuchFloppyDrive:
    db "No "
Msg_FloppyDrive:
    db "Floppy Drive #",0
Msg_FloppyDriveType:
    db "Drive Type ",0
Msg_FloppyDriveTable:
    db 0,"Unknown",0
    db 1,"360k",0
    db 2,"1.2m",0
    db 3,"720k",0
    db 4,"1.44m",0
    db 5,"2.88m (Maybe)",0
    db 6,"2.88m",0
    db 0x10,"ATAPI",0
    db 0xff,"Other",0

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

