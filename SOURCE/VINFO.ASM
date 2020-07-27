
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
%include "V8-VBIOS.INC"

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

SwitchP:
    mov         [OptionProcessed], cx
    jmp         DetectCPU

SwitchC:
;    StdOutStr   0x81
;    StdOutCRLF
;    mov         di, 0x80
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

ShowByte:
    push    cx
    StdOutHexByte none
    pop     cx
    ret

ShowWord:
    push    ax
    mov     al, ah
    call    ShowByte
    pop     ax
    call    ShowByte
    ret

ShowRAMline:
    cld
    mov     ax, ds
    call    ShowWord
    StdOutChar ':'
    StdOutChar '0'
    StdOutChar ' '
    StdOutChar ' '
    xor     si, si
    mov     cx, 0x10
.HexBytes:
    lodsb
    call    ShowByte
    StdOutChar ' '
    loop    .HexBytes
    StdOutChar ' '
    StdOutChar ' '
    xor     si, si
    mov     cx, 0x10
.CharBytes:
    lodsb
    cmp       al, 7 ; bell
    je        .Hidden
    cmp       al, 8 ; backspace
    je        .Hidden
    cmp       al, 9 ; tab
    je        .Hidden
    cmp       al, 10 ; Carriage Return
    je        .Hidden
    cmp       al, 11 ; Vertical Tab
    je        .Hidden
    cmp       al, 12 ; Form Feed
    je        .Hidden
    cmp       al, 13 ; LineFeed
    je        .Hidden
    cmp       al, 26 ; EOF
    je        .Hidden

    StdOutChar al
    jmp        .Shown;
.Hidden:
    StdOutChar '.'
.Shown:
    loop     .CharBytes
    StdOutChar 10
    StdOutChar 13
    ret

ShowRAM:
    push    ds
    mov     ax, ds
    mov     cx, 0
.cycle:
    push    cx
    push    ax
    mov     ds, ax
    call    ShowRAMline
    pop     ax
    pop     cx
    inc     ax
    loopnz  .cycle
    pop     ds
    ret

SwitchU:
    cld
    push    di
    mov     si, di
.Loopy:
    lodsb
    cmp     al, 0
    je      .Done
    cmp     al, 0x61
    jb      .NoCase
    cmp     al, 0x7a
    ja      .NoCase
    sub     al, 0x20
.NoCase:
    stosb
    jmp     .Loopy
.Done:
    pop     di
    mov     bl, 1
    mov     ax, 0xa000
    jmp     SearchRAM

SwitchR:
    mov     bl, 0
    xor     ax, ax

SearchRAM:
    cld
    mov     si, di
    mov     es, ax
    xor     ax, ax
    mov     di, ax
.CheckPos:
    push    di
    push    si
.CheckLoop:
    lodsb
    mov     ah, [es:di]
    inc     di

    cmp     al, 13
    je      .Same
    cmp     al, 0
    je      .Same
    cmp     bl, 0
    je      .CheckChar

    cmp     ah, 0x61
    jb      .CheckChar
    cmp     ah, 0x7a
    ja      .CheckChar
    sub     ah, 0x20
.CheckChar:
    cmp     al, ah
    jne     .Diff
    jmp     .CheckLoop
.Same:
    pop     si
    pop     di
    push    di
    push    si
    mov     ax, es
    call    ShowWord
    StdOutChar ':'
    mov     ax, di
    call    ShowWord
    StdOutChar 10
    StdOutChar 13

    push    es
    push    ds

    push    es
    pop     ds

    call    ShowRAMline
    mov     ax, ds
    inc     ax
    mov     ds, ax
    call    ShowRAMline

    pop     ds
    pop     es
.Diff:
    pop     si
    pop     di
    inc     di
    cmp     di, 0x0010
    jb      .CheckPos
    xor     di, di
    push    es
    pop     ax
    inc     ax
    push    ax
    pop     es
    cmp     ax, 0xffff
    jne     .CheckPos

    Terminate   0

SwitchG:
    Probe_Display_Adapter
    mov     ah, [QueryMode]
    cmp     ah, 0
    je      .SwitchGExit
    push    ax
    mov     ah, al
    mov     di, .DisplayTypes
    cmp     ah, 9
    jna     .Find
    xor     ah, ah
.Find:
    cmp     ah, 0
    je      .Print
    mov     al, [di]
    inc     di
    cmp     al, 0
    jne     .Find
    dec     ah
    jmp     .Find
.Print:
    ; dec         di
    StdOutStr   di
    StdOutCRLF
    pop  ax
.SwitchGExit:
    Terminate al

.DisplayTypes:
    db 'Unknown',0
    db 'MDA',0
    db 'HGC',0
    db 'HGCPlus',0
    db 'InColor',0
    db 'CGA',0
    db 'EGA',0
    db 'MCGA',0
    db 'VGA',0
    db 'VESA/SuperVGA',0

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData 'D', 1, SwitchD
    SwitchData 'V', 0, SwitchV
    SwitchData 'M', 0, SwitchM
    SwitchData 'P', 0, SwitchP
    SwitchData 'C', 0, SwitchC
    SwitchData 'U', 1, SwitchU
    SwitchData 'R', 1, SwitchR
    SwitchData 'G', 0, SwitchG
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
%ifdef ASCII_Table
    TableData "ASCII", ShowAscii
    TableData "RAM", ShowRAM
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
EndOfCode:
