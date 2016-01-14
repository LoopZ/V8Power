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
%idefine SuperVGA

%include "COMMON.INC"

    call        ReadMode
    mov         [ModeFirst], ax

    CommandLineParser       ; insert code for command line parsing

GoodBye:
    mov     ax, [ModeCurrent]
    mov     bx, [ModeFirst]
    cmp     ax, bx
    jne     .SetNewMode
    StdOutHexWord
    StdOutCRLF
    jmp     .Done
.SetNewMode:
    call    WriteMode
.Done:
    Terminate 0

ReadMode:
    %ifdef SuperVGA
        call    ReadModeSVGA
        cmp     ax, 0x100
        jge     .Done
    %endif
    mov     ah, 0x0f
    int     0x10
    xor     ah, ah
    cmp     al, 0x07
    jle     .Normal
    mov     ax, 0xffff
    jmp     .Done
.Normal:
    push        es
    mov         bx, 0x0040
    push        bx
    pop         es
    mov         bl, [es:0x0085]
    pop         es
    mov         bh, 0x10
    cmp         bl, 0x08
    je          .KnownFont
    mov         bh, 0x20
    cmp         bl, 0x0e
    je          .KnownFont
    mov         bh, 0x30
    cmp         bl, 0x10
    je          .KnownFont
    mov         bh, 0x00
.KnownFont:
    or          al, bh
.Done:
    mov         [ModeCurrent], ax
    ret

WriteMode:
    mov     ax, [ModeCurrent]
    cmp     ax, 0xffff
    je      .Invalid
    cmp     ax, 0x0100
    jge     .NotStandard
    and     al, 00001111b
    mov     ah, 0x00
    int     0x10
    mov     ax, [ModeCurrent]
    and     al, 0xf0
    cmp     al, 0x10
    jl      .Done
    mov     bl, 0x12
    cmp     al, 0x10
    je      .LoadROMFont
    mov     bl, 0x11
    cmp     al, 0x20
    je      .LoadROMFont
    mov     bl, 0x14
    cmp     al, 0x30
    jne     .Done
.LoadROMFont:
    mov     al, bl
    mov     ah, 0x11
    mov     bl, 0
    int     0x10
    ; fix cursor
    mov     ah, 0x03
    mov     bh, 0
    int     0x10
    push    cx
    mov     cx, 0x2000
    mov     ah, 0x01
    int     0x10
    pop     cx
    int     0x10
    jmp     .Done
.NotStandard:
    %ifdef SuperVGA
        call    WriteModeSVGA
        jmp     .Done
    %endif
.Invalid:
    Terminate 100
.Done:
    ret

ReadModeSVGA:
    push    di
    mov     ax, 0x4f00
    mov     di, SVGABuffer
    int     0x10
    cmp     ax, 0x004f
    jne     .NoVesa
    ; quick dirty VESA test
    mov     dx, [SVGABuffer]
    cmp     dx, 'VE'
    jne     .NoVesa
    mov     dx, [SVGABuffer + 2]
    cmp     dx, 'SA'
    jne     .NoVesa
    ; get mode
    mov     ax, 0x4f03
    int     0x10
    cmp     ax, 0x004f
    jne     .NoVesa
    mov     ax, bx
    jmp     .Done
.NoVesa:
    xor     ax, ax
.Done:
    pop     di
    ret

WriteModeSVGA:
    push    di
    mov     ax, 0x4f00
    mov     di, SVGABuffer
    int     0x10
    cmp     ax, 0x004f
    jne     .NoVesa
    ; quick dirty VESA test
    mov     dx, [SVGABuffer]
    cmp     dx, 'VE'
    jne     .NoVesa
    mov     dx, [SVGABuffer + 2]
    cmp     dx, 'SA'
    jne     .NoVesa
    ; get mode
    mov     ax, 0x4f02
    mov     bx, [ModeCurrent]
    int     0x10
    cmp     ax, 0x004f
    je      .Done
    pop     di
    StdOutStr FailVesaMsg
    Terminate 100
.NoVesa:
    StdOutStr NoVesaMsg
    Terminate 101
.Done:
    pop     di
    ret

    LookupParamProc
    NumberParamProc

OptVesa:
    push    es
    push    si
    push    di
    mov     ax, 0x4f00
    mov     di, SVGABuffer
    int     0x10
    cmp     ax, 0x004f
    jne     .NoVesa
    ; quick dirty VESA test
    mov     dx, [SVGABuffer]
    cmp     dx, 'VE'
    jne     .NoVesa
    mov     dx, [SVGABuffer + 2]
    cmp     dx, 'SA'
    jne     .NoVesa
    les     si, [SVGABuffer + 0x0e]
.Looping:
    mov     ax, [es:si]
    cmp     ax, 0xffff
    je      .Done
    StdOutHexWord
    StdOutCRLF
    add     si, 2
    jmp     .Looping
.NoVesa:
    pop     di
    StdOutStr NoVesaMsg
    push    di
.Done:
    pop     di
    pop     si
    pop     es
    Terminate 0
;    ret

OptBW40:
    mov     ax, 0x0000
    jmp     SetModeCurrent

OptColor40:
    mov     ax, 0x0001
    jmp     SetModeCurrent

OptBW80:
    mov     ax, 0x0002
    jmp     SetModeCurrent

OptColor80:
    mov     ax, 0x0003
    jmp     SetModeCurrent

OptMono80:
    mov     ax, 0x0007
    jmp     SetModeCurrent

OptFont8:
    and     bx, 0x000f
    mov     ax, 0x0010
    or      ax, bx
    jmp     SetModeCurrent

OptFont14:
    and     bx, 0x000f
    mov     ax, 0x0020
    or      ax, bx
    jmp     SetModeCurrent

OptFont16:
    and     bx, 0x000f
    mov     ax, 0x0030
    or      ax, bx
    jmp     SetModeCurrent

SwitchF:
    mov     ax, 0xffff
    mov     [ModeFirst], ax
    ret

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    mov         bx, [ModeCurrent]
    jmp         ax

.NotOption:
    NumberParam
SetModeCurrent:
    mov         [ModeCurrent], ax
    ret

.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData 'F', 0, SwitchF
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
    TableData 'B40',    OptBW40
    TableData 'B80',    OptBW80
    TableData 'BW40',   OptBW40
    TableData 'BW80',   OptBW80
    TableData 'BW',     OptBW80
    TableData 'C40',    OptColor40
    TableData 'C80',    OptColor80
    TableData 'CO40',   OptColor40
    TableData 'CO80',   OptColor80
    TableData 'COLOR',  OptColor80
    TableData 'MONO',   OptMono80
    TableData 'FONT8',  OptFont8
    TableData 'FONT14', OptFont14
    TableData 'FONT16', OptFont16
    TableData 'F8',     OptFont8
    TableData 'F14',    OptFont14
    TableData 'F16',    OptFont16
    TableData 'VESA',   OptVesa
    TableEnd

%ifdef SuperVGA
FailVesaMsg:
    DB 'Bad Vesa Mode.',CRLF,0
NoVesaMsg:
    DB 'No Vesa Support Present.',CRLF,0
SVGABuffer:
    times 0x100 db 0
%endif
ModeCurrent:
    dw      0
ModeFirst:
    dw      0