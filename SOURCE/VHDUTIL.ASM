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
    SwitchData  0,  0, 0

OptionsTable:
    TableEnd

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

