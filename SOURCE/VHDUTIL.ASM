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

    Terminate 0

%include "DSKTLS.INC"

SwitchV:
    mov         al, 1
    mov         [Verbose], al
    ret

SwitchD:
    NumberParam
    push di
    push es
    mov             ah, 0x08
    xor             di, di
    mov             es, di
    mov             dl, 0x80
    push            ax
    int             0x13
    pop             ax
    jc              .Error
    pop             es
    pop             di
    cmp             dl, al
    jna             .NotPresent
    mov             ah, dl
    mov             [HardDisk], ax
    ret
.NotPresentMsg:
    db "No Hard Disk #",0
.Error:
    pop             es
    pop             di
.NotPresent:
    push            ax
    StdOutStr       .NotPresentMsg
    pop             ax
    StdOutIntByte   al
    StdOutCRLF
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
    SwitchData 'V', 0, SwitchV
    SwitchData 'D', 1, SwitchD
    SwitchData  0,  0, 0

OptionsTable:
    TableEnd

Verbose:
    db  0
HardDisk:
    dw  0

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

