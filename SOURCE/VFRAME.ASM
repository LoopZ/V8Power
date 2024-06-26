; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%undef DEBUG

%include "COMMON.INC"

ProgramMain:

    SetMaxSize

MainParsing:

    CommandLineParser       ; insert code for command line parsing

    mov         al, [BoxOpt]
    cmp         al, 1
    jne         NotOptionBox
    call        MakeBoxOption

    mov         al, [BoxPad]
    cmp         al, 0
    je          NotFrameless

    mov         ax, BoxPadding
    mov         [BoxStyle], ax
NotFrameless:
    call        DrawBox
    jmp         Done

NotOptionBox:
    mov         al, [BoxText]
    cmp         al, 0x00
    jne         DrawTextBox
    call        DrawBox
    jmp         Done

DrawTextBox:
    ; Outer Box
    mov         ax, [BoxStyle]
    push        ax
    mov         ax, BoxHidden
    mov         [BoxStyle], ax
    call        DrawBox
    pop         ax
    mov         [BoxStyle], ax
    ; Normal Box
DrawNormalTextBox:
    xor         al, al
    mov         [BoxShadow], al
    mov         al, [CurrentX]
    inc         al
    mov         [CurrentX], al
    mov         al, [CurrentW]
    cmp         al, 0x02
    jng         Done
    sub         al, 2
    mov         [CurrentW], al
    call        DrawBox
    xor         al, al
    mov         [BoxShadow], al
    mov         ax, BoxHidden
    mov         [BoxStyle], ax
    mov         ax, [CurrentXY]
    add         ax, 0x0101
    mov         [CurrentXY], ax
    mov         ax, [CurrentSize]
    cmp         ah, 0x02
    jng         Done
    cmp         al, 0x02
    jng         Done
    sub         ah, 2
    sub         al, 2
    mov         [CurrentSize], ax

    mov         al, [BoxPad]
    cmp         al, 1
    jne         .DrawLining

    mov         ax, BoxPadding
    mov         [BoxStyle], ax

.DrawLining:
    call        DrawBox

Done:
    Terminate 0

DrawBox:
    mov         cx, [CurrentXY]
    mov         [WindMin], cx
    mov         dx, [CurrentSize]
    cmp         dl, 1
    jg          .WidthOK
    mov         dl, 2
.WidthOK:
    cmp         dh, 1
    jg          .HeightOK
    mov         dh, 2
.HeightOK:
    mov         [CurrentSize], dx
    push        dx
    add         dx, cx
    mov         [WindMax], dx

    mov         al, [TextAttr]
    mov         [BoxAttr], al
    mov         di, [BoxStyle]

    ; Comment these to make padding visible (during debug & testing)
    cmp         di, BoxPadding
    je          .IsHidden

    ; Comment these to make hidden boxes visible (during debug & testing)
    cmp         di, BoxHidden
    jne         .NotHiddenBox
.IsHidden:
    mov         al, [TextAttr]
    %ifndef DEBUG
        and         al, 0xf0
        mov         ah, al
        mov         cl, 4
        shr         al, cl
        or          al, ah
    %endif
    mov         [BoxAttr], al
    cmp         di, BoxPadding
    je          .NotHiddenBox
    mov         di, BoxSingle
    mov         [BoxStyle], di
.NotHiddenBox:
    mov         dx, 0x0000
    GotoXY      dx
    pop         dx

    call        WriteRow
    mov         al, [BoxShadow]
    inc         al
    mov         [BoxShadow], al
    dec         dh
    add         di, 3
Vertical:
    dec         dh
    cmp         dh, 0
    je          LastRow
    push        dx
    WhereXY
    mov         dl, 0
    inc         dh
    GotoXY      dx
    pop         dx
    call        WriteRow
    jmp         Vertical
LastRow:
    push        dx
    WhereXY
    mov         dl, 0
    inc         dh
    GotoXY      dx
    pop         dx
    add         di, 3
    push        ax
    mov         al, [BoxOpt]
    cmp         al, 1
    pop         ax
    je          NoShadowRow

    call        WriteRow

ShadowRow:
    mov         al, [BoxShadow]
    cmp         al, 2
    jl          NoShadowRow
    mov         bx, [WindMin]
    mov         dx, [WindMax]
    mov         cl, dl
    sub         cl, bl
    xor         ch, ch
    sub         dh, bh
    mov         dl, 0x01
    call        ShadowChars

NoShadowRow:
    mov         dx, 0x0101
    GotoXY      dx
    ret

WriteRow:
    push        dx
    ; Left
    mov         ah, 0x09
    mov         al, [di]
    mov         bh, [VideoPage]
    mov         bl, [BoxAttr]
    mov         cx, 0x0001
    int         0x10
    ; Center
    WhereXY
    inc         dx
    GotoXY      dx
    pop         dx
    push        dx
    mov         ah, 0x09
    mov         al, [di+1]
    mov         bh, [VideoPage]
    cmp         al, 0x20
    mov         bl, [BoxAttr]
    jne         .NotCenter
    mov         bl, [TextAttr]
.NotCenter:
    xor         ch, ch
    mov         cl, dl
    sub         cl, 2
    int         0x10
    pop         dx
    push        dx
    push        dx
    WhereXY
    pop         cx
    mov         dl, cl
    dec         dl
    GotoXY      dx
    ; Right
    mov         ah, 0x09
    mov         al, [di+2]
    mov         bh, [VideoPage]
    mov         bl, [BoxAttr]
    mov         cx, 0x0001
    int         0x10
    mov         al, [BoxShadow]
    cmp         al, 2
    jl          .NoShadow
    inc         cx
    call        ShadowChars
.NoShadow:
    pop         dx
    ret

ShadowChars:
    mov         ax, [ScreenMax]
    mov         bx, [WindMin]
    add         dh, bh
    add         dl, bl
    inc         dl
.ShadowLoop:
    cmp         dl, al
    jg          .NoCanDo
    cmp         dh, ah
    jg          .NoCanDo
    push        ax
    push        bx
    push        cx
    push        dx
    mov         ah, 0x02
    mov         bh, [VideoPage]
    int         0x10
    mov         ah, 0x08
    int         0x10
    mov         ah, 0x09
    mov         bl, [ShadowAttr]
    mov         cx, 0x0001
    int         0x10
    pop         dx
    pop         cx
    pop         bx
    pop         ax
    inc         dl
    loop        .ShadowLoop
.NoCanDo:
    ret

NoSwitch:
    LookupParam BoxStyleTable
    cmp         ax, BoxShadow
    je          .SetShadow
    cmp         ax, 0xffff
    jne         .Found
    jmp         .NotBox
.Found:
    cmp         ax, BoxSingle
    je          .NormalBox
    cmp         ax, BoxDouble
    je          .NormalBox
    cmp         ax, BoxDoubleSides
    je          .NormalBox
    cmp         ax, BoxSingleSides
    je          .NormalBox
    cmp         ax, BoxText
    je          .BoxTextMode
    cmp         ax, BoxOption
    je          BoxOption
.NormalBox:
    mov         [BoxStyle], ax
    ret
.BoxTextMode:
    mov         al, 1
    mov         [BoxText], al
    ret
.SetShadow:
    mov         al, 1
    mov         [BoxShadow], al
    ret

.NotBox:

.Error:
    WriteStr    CommandLineErrorMsg
    Terminate   100

SwitchC:
    mov         ax, [WindMax]
    xor         dx, dx
    xor         ah, ah
    mov         cx, 2
    div         cx
    inc         ax
    xor         dx, dx
    push        ax
    mov         al, [CurrentW]
    div         cx
    pop         bx
    cmp         bx, ax
;   jge         .OkX
;   xor         bx, bx
;   xor         ax, ax
;.OkX:
    sub         bx, ax
    mov         [CurrentX], bl
    mov         ax, [WindMax]
    xor         dx, dx
    xor         al, al
    xchg        al, ah
    mov         cx, 2
    div         cx
    xor         dx, dx
    push        ax
    mov         al, [CurrentH]
    div         cx
    pop         bx
    cmp         bx, ax
    jge         .OkY
    xor         bx, bx
    xor         ax, ax
.OkY:
    sub         bx, ax
    mov         [CurrentY], bl
    ret

%include "TRANSLAT.INC"

SwitchT:
    Translator MainParsing

ColorSwitchHandlers
XYSwitchHandlers
SizeSwitchHandlers

BoxOption:
    mov         ax, BoxHidden
    mov         [BoxStyle], ax
    mov         al, 1
    mov         [BoxOpt], al
    ret

MakeBoxOption:
    mov				ah,0x03
    mov				bh, [VideoPage]
    int 			0x10
    ; Save it for later
    push			dx
.ScanDownLoop:
    mov				ah, 0x02
    int				0x10
    mov				ah, 0x08
    int				0x10
    cmp				al, 0xb3
    jb				.NotFrame
    cmp				al, 0xda
    ja				.NotFrame
    jmp             .Done
.NotFrame:
    cmp				dh, [ScreenMaxY]
    jae				.Done
    inc             dh
    jmp				.ScanDownLoop
.Done:
    mov             ch, [CurrentH]
    sub             dh, ch
    inc             dh
    mov             [CurrentY], dh

    pop				dx
    mov				ah, 0x02
    int				0x10
    ret

SwitchP:
    NumberParam

    push            di
    cld
    mov             di, BoxPadding
    stosb
    stosb
    stosb
    stosb
    inc             di
    stosb
    stosb
    stosb
    stosb
    mov             al, 1
    mov             [BoxPad], al
    pop             di
    ret


BoxSingle:          db 0xda,0xc4,0xbf,0xb3,0x20,0xb3,0xc0,0xc4,0xd9
BoxSingleSides:     db 0xd5,0xcd,0xb8,0xb3,0x20,0xb3,0xd4,0xcd,0xbe
BoxDoubleSides:     db 0xd6,0xc4,0xb7,0xba,0x20,0xba,0xd3,0xc4,0xbd
BoxDouble:          db 0xc9,0xcd,0xbb,0xba,0x20,0xba,0xc8,0xcd,0xbc
BoxPadding:         db 0x00,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x00

BoxHidden:          ; dummy address to trip modification

BoxStyle:
    dw  BoxDouble
BoxShown:
    db  0
BoxAttr:
    db  0
ShadowAttr:
    db  0x08
BoxShadow:
    db  0
BoxText:
    db  0
BoxPad:
    db  0
BoxOpt:
    db  0

BoxStyleTable:
    TableData "SHADOW",         BoxShadow
    TableData "HIDE",           BoxHidden
    TableData "HIDDEN",         BoxHidden
    TableData "SINGLE",         BoxSingle
    TableData "DOUBLE",         BoxDouble
    TableData "SINGLESIDES",    BoxSingleSides
    TableData "DOUBLESIDES",    BoxDoubleSides
    TableData "TEXTBOX",        BoxText
    TableData "OPTIONBOX",      BoxOption
    TableEnd

    HelpSwitchHandler 'vframe'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData 'C',  0, SwitchC
    SwitchData 'P', 1, SwitchP
    ColorSwitchData
    XYSwitchData
    SizeSwitchData
    HelpSwitchData
    SwitchData  'T', 1, SwitchT
    SwitchData  0,  0, 0
