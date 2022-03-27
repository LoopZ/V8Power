; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

MainProgram:
    mov     al, [CursorSet]
    cmp     al, 1
    je      .Done
    mov     ax, [CursorShape]
    StdOutHexWord
    StdOutCRLF
.Done:
    mov         ah, 0x01
    mov         cx, [CursorShape]
    int         0x10
    Terminate 0

    LookupParamProc
    NUmberParamProc

NoSwitch:
    push        es
    LookupParam CursorStyles
    cmp         ax, 0xffff
    jne         .Found
    NumberParam

    jmp         .Done
.Found:
    cmp         ax, 1
    jne         .NotHide
    mov         ax, 0x2000
    jmp         .Done
.NotHide:
    mov         bx, 0x0040
    mov         es, bx
    mov         cl, [es:0x0085]
    cmp         ax, 2
    jne         .NotSmall
    mov         al, cl
    mov         ah, al
    sub         ah, 2
    jmp         .Done
.NotSmall:
    cmp         ax, 3
    jne         .NotHalf
    mov         al, cl
    mov         ah, al
    shr         ah, 1
    jmp         .Done
.NotHalf:
    mov         al, cl
    mov         ah, 0
.Done:
    pop         es
    mov         [CursorShape], ax
    mov         al, 1
    mov         [CursorSet], al
    ret

    HelpSwitchHandler 'vcursor'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    HelpSwitchData
    SwitchData  0,  0, 0

CursorStyles:
    db "HIDE",0,1,0
    db "SMALL",0,2,0
    db "HALF",0,3,0
    db "FULL",0,4,0
    db  0, 0xff, 0xff

CursorSet:
    db 0