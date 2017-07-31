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

%idefine NoVideoOutput          ; A lie, but only using STDOUT

%include "COMMON.INC"

    CommandLineParser
    mov     al, [Shown]
    cmp     al, 0
    jne     Done
    call    OptAll
Done:
    Terminate 0

OptAll:
    StdOutCRLF
    call    OptName
    call    OptCopy
    call    OptVer
    call    OptURL
    call    OptEMail
    StdOutCRLF
    call    OptLic
    ret

OptName:
    StdOutStr OptNameMsg
    StdOutCRLF
    ret
OptVer:
    StdOutStr OptVerMsg
    StdOutCRLF
    ret
OptCopy:
    StdOutStr OptCopyMsg
    StdOutCRLF
    ret
OptLic:
    StdOutStr OptLicMsg
    StdOutCRLF
    ret
OptURL:
    StdOutStr OptURLMsg
    StdOutCRLF
    ret
OptEMail:
    StdOutStr OptEmailMsg
    StdOutCRLF
    ret

NoSwitch:
    LookupParam OptionsTable
    cmp     ax, 0xffff
    je      Oops
    mov     bl, 1
    mov     [Shown], bl
    jmp     ax
    ret

Oops:
    StdOutStr CommandLineErrorMsg
    StdOutCRLF
    Terminate 100

    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    HelpSwitchData
    SwitchData  0,  0, 0

Shown:
    db 0

OptionsTable:
    TableData "ALL", OptAll
    TableData "NAME", OptName
    TableData "COPYRIGHT", OptCopy
    TableData "VERSION", OptVer
    TableData "LICENSE", OptLic
    TableData "TITLE", OptName
    TableData "COPY", OptCopy
    TableData "VER", OptVer
    TableData "LIC", OptLic
    TableData "URL", OptURL
    TableData "EMAIL", OptEMail
    TableEnd

OptNameMsg:
    DB 'V8Power Tools for DOS',0
OptVerMsg:
    DB 'Version 07/31/2017',0
OptCopyMsg:
    DB 'Copyright (C) 2017 Jerome Shidel',0
OptEmailMsg:
    DB 'mailto:V8Power@LoopZ.org',0
OptURLMsg:
    DB 'https://github.com/LoopZ/V8Power',0
OptLicMsg:
    DB "This program is free software; you can redistribute it and/or modify",CRLF
    DB "it under the terms of the GNU General Public License as published by",CRLF
    DB "the Free Software Foundation; either version 2 of the License, or",CRLF
    DB "(at your option) any later version.",CRLF
    DB CRLF
    DB "This program is distributed in the hope that it will be useful,",CRLF
    DB "but WITHOUT ANY WARRANTY; without even the implied warranty of",CRLF
    DB "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the",CRLF
    DB "GNU General Public License for more details.",CRLF
    DB CRLF
    DB "You should have received a copy of the GNU General Public License along",CRLF
    DB "with this program; if not, write to the Free Software Foundation, Inc.,",CRLF
    DB "51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.",CRLF
    DB 0
