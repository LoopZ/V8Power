; Copyright (C) 2017 Jerome Shidel
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

%idefine STACK_SIZE 0x0200

    mov         sp, StackBottom + STACK_SIZE

    multipush   bx, cx, es, ds, si, di
    push        cs
    pop         es
    mov         ax, sp
    add         ax, 2
    mov         cl, 4
    shr         ax, cl
    inc         ax
    mov         bx, ax
    mov         ax, 0x4a00
    int         0x21
    jnc         FootprintReduced
    multipop    bx, cx, es, ds, si, di
    StdOutStr   Memory_Error_Message
    Terminate   8
FootprintReduced:
    multipop    bx, cx, es, ds, si, di

    CommandLineParser       ; insert code for command line parsing

    mov     al, [ExitCode]
    Terminate al

SwitchM:
    ShellExec   .Program, .Options

    ret
    .Program:
        db "C:\FDOS\BIN\MEM.EXE",0
    .Options:
        db "/c/p",0

NoSwitch:
    ret

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'M', 0, SwitchM
    HelpSwitchData
    SwitchData  0,  0, 0

Memory_Error_Message:
    db  "memory error",CRLF,0

ExitCode:
    db 0

StackBottom:
