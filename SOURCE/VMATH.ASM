; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput
; %idefine Bit64

%include "COMMON.INC"

    %idefine SwitchChar '^'

    CommandLineParser       ; insert code for command line parsing

; Include 64-bit number math for 8086
%ifdef Bit64
    jmp  Start
    %include "INT64.INC"
Start:
; %endif

; Int64 development and testing
;    uInt64_StdOutHex N1
    uInt64_MOV       N3, N2
    sInt64_ABS	     N3
    uInt64_StdOutHex N2
    StdOutCRLF
    uInt64_StdOutInt N2
    StdOutCRLF
    sInt64_StdOutHex N3
    StdOutCRLF
    sInt64_StdOutInt N3
    StdOutCRLF

    mov  cx, 10
OutLoop:
    push cx
    sInt64_DEC	N4
    sInt64_StdOutInt N4
    StdOutCRLF
    pop  cx
    loop OutLoop
    jmp Done

N1:
    dq		0x123456789abcdef0
N2:
    dq  -0x10000
    dq		-123456789123456789
N3:
    dq 0
N4:
    dq 0x7

; end test area
%endif

    mov     al, [OutStyle]
    cmp     al, 1
    je      OutHex
    StdOutIntWord [OutResult]
    jmp     Done
OutHex:
    mov     ax, [OutResult]
    StdOutHexWord
Done:
    StdOutCRLF
    Terminate 0

ClearLastOpt:
    mov     ax, OptNone
    mov     [LastOpt], ax
    ret

OptNone:
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptPlus:
    mov     cx, [OutResult]
    add     cx, ax
    mov     [OutResult], cx
    jmp     ClearLastOpt

OptMinus:
    mov     cx, [OutResult]
    sub     cx, ax
    mov     [OutResult], cx
    jmp     ClearLastOpt

OptMultiply:
    xor     dx, dx
    mov     cx, [OutResult]
    mul     cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptDivide:
    xor     dx, dx
    mov     cx, [OutResult]
    xchg    ax, cx
    div     cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptMod:
    xor     dx, dx
    mov     cx, [OutResult]
    xchg    ax, cx
    div     cx
    mov     [OutResult], dx
    jmp     ClearLastOpt

OptShr:
    xor     dx, dx
    mov     cx, [OutResult]
    xchg    ax, cx
    shr     ax, cl
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptShl:
    xor     dx, dx
    mov     cx, [OutResult]
    xchg    ax, cx
    shl     ax, cl
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptAnd:
    xor     dx, dx
    mov     cx, [OutResult]
    and     ax, cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptOr:
    xor     dx, dx
    mov     cx, [OutResult]
    or      ax, cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

OptXor:
    xor     dx, dx
    mov     cx, [OutResult]
    xor     ax, cx
    mov     [OutResult], ax
    jmp     ClearLastOpt

RealSwitches:

SwitchH:
    mov     al, 1
    mov     [OutStyle], al
    ret

SwitchD:
    mov     al, 0
    mov     [OutStyle], al
    ret

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    cmp         ax, RealSwitches
    jl          .NotSwitch
    jmp         ax
.NotSwitch:
    mov         [LastOpt], ax
    ret

.NotOption:
    NumberParam
    jmp         [LastOpt]

.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

LastOpt:
    dw OptNone

OutResult:
    dw 0

OutStyle:
    db 0

    HelpSwitchHandler 'vmath'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  0,  0, 0

OptionsTable:

    TableData '/H', SwitchH
    TableData '/D', SwitchD
    TableData '/?', SwitchHelp
    TableData 'ADD', OptPlus
    TableData '+', OptPlus
    TableData 'ADD', OptPlus
    TableData '-', OptMinus
    TableData 'SUB', OptMinus
    TableData '*', OptMultiply
    TableData 'MUL', OptMultiply
    TableData '/', OptDivide
    TableData 'DIV', OptDivide
    TableData '\', OptMod
    TableData 'MOD', OptMod
    TableData 'SHR', OptShr
    TableData 'SHL', OptShl
    TableData 'AND', OptAnd
    TableData 'OR', OptOr
    TableData 'XOR', OptXor
    TableEnd
