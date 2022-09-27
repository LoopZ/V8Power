; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

;%idefine Bit64
;%idefine DevBit64

%include "COMMON.INC"

    %idefine SwitchChar '^'

    CommandLineParser       ; insert code for command line parsing

; Include 64-bit number math for 8086
%ifdef Bit64
    %include "INT64.INC"
%endif
%ifdef DevBit64

; Int64 development and testing
    mov  cx, 70
    clc
OutLoop1:
    push cx
    uInt64_ROR		N0, 1
    pushf
    sInt64_StdOutBin 	N0
    StdOutCRLF
    call  SlowDown
    popf
    pop  cx
    loop OutLoop1
    jmp Done

SlowDown:
   pushf
   push cx
   mov  cx, 2
.WaitLoop:
   hlt
   loop  .WaitLoop
   pop  cx
   popf
   ret

N0:
   dq 1
N1:
   dq 0x100000


; end test area
%endif
; -----------------------------------------------------------------------------
%ifndef Bit64
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

OutResult:
    dw 0
%else

; -----------------------------------------------------------------------------
    mov     al, [OutStyle]
    cmp     al, 1
    je      OutHex
    sInt64_StdOutInt 	OutResult
    jmp     Done
OutHex:
    StdOutChar		'0'
    StdOutChar		'x'
    sInt64_StdOutHex 	OutResult
Done:
    StdOutCRLF
    Terminate 0

ClearLastOpt:
    mov     ax, OptNone
    mov     [LastOpt], ax
    ret

OptNone:
    sInt64_MOV     OutResult, TempVal
    jmp     ClearLastOpt

OptPlus:
    sInt64_ADD     OutResult, TempVal
    jc	    OverFlowError
    jmp     ClearLastOpt

OptMinus:
    sInt64_SUB     OutResult, TempVal
    jc	    OverFlowError
    jmp     ClearLastOpt

OptMultiply:
    ;xor     dx, dx
    ;mov     cx, [OutResult]
    ;mul     cx
    ;mov     [OutResult], ax
    jmp     ClearLastOpt

OptDivide:
    sInt64_DIV OutResult, TempVal ; out Quotient, Remainder
    jc	    OverFlowError
    jmp     ClearLastOpt

OptMod:
    sInt64_DIV OutResult, TempVal
    sInt64_MOV OutResult, TempVal ; mov Remainder into result
    jc	    OverFlowError
    jmp     ClearLastOpt

OptShr:
    ;xor     dx, dx
    ;mov     cx, [OutResult]
    ;xchg    ax, cx
    ;shr     ax, cl
    ;mov     [OutResult], ax
    jmp     ClearLastOpt

OptShl:
    ;xor     dx, dx
    ;mov     cx, [OutResult]
    ;xchg    ax, cx
    ;shl     ax, cl
    ;mov     [OutResult], ax
    jmp     ClearLastOpt

OptAnd:
    ;xor     dx, dx
    ;mov     cx, [OutResult]
    ;and     ax, cx
    ;mov     [OutResult], ax
    jmp     ClearLastOpt

OptOr:
    ;xor     dx, dx
    ;mov     cx, [OutResult]
    ;or      ax, cx
    ;mov     [OutResult], ax
    jmp     ClearLastOpt

OptXor:
    ;xor     dx, dx
    ;mov     cx, [OutResult]
    ;xor     ax, cx
    ;mov     [OutResult], ax
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
    Ascii_uInt64   TempVal, di
    jc 		   .InvalidOption
    jmp         [LastOpt]

.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

OverFlowError:
    WriteStr    OverFlowErrorMessage
    Terminate   100

OverFlowErrorMessage:
  db 'overflow error',CRLF,0

Int64_Procs

OutResult:
    dq 0
TempVal:
    dq 0
%endif
; -----------------------------------------------------------------------------
LastOpt:
    dw OptNone

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
