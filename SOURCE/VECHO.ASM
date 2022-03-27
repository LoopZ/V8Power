; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%include "COMMON.INC"

    FrameBounds

MainParsing:

    CommandLineParser       ; insert code for command line parsing

    UseAdvancedStdIn

    mov         al, [NoNewLine]
    cmp         al, 0
    jne         Done
    mov         cx, [Repeat]
ReturnLoop:
    push        cx
    WriteStr    CRLFString
    pop         cx
    loop        ReturnLoop
Done:
    Terminate   0

NoSwitch:
    xor         al, al
    mov         [si], al
    mov         cx, [Repeat]
.SwitchLoop:
    push        cx
    push        di
    mov         al, [Squeeze]
    cmp         al, 1
    jne         .NoSpace
    mov         al, [SqueezeFlag]
    cmp         al, 1
    jne         .NoSpace
    push         di
    mov         al, 0x20
    WriteChar   0x09
    pop         di
.NoSpace:
    WriteStr    di
    mov         al, 1
    mov         [SqueezeFlag], al
    pop         di
    pop         cx
    loop        .SwitchLoop
    inc         cx
    mov         [Repeat], cx
    ret

SwitchN:
    mov         al, 1
    mov         [NoNewLine], al
    ret

SwitchS:
    mov         al, [di]
    mov         ah, 0
    cmp         al, '-'
    je          .SetSqueeze
    mov         ah, 1
    cmp         al, '+'
    jne         .Error
.SetSqueeze:
    mov         [Squeeze], ah
    ret
.Error:
    WriteStr    CommandLineErrorMsg
	Terminate   100


SwitchC:
    NumberParam
    mov         cx, [Repeat]
.SwitchLoop:
    push        cx
    WriteChar
    pop         cx
    loop        .SwitchLoop
    inc         cx
    mov         [Repeat], cx
    ret

SwitchI:
    WriteStdIn
    ret

SwitchR:
    NumberParam
    mov         [Repeat], ax
    ret

SwitchE:
    mov         ax, 0x20
    jmp         FillLine

SwitchX:
    NumberParam

FillLine:
    push        ax
    WhereXY
    pop         ax
    mov         cl, [WindMaxX]
    sub         cl, [WindMinX]
    inc         cl
    sub         cl, dl
    xor         ch, ch
    cmp         cx, 0
    je          .Done
.Fill:
    mov         ah, 0x09
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    int         0x10
.Done:
    ret

    ColorSwitchHandlers

    LocalSwitchHandlers

%include "TRANSLAT.INC"

SwitchT:
    Translator  MainParsing

SwitchP:
    WriteStr    CRLFString
    mov         al, 0
    mov         [SqueezeFlag], al
    ret

    HelpSwitchHandler 'vecho'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    ColorSwitchData
    SwitchData  'N', 0, SwitchN
    SwitchData  'C', 1, SwitchC
    SwitchData  'R', 1, SwitchR
    SwitchData  'I', 0, SwitchI
    SwitchData  'E', 0, SwitchE
    SwitchData  'X', 1, SwitchX
    SwitchData  'T', 1, SwitchT
    SwitchData  'P', 0, SwitchP
    SwitchData  'S', 1, SwitchS
    LocalSwitchData
    HelpSwitchData
    SwitchData  0,  0, 0

Repeat:
    dw 1
NoNewLine:
    db 0
Squeeze:
    db 1
SqueezeFlag:
    db 0

