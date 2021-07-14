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



struc tPDA

    .BEGIN          resb 0
    .QUITE          resb 1
    .VERBOSE        resb 1

    .RESET          resb 0
    .DRIVE_ID       resw 1
    .DRIVE_TYPE     resb 1

    .MODE           resb 1

    .FILENAME       resb 128
    .FILENAME_END   resb 1

    .MBR_BUFFER     resb 512
    .MBR_BUFFER_END resb 0

    .DTA            resb 512
    .DTA_END        resb 0

    .END            resb 0

endstruc

%idefine PDA(x) PDA_START + tPDA. %+ x

    ZeroFill      PDA(BEGIN), PDA(END)

    CommandLineParser       ; insert code for command line parsing

    call            GetDriveInfo
    mov             ah, [PDA(MODE)]
    cmp             ah, 0x0
    je              DisplayDrive


Done:
    Terminate 0

DisplayDrive:
    cmp             al, 0x80
    jb              DisplayFloppy

DisplayHD:
    push            ax
    StdOutStr       Msg_HardDrive
    pop             ax
    and             al, 0x7F
    StdOutIntByte   al
    StdOutCRLF
    StdOutCRLF
    call            FetchMBR
    ; StdOutHexASCIIDump PDA(MBR_BUFFER), PDA(MBR_BUFFER_END)
    ; StdOutCRLF
    jmp             Done

DisplayFloppy:
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

    StdOutStr       Msg_ChangeLine
    mov             dl, [PDA(DRIVE_ID)]
    mov             ah, 0x15
    int             0x13
    jnc             .GotDiskType
    mov             al, ah
    call            ErrorMessage

    jmp             .NextTest
.GotDiskType:
    mov             di, Msg_Unknown
    cmp             ah, 0
    je              .ShowDiskType
    mov             di, Msg_Unsupported
    cmp             ah, 1
    je              .ShowDiskType
    mov             di, Msg_Supported
    cmp             ah, 2
    je              .ShowDiskType
    mov             di, Msg_NotAFloppyDrive
.ShowDiskType:
    call            StdOutStr_Proc
    StdOutCRLF
.NextTest:
    StdOutCRLF
    call            FetchMBR
    ; StdOutHexASCIIDump PDA(MBR_BUFFER), PDA(MBR_BUFFER_END)
    ; StdOutCRLF
    jmp             Done

GetDriveInfo:
    mov             ax, [PDA(DRIVE_ID)]
    cmp             ah, 0
    je              NoDriveAssigned
    mov             ah, 0x08
    push            di
    push            es
    xor             di, di
    mov             es, di
    mov             dl, al
    and             dl, 0x80
    cmp             al, 1
    jne             .TestNow
    mov             dl, 1
.TestNow:
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
    mov             [PDA(DRIVE_TYPE)], bl
    mov             ah,0x48
    mov             dl, [PDA(DRIVE_ID)]
    mov             si, PDA(DTA)
    DebugHexWord    [PDA(DTA)]

    ret

FetchMBR:
    mov             cx, 3
.ReadRetry:
    push            cx
    ZeroFill        PDA(MBR_BUFFER), PDA(MBR_BUFFER_END)
    mov             ax, 0x0201
    mov             cx, 0x0001
    xor             dh, dh
    mov             dl, [PDA(DRIVE_ID)]
    mov             bx, PDA(MBR_BUFFER)
    int             0x13
    pop             cx
    jnc             .ReadOK
    loop            .ReadRetry
    mov             al, ah
    call            ErrorMessage
    jmp             ErrorTerminate
.ReadOK:
    ret

ErrorHeader:
    push            ax
    mov             al, [PDA(QUITE)]
    cmp             al, 1
    je              ErrorTerminateNoMsg
    pop             ax
    push            ax
    StdOutStr       Msg_ErrorHeader
    pop             ax
    clc
    ret

ErrorMessage:
    call            ErrorHeader
    push            ax
    StdOutChar      "#"
    pop             ax
    StdOutIntByte   al
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
    mov         [PDA(VERBOSE)], al
    xor         al, al
    mov         [PDA(QUITE)], al
    ret

SwitchQ:
    mov         al, 1
    mov         [PDA(QUITE)], al
    xor         al, al
    mov         [PDA(VERBOSE)], al
    ret

SwitchD:
    NumberParam
    add         ax, 0x0080
    mov         ah, 0x01
    mov         [PDA(DRIVE_ID)], ax
    ret

SwitchF:
    NumberParam
    mov         ah, 0x01
    mov         [PDA(DRIVE_ID)], ax
    ret

SwitchN:
    push            di
    push            cx
    ZeroFill        PDA(FILENAME), PDA(FILENAME_END)
    pop             cx
    pop             si
    mov             di, PDA(FILENAME)
    cld
.CopyFileName:
    lodsb
    stosb
    loop            .CopyFileName
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
    SwitchData 'D', 1, SwitchD  ; Hard Drive (number)
    SwitchData 'F', 1, SwitchF  ; Floppy (number)
    SwitchData 'N', 1, SwitchN  ; Specify File (name)
    SwitchData  0,  0, 0

OptionsTable:
    TableEnd


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
Msg_ChangeLine:
    db "Change Line ",0
Msg_FloppyDriveType:
    db "Drive Type ",0
Msg_NotAFloppyDrive:
    db "not a floppy",0
Msg_FloppyDriveTable:
    db 0,
Msg_Unknown:
    db "unknown",0
    db 1,"360k",0
    db 2,"1.2m",0
    db 3,"720k",0
    db 4,"1.44m",0
    db 5,"2.88m (Maybe)",0
    db 6,"2.88m",0
    db 0x10,"ATAPI",0
    db 0xff,"Other",0
Msg_Error:
    db "error",0
Msg_Unsupported:
    db "un"
Msg_Supported:
    db "supported"

PDA_START:

