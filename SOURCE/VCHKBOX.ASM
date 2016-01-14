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

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

    ; PlaceHolder 

    Terminate 0
    
NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    jmp         ax      

.NotOption:
    NumberParam
    ; do something with ax
    
.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

    HelpSwitchHandler

    
CommandLineSwitches:
    SwitchData  0,  0, NoSwitch  
    HelpSwitchData
    SwitchData  0,  0, 0
    
OptionsTable:
    TableEnd