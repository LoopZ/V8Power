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

; NASM 2.14rc0

%imacro HelpSwitchHandler 0-1 ''
SwitchHelp:
%ifidni %1, ''
    ;%ifdef NoVideoOutput
        StdOutStr   %%NoHelpMessage
    ;%else
    ;    WriteStr 	%%NoHelpMessage
    ;%endif
        jmp  %%Done
    %%NoHelpMessage:
	    DB 'See V8Power Tools docs.',0
%else
        ; set filename based on env strings and program
        SearchEnv   %%EnvHelp
        jc          %%HelpNotSet
        mov         di, PSP_CMDLEN
        call        %%CopyStr
        mov         al, '\'
        cs          stosb
        push cs
        pop  ds
        mov         si, %%UtilName
        call        %%CopyStr
        mov         al, '.'
        cs          stosb
        SearchEnv   %%EnvLang
        jnc          %%CopyLang
        push cs
        pop  ds
        mov         si, %%DefLang
    %%CopyLang:
        call        %%CopyStr
        push cs
        pop  ds
        xor         al, al
        stosb
        mov         ax, 0x3d00
        mov         dx, PSP_CMDLEN
        int         0x21
        jnc         %%FileOpened
    %%ChangeExt:
        mov         al, [di]
        cmp         al, '.'
        je          %%ExtFound
        dec         di
        jmp         %%ChangeExt
    %%ExtFound:
        inc         di
        mov         si, %%DefLang
        call        %%CopyStr
        xor         al, al
        stosb
        mov         ax, 0x3d00
        int         0x21
        jnc         %%FileOpened

        StdOutStr   PSP_CMDLEN
        StdOutStr   %%HelpMissing
        jmp         %%Done


    %%FileOpened:
        mov         bx, ax
        mov         cx, 0x100 - PSP_CMDLEN - 1
        ; mov         dx, PSP_CMDLEN
    %%ReadLoop:
        mov         ah, 0x3f
        int         0x21
        jc          %%ReadDone
        push        dx
        mov         si, dx
    %%PrintLoop:
        cmp         ax, 0
        je          %%PrintDone
        mov         dl, [si]
        inc         si
        dec         ax
        push        ax
        mov         ah, 0x02
        int         0x21
        pop         ax
        jmp         %%PrintLoop
    %%PrintDone:
        pop         dx
        cmp         si, dx
        jne         %%ReadLoop
    %%ReadDone:
        mov         ah, 0x3e
        int         0x21
        jmp  %%Done

    %%HelpNotSet:
        push cs
        pop  ds
        StdOutStr   %%EnvHelp
        StdOutStr   %%EnvHelpNotSet
        jmp  %%Done
    %%CopyStr:
        cld
        lodsb
        cmp    al, 0
        retz
        cs      stosb
        jmp     %%CopyStr

    %%EnvHelpNotSet:
        DB ' environment variable is not set.',0
    %%HelpMissing:
        DB ' file not found.',0
    %%EnvHelp:
        DB 'HELPPATH',0
    %%EnvLang:
        DB 'LANG',0
    %%UtilName:
        DB %1,0
    %%DefLang:
        DB 'en',0
%endif

    %%CRLFString:
        DB CRLF,0

%%Done:
        push cs
        pop  ds
        StdOutStr   %%CRLFString
        Terminate   0

%endmacro