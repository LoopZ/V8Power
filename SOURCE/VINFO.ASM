
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

%idefine ASCII_Table

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

    mov     ax, [OptionProcessed]
    cmp     ax, 0xffff
    jne     Done

    ; PlaceHolder

Done:
    mov         al, [ExitCode]
    Terminate   al

%include "DSKTLS.INC"
%include "MACHINES.INC"

%ifdef ASCII_Table
ShowAscii:
    mov         al, 0x20
    WriteChar   0x09
    WriteChar   0x09
    WriteChar   0x09
    WriteChar   0x09
    WriteChar   0x09
    mov         bx, 0x30

.ShowAscii_1:
    push        bx
    mov         al, 0x20
    WriteChar   0x09
    mov         al, '+'
    WriteChar   0x09
    mov         al, 0x30
    WriteChar   0x09
    pop         bx
    push        bx
    mov         al, bl
    WriteChar   0x09
    pop         bx
    inc         bx
    cmp         bx, 0x3a
    jne         .ShowAscii_2
    add         bx, 0x27
.ShowAscii_2:
    cmp         bx, 0x67
    jne         .ShowAscii_1
    xor         bx, bx
.ShowAscii_3:
    push        bx
    WriteStr    .ShowAscii_CRLF
    pop         bx
    push        bx
    mov         ax, bx
    push        ax
    mov         al, '0'
    WriteChar   0x09
    mov         al, 'x'
    WriteChar   0x09
    pop         ax
    mov         cl, 4
    shr         al, cl
    cmp         al, 0x0a
    jl         .ShowAlpha
    add         al, 0x07
.ShowAlpha:
    add         al, 0x30
    WriteChar   0x09
    mov         al, '0'
    WriteChar   0x09
    mov         al, 0x20
    WriteChar   0x09

    pop         bx
    xor         cx, cx
.ShowAscii_4:
    push        bx
    push        cx
    mov         ax, bx
    add         ax, cx
    push        ax
    mov         al, 0x20
    WriteChar   0x09
    WriteChar   0x09
    WriteChar   0x09
    pop         ax
    WriteChar   0x09
    pop         cx
    pop         bx
    inc         cx
    cmp         cx, 0x10
    jne         .ShowAscii_4
    add         bx, cx
    cmp         bx, 0x100
    jl          .ShowAscii_3
    ret
.ShowAscii_CRLF:
    db          CRLF,0
%endif

SwitchV:
    mov         [OptionProcessed], cx
    mov         al, 1
    mov         [QueryMode], al
    ret

SwitchD:
    mov         [OptionProcessed], cx
    DiskStatus      [di]
    cmp         al, 0
    je          .Skip
    mov         [ExitCode], al
.Skip:
    mov         ah, [QueryMode]
    cmp         ah, 1
    jne         .Done
    DiskStatusMessage  al
.Done:
    ret

SwitchM:
    mov         [OptionProcessed], cx
    DetectMachine
    cmp         al, 0
    je          .Skip
    mov         [ExitCode], al
.Skip:
    mov         ah, [QueryMode]
    cmp         ah, 1
    jne         .Done
    MachineStatusMessage  al
.Done:
    ret

SwitchC:
    StdOutStr   0x81
    StdOutCRLF
    mov         di, 0x80
    xor         ax, ax
.Repeat:
    lodsb
    StdOutIntWord
    push        ax
    StdOutChar ' '
    pop         ax
    cmp         al,0
    jne         .Repeat
    StdOutCRLF
    Terminate 0

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    mov         [OptionProcessed], ax
    jmp         ax


.NotOption:
    NumberParam
    ; do something with ax

InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData 'D', 1, SwitchD
    SwitchData 'V', 0, SwitchV
    SwitchData 'M', 0, SwitchM
    SwitchData 'C', 0, SwitchC
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
%ifdef ASCII_Table
    TableData "ASCII", ShowAscii
%endif
    TableEnd


OptionProcessed:
    dw 0xffff
QueryMode:
    db  0
ExitCode:
    db  0
SavedInt24:
    dw 0, 0
Drive:
    db 0

