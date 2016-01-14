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

%idefine NoVideoOutput

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

    mov     ax, [DelayTime]
    call    DelayFunc

    Terminate 0

DelayFunc:
	mov  		dx, ax
	cmp			dx, 0x0000
	je			.NoDelay
	mov         al, [DelayMode]
	cmp         al, 0
	je          .Delay8086
	cmp         al, 2
	je          .Delay286
	Is286
	cmp			ax, 0x0001
	je			.Delay286
.Delay8086:
	DelayTicks	dx
	jmp			.NoDelay
.Delay286:
	DelayTimer	dx
.NoDelay:
    ret

SwitchD:
    mov         al, 1
    mov         [DelayMode], al
    ret

SwitchS:
    mov         al, 0
    mov         [DelayMode], al
    ret

SwitchI:
    mov         al, 2
    mov         [DelayMode], al
    ret

NoSwitch:
    NumberParam
    call        DelayFunc
    xor         ax, ax
    mov         [DelayTime], ax
    ret

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'D',  0, SwitchD
    SwitchData  'S',  0, SwitchS
    SwitchData  'I',  0, SwitchI
    HelpSwitchData
    SwitchData  0,  0, 0


DelayMode:
    DB 0

DelayTime:
    DW 1000
