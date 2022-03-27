; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

; common code for command line switches

%include "V8-HELP.INC"


%imacro ColorSwitchHandlers 0
SwitchA:
    NumberParam
    mov         [TextAttr], al
    ret

SwitchColor:
    LookupParam ColorTable
    cmp         ax, 0xffff
    jne         .Found
    NumberParam
.Found:
    ret

SwitchF:
    call        SwitchColor
    cmp			ax, 0x000f
    ja 			SwitchError
    mov         ah, [TextAttr]
    and         ah, 0xf0
    or          ah, al
    mov         [TextAttr], ah
    ret

SwitchB:
    call        SwitchColor
    cmp			ax, 0x0007
    ja 			BlinkOnOff

    mov         ah, [TextAttr]
    mov         cl, 4
    shl         al, cl
    and         ah, 0x0f
    or          ah, al
    mov         [TextAttr], ah
    ret

BlinkOnOff:
	cmp			ax, 0x8000
	je			BlinkOff
	cmp			ax, 0x8001
	je			BlinkOn
	jmp			SwitchError

BlinkOn:
    mov         ah, [TextAttr]
	or			ah, 0x80
    mov         [TextAttr], ah
	ret

BlinkOff:
    mov         ah, [TextAttr]
	and			ah, 0x7f
    mov         [TextAttr], ah
	ret


    ColorTableData      ; insert color name table

%endmacro

%imacro SwitchData 3
    db          %1
    db          %2
    dw          %3
%endmacro

%imacro ColorSwitchData 0
    SwitchData 'A', 1, SwitchA
    SwitchData 'F', 1, SwitchF
    SwitchData 'B', 1, SwitchB
%endmacro

%imacro XYSwitchHandlers 0
SwitchX:
    NumberParam
    dec         al
    mov         [CurrentX], al
    ret

SwitchY:
    call        NumberParam
    dec         al
    mov         [CurrentY], al
    ret

CurrentXY:
    CurrentX:   DB 0
    CurrentY:   DB 0
%endmacro

%imacro SizeSwitchHandlers 0
SwitchW:
    NumberParam
    mov         [CurrentW], al
    ret

SwitchH:
    NumberParam
    mov         [CurrentH], al
    ret

CurrentSize:
    CurrentW:   DB 80
    CurrentH:   DB 25
%endmacro

%imacro SetMaxSize 0
    push        ax
    push        bx
    mov         ax, [WindMax]
    mov         bx, [WindMin]
    sub         ah, bh
    sub         al, bl
    inc         ah
    inc         al
    mov         [CurrentSize], ax
    pop         bx
    pop         ax
%endmacro

%imacro BoundsSwitchHandler 0
    SwitchK:
        NumberParam
        mov         ah, 1
        mov         [BoundsChar], al
        mov         [UseBoundsChar], ah
        FrameBounds
        ret
%endmacro

%imacro LocalSwitchHandlers 0
    SwitchK:
        NumberParam
        mov         ah, 1
        mov         [BoundsChar], al
        mov         [UseBoundsChar], ah
    SwitchL:
        FrameBounds
        ret
    SwitchG:
        mov     ax, 0x0000
        mov     [WindMin], ax
        mov     ax, [ScreenMax]
        mov     [WindMax], ax
        ret
%endmacro

%imacro XYSwitchData 0
    SwitchData 'X', 1, SwitchX
    SwitchData 'Y', 1, SwitchY
%endmacro

%imacro SizeSwitchData 0
    SwitchData  'W', 1, SwitchW
    SwitchData  'H', 1, SwitchH
%endmacro

%imacro BoundsSwitchData 0
    SwitchData 'K', 1, SwitchK
%endmacro

%imacro LocalSwitchData 0
    SwitchData 'L', 0, SwitchL
    SwitchData 'G', 0, SwitchG
    BoundsSwitchData
%endmacro

%imacro HelpSwitchData 0
    SwitchData '?', 0, SwitchHelp
%endmacro

