; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%include "COMMON.INC"

    FrameBounds

    CommandLineParser       ; insert code for command line parsing

    WhereXY
    mov     [Position], dx
    xor     dl, dl
    GotoXY  dx
    xor     ax, ax

Scrolling:
    mov         cx, [WindMin]
    mov         dx, [Position]
    add         ch, dh
    mov         dx, [WindMax]
    mov         ax, 0x0701
    mov         bh, [TextAttr]
    int         0x10
    mov         cx, [Lines]
    cmp         cx, 0x0001
    jna         Done
    dec         cx
    mov         [Lines], cx
    jmp         Scrolling

Done:
    mov     dx, [Position]
    GotoXY  dx
    Terminate 0

NoSwitch:
;    LookupParam OptionsTable
;    cmp         ax, 0xffff
;    je          .NotOption
;    jmp         ax

;.NotOption:
    NumberParam
    ; do something with ax
    mov  [Lines], ax
    ret

.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

ColorSwitchHandlers
LocalSwitchHandlers
HelpSwitchHandler 'vinsert'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    ColorSwitchData
    LocalSwitchData
    HelpSwitchData
    SwitchData  0,  0, 0

Position:
    dw 0
Lines:
    dw 0
