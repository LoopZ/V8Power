; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%include "COMMON.INC"

    call  PrepareSettings

    CommandLineParser       ; insert code for command line parsing

    mov     al, [LineStyle]
    cmp     al, 0
    jne     .NotHidden
    mov     al, [TextAttr]
    and     al, 0xf0
    mov     ah, al
    mov     cl, 4
    shr     al, cl
    or      al, ah
    mov     [TextAttr], al

.NotHidden:
    xor     ch, ch
    mov     cl, [LineDir]
    cmp     cl, 1
    je      Vertical
    mov     cl, [CurrentW]
    cmp     cl, 0
    je      Vertical

Horizontal:
    mov     cl, [CurrentW]
    push    cx
    mov     bh, [VideoPage]
    mov     dx, [CurrentXY]
    mov     ax, [WindMin]
    add     dh, ah
    add     dl, al
    mov     ah, 0x02
    int     0x10
    mov     bl, [TextAttr]
    mov     ah, [BoxPad]
    test    ah, ah
    jnz     .PadChar
    mov     ah, [LineStyle]
    cmp     ah, 2
    je      .DoubleLine
    mov     al, 0xc4
    jmp     .CharSet
.PadChar:
    mov     al, [BoxPadChar]
    jmp     .CharSet
.DoubleLine:
    mov     al, 0xcd
.CharSet:
    mov     ah, 0x09
    int     0x10
    pop     cx
    mov     dx, [Position]
    xor     dl, dl
    inc     dh
    mov     cx, [ScreenMax]
    cmp     dh, ch
    jge     Done
    mov     [Position], dx
    jmp     Done

Vertical:
    mov     cl, [CurrentH]
    cmp     cl, 0
    je      Done

Done:
    mov     dx, [Position]
    GotoXY  dx
    Terminate 0

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    jmp         ax

.NotOption:
    NumberParam
    ; do something with ax

.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

PrepareSettings:
    FrameBounds

    SetMaxSize

    WhereXY
    mov     [CurrentXY], dx
    mov     [Position], dx
    xor     dl, dl
    GotoXY  dx
    xor     ax, ax
    mov     [CurrentH], al
    ret

ColorSwitchHandlers
XYSwitchHandlers
SizeSwitchHandlers

OptHidden:
    mov     al, 0
    mov     [LineStyle], al
    mov     [LineSmart], al
    ret
OptSingle:
    mov     al, 1
    mov     [LineStyle], al
    ret
OptDouble:
    mov     al, 2
    mov     [LineStyle], al
    ret
OptSmart:
    mov     al, 1
    mov     [LineSmart], al
    ret
OptDumb:
    mov     al, 0
    mov     [LineSmart], al
    ret
OptHorizontal:
    mov     al, 0
    mov     [LineDir], al
    ret
OptVertical:
    mov     al, 1
    mov     [LineDir], al
    ret

SwitchP:
    NumberParam
    mov             [BoxPadChar], al
    mov             al, 1
    mov             [BoxPad], al
    xor             al, al
    mov             [LineStyle], al
    ret

SwitchK:
    NumberParam
    mov         ah, 1
    mov         [BoundsChar], al
    mov         [UseBoundsChar], ah
    FrameBounds
    WhereXY
    mov     [CurrentXY], dx
    mov     [Position], dx
    xor     dl, dl
    GotoXY  dx
    xor     ax, ax
    mov     [CurrentH], al
    ret
    jmp         PrepareSettings

    HelpSwitchHandler 'vline'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData 'P', 1, SwitchP
    ColorSwitchData
    XYSwitchData
    SizeSwitchData
    BoundsSwitchData
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
    TableData "HIDE",           OptHidden
    TableData "HIDDEN",         OptHidden
    TableData "SINGLE",         OptSingle
    TableData "DOUBLE",         OptDouble
    TableData "SMART",          OptSmart
    TableData "DUMB",           OptDumb
    TableData "HORIZONTAL",     OptHorizontal
    TableData "VERTIVAL",       OptVertical
    TableData "HORZ",           OptHorizontal
    TableData "VERT",           OptVertical
    TableData "HOR",            OptHorizontal
    TableData "VER",            OptVertical
    TableEnd

BoxPad:
    db 0
BoxPadChar:
    db 0
Position:
    dw 0
LineStyle:
    db 1
LineSmart:
    db 1
LineDir:
    db 0