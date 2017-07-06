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

; Note, File I/O for viewing just uses the Translate Buffer File I/O area.
; So, only one file can be viewed.

    FrameBounds

MainParsing:

    Placeholder
    Terminate 0

    CommandLineParser       ; insert code for command line parsing

; Check window is not larger than 60 lines
    mov     al, [WindMax+1]
    sub     al, [WindMin+1]
    cmp     al, 60
    ja      ParamError

; Check that Filename was set
    mov    di, [FileName + 2]
    cmp    di, 0
    je     ParamError

; Disable Smooth scrolling if not FullScreen
    mov         bx, [WindMin]
    cmp         bx, 0
    jne         .CannotSmooth
    mov         bx, [WindMax]
    mov         dx, [ScreenMax]
    cmp         bx, dx
    je          .CanSmooth
.CannotSmooth:
    xor         al, al
    mov         [SmoothScroll], al
.CanSmooth:
; Zero terminate filename
    xor     al, al
    mov     [di], al
    mov     si, [FileName]

    FileOpen  FileName, FileHandle
    call      PageCalc
    call      PageShow
    FileClose FileHandle
    Terminate 0

PageCalc:
    ret

PageShow:
    ret


NoSwitch:
    mov     [FileName], di
    mov     [FileName + 2], si
    ret

%include "TRANSLAT.INC"

SwitchT:
    Translator MainParsing
    LocalSwitchHandlers
    ColorSwitchHandlers
    HelpSwitchHandler

SwitchS:
    xor         ah, ah
    mov         al, [di]
    cmp         al, '-'
    je          .SetSmooth
    mov         ah, 1
    cmp         al, '+'
    jne         ParamError
.SetSmooth:
    mov         [SmoothScroll], ah
    ret

ParamError:
    WriteStr    CommandLineErrorMsg
	Terminate   100

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    ColorSwitchData
    LocalSwitchData
    HelpSwitchData
    SwitchData 'T', 1, SwitchT
    SwitchData 'S', 1, SwitchS
    SwitchData  0,  0, 0

SmoothScroll:   db 0

FileName:       dw 0, 0
ShiftOffset:    dw 0
PageStart:      dd 0
LineStart:      times 60 dw 0
PageEnd:        dd 0
