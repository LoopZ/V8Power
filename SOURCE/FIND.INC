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

; NASM 2.14rc0 for DOS

; %1 FILE, %2 DIR, AX = 0 As is, 1-3 + extension, 0xffff not found.
%imacro FindExecInDir 2
    %ifndef FindExecInDirProc_Declared
        %idefine FindExecInDirProc_Declared
            jmp     %%Over
        FindFirstMatchFileProc:
            push        ax
            push        cx
            push        dx
            ; StdOutChar  "?"
            ; StdOutStr   DATABLOCK(SEARCHNAME)
            ; StdOutCRLF
            mov         dx, DATABLOCK(DTA)
            mov         ah, 0x1a
            int         0x21
            mov         ah, 0x4e
            mov         cx, 00100111b
            mov         dx, DATABLOCK(SEARCHNAME)
            int         0x21
            pop         dx
            pop         cx
            pop         ax
            ret
        CopyAB:
            cld
        .RepeatA:
            lodsb
            stosb
            cmp         al, 0
            jne         .RepeatA
            dec         di
            xor         ah, ah
            mov         si, bx
        .RepeatB:
            lodsb
            stosb
            cmp         al, '.'
            jne         .NotDot
            mov         ah, al
        .NotDot:
            cmp         al, 0
            jne         .RepeatB
            push        ax
            mov         si, DATABLOCK(SEARCHNAME)
            mov         di, si
        .CaseLoop:
            lodsb
            cmp         al, 0x61
            jb          .CaseOK
            cmp         al, 0x7a
            ja          .CaseOK
            sub         al, 0x20
        .CaseOK:
            stosb
            cmp         al, 0
            jne         .CaseLoop
            pop         ax
            ret

        FindExecExt:
            db '.COM',0
            db '.EXE',0
            db '.BAT',0
        FindExecInDirProc:
            push        dx
            push        di
            mov         di, DATABLOCK(SEARCHNAME)
            mov         dx, di
            call        CopyAB
            cmp         ah, 0x00
            jne         .ExactOnly
        .TryAll:
            xor         ax, ax
            mov         bx, di
            dec         bx
            mov         si, FindExecExt
            call        .WithExtension
            jnc         .Done
            call        .WithExtension
            jnc         .Done
            call        .WithExtension
            jnc         .Done
            mov         ax, 0xffff
            jmp         .Done
            jmp         .ExactOnly
        .WithExtension:
            mov         di, bx
            inc         ax
            push        ax
        .CopyExt:
            lodsb
            stosb
            cmp         al, 0
            jne         .CopyExt
            pop         ax
            call        FindFirstMatchFileProc
            ret
        .ExactOnly:
            mov         ax, 0xffff
            call        FindFirstMatchFileProc
            jc          .Done
            xor         ax, ax
        .Done:
            pop         di
            pop         dx
            ret
        %%Over:
    %endif
    push        si
    push        bx
    mov         bx, %1
    mov         si, %2
    call        FindExecInDirProc
    pop         bx
    pop         si
%endmacro

; %1 FILE, %2 Output
%imacro FindExec 2
    %ifndef FindExecProc_Declared
        %idefine FindExecProc_Declared
            jmp         %%Over
        %%PathEnvVarName:
            db          'PATH',0

        GetCurrentDir:
            push        di
            push        si
            push        dx
            cmp         al, 0x00
            jne         %%SkipCurDisk
            mov         ah, 0x19
            int         0x21    ; Get Current Disk
            inc         al
        %%SkipCurDisk:
            xor         dh, dh
            mov         dl, al
            add         al, 0x40
            mov         si, DATABLOCK(SEARCHPATH)
            mov         [si], al
            mov         ax, 0x5c3a
            mov         [si + 1], ax
            add         si, 3
            mov         [si], dh
            mov         ah, 0x47
            int         0x21    ; Get Current Working Directory
            jc          %%DriveLetterError
            lodsb
            cmp         al, 0
            je          %%NoAddSlash
        %%AddSlash:
            lodsb
            cmp         al, 0
            jne         %%AddSlash
            mov         ax, 0x005c
            mov         [si - 1], ax
            jmp         %%NoAddSlash
        %%DriveLetterError:
            mov         si, DATABLOCK(SEARCHPATH)
            mov         [si], dh
        %%NoAddSlash:
            pop         dx
            pop         si
            pop         di
        ret

        FindExecProc:
        ; Null Result now.
            xor         ah, ah
            mov         [di], ah

        ; Test if Filename includes relative path
            cld
            push        si
            xor         bx, bx
            xor         ah, ah
        %%RelativeTestLoop:
            lodsb
            inc         ah
            cmp         al, ':'
            jne         %%NotColon
            cmp         bh, 0x00
            jne         %%NotColon
            mov         bh, ah
        %%NotColon:
            cmp         al, '\'
            jne         %%NotSlash
            mov         bl, ah
        %%NotSlash:
            cmp         al, 0x00
            jne         %%RelativeTestLoop
            pop         si
            mov         [DATABLOCK(RELATIVE)], bx

        ; Check Current Working Directory
        ; Convert to CWD/Relative Path
            xor         al, al
            call        GetCurrentDir
            jc          %%Error

            push        si
            push        cx
            push        di
            mov         cx, [DATABLOCK(RELATIVE)]
            cmp         cx, 0x0000
            je          %%SearchCWD

        ; Check if drive is specified
            cmp         ch, 0x02
            jne         %%NoColon
            mov         al, [si]
            sub         al, 0x40
            cmp         al, 0x20
            jna         %%SkipCaseAdj
            sub         al, 0x20
        %%SkipCaseAdj:
            call        GetCurrentDir
        %%NoColon:
        ; Check if Root is specified
            xor         bx, bx
            mov         bl, ch
            mov         al, [si + bx]
            cmp         al, '\'
            jne         %%NotRootDir
            mov         [DATABLOCK(SEARCHPATH) + bx + 1], bh
            inc         bx
        %%NotRootDir:
        ; Clone relative path
            cmp         cl, 0x00
            je          %%SkipClone
            push        di
            mov         di, DATABLOCK(SEARCHPATH)
        %%FindEnd:
            mov         ah, [di]
            cmp         ah, 0x00
            je          %%FoundEnd
            inc         di
            jmp         %%FindEnd
        %%FoundEnd:
            cmp         cl, ch
            jae         %%CloneRelative
            mov         cl, ch
        %%CloneRelative:
            cmp         bl, cl
            jae         %%CloneDone
            mov         al, [si + bx]
        ; .. Walking up to parent directory
            cmp         al, '.'
            jne         %%NoWalkUp
            mov         dx, [si + bx + 1]
            cmp         dx, '.\'
            jne         %%NoWalkUp
            add         bx, 3
        %%Walking:
            cmp         di, DATABLOCK(SEARCHPATH) + 0x03
            jna         %%CloneRelative
            dec         di
            mov         al, [di - 1]
            cmp         al, '\'
            je          %%CloneRelative
            jmp         %%Walking
        %%NoWalkUp:
            mov         [di], ax
            inc         di
            inc         bl
            jmp         %%CloneRelative
        %%CloneDone:
            mov        [di], ah
            pop         di
        %%SkipClone:

        ; Set RELNAME to Filename part of relative name
            mov         di, DATABLOCK(RELNAME)
        ;    xor         bx, bx
            cmp         cl, ch
            jae         %%HighValSet
            mov         cl, ch
        %%HighValSet:
            mov         bl, cl
            push        si
            add         si, bx
        %%CopyRelName:
            lodsb
            stosb
            cmp         al, 0x00
            jne         %%CopyRelName
            pop         si
            mov         si, DATABLOCK(RELNAME)

        %%SearchCWD:
            pop         di
            pop         cx
            FindExecInDir si, DATABLOCK(SEARCHPATH)
            pop         si

        ; Temporary Always Match for Search Parsing Tests
        ;    je          %%FoundInPath

            cmp         ax, 0xffff
            jne         %%FoundInPath
            mov         bx, [DATABLOCK(RELATIVE)]
            cmp         bx, 0x0000
            je          %%FetchPathEnv
            jmp         %%Done

        %%FetchPathEnv:
        ; Find the PATH environment directories
            mov         bx, si
            push        ds
            SearchEnv   %%PathEnvVarName
            push        ds  ; mov es, ds
            pop         es
            pop         ds
            jc          %%PathNotSet
            jmp         %%CheckPath
        %%PathNotSet:
        ; Display Path Not Set Message?
            jmp         %%Done

        %%CheckPath:
            push        di
            mov         di, DATABLOCK(SEARCHPATH)
        %%CopyPath:
            mov         al, [es:si]
            inc         si
            cmp         al, ';'
            je          %%EndPathItem
            cmp         al, 0x00
            je          %%EndPathItem
            mov         [ds:di], al
            inc         di
            jmp         %%CopyPath
        %%EndPathItem:
            mov         cl, al
            xor         al, al
            mov         [ds:di], al
            cmp         di, DATABLOCK(SEARCHPATH)
            je          %%NullItem
            mov         ax, [ds:di -1]
            cmp         ax, 0x005c
            je          %%HasSlash
            mov         ax, 0x005c
            mov         [ds:di], ax
        %%HasSlash:
            push        cx
            push        si
            push        es
            push        ds ; mov es, ds
            pop         es
            FindExecInDir bx, DATABLOCK(SEARCHPATH)
            pop         es
            pop         si
            pop         cx
            cmp         ax, 0xffff
            je          %%NullItem
            mov         ch, al
            pop         di
            jmp         %%Found
        %%NullItem:
            pop         di
            cmp         cl, 0x0
            jne         %%CheckPath
            jmp         %%Done
        %%FoundInPath:
        %%Found:
            push        ds
            pop         es
            mov         si, DATABLOCK(SEARCHNAME)
        %%CopyName:
            lodsb
            stosb
            cmp         al, 0
            jne         %%CopyName
            jmp         %%Done
        %%Error:
        %%Done:
            push        ds
            pop         es
            ret
        %%Over:
    %endif

    push        di
    push        si
    mov         si, %1
    mov         di, %2
    call        FindExecProc
    pop         si
    pop         di

%endmacro

; %1 Output
%imacro FindComspec 1
    jmp         %%Over
%%COMSPEC:
    db 'COMSPEC',0
%%COMMAND:
    db 'COMMAND.COM',0
%%Over:
    push        ds
    mov         di, %1
    SearchEnv   %%COMSPEC
    jc          %%NotFound
    cld
    mov         cx, 127
%%CopyEnv:
    lodsb
    cmp         al, 0x00
    je          %%EnvCopied
    cs stosb
    cmp         al, 0x20
    je          %%EnvCopied
    loop        %%CopyEnv
%%EnvCopied:
    xor         al, al
    cs stosb
    jmp         %%Done
%%NotFound:
    xor         al, al
    cs stosb
    push        cs
    pop         ds
    FindExec    %%COMMAND, %1
    ; Not found display COMMAND.COM not found?
%%Done:
    pop         ds

%endmacro
