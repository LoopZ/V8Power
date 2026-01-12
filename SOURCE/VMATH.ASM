; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%idefine Bit64

%include "COMMON.INC"

    %idefine SwitchChar '^'

    CommandLineParser       ; insert code for command line parsing

; Include 64-bit integer math for 8086
%ifdef Bit64
    %include "INT64.INC"
%endif

Main:
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

SwitchB:
    ret

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
    ja      OutBin
    sInt64_StdOutInt 	OutResult
    jmp     Done
OutHex:
    StdOutChar		'0'
    StdOutChar		'x'
    sIntFlex_StdOutHex 	OutResult
    jmp     Done
OutBin:
    sIntFlex_StdOutBin 	OutResult
Done:
    StdOutCRLF
    Terminate 0

ClearLastOpt:
    mov     ax, OptNone
    mov     [LastOpt], ax
    ret

OptNone:
    test    [NeedOpt], byte 1
    jnz	    NoOptError
    mov	    [NeedOpt], byte 1
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
    sInt64_MUL OutResult, TempVal
    jc	    OverFlowError
    jmp     ClearLastOpt

OptDivide:
    sInt64_DIV OutResult, TempVal ; out Quotient, Remainder
    jc	    DivZeroError
    jmp     ClearLastOpt

OptMod:
    sInt64_DIV OutResult, TempVal
    sInt64_MOV OutResult, TempVal ; mov Remainder into result
    jc	    DivZeroError
    jmp     ClearLastOpt

OptShr:
    mov      cx, [TempVal]
    sInt64_SHR OutResult, cx
    jmp     ClearLastOpt

OptShl:
    mov      cx, [TempVal]
    sInt64_SHL OutResult, cx
    jmp     ClearLastOpt

OptAnd:
    sInt64_AND OutResult, TempVal
    jmp     ClearLastOpt

OptOr:
    sInt64_OR OutResult, TempVal
    jmp     ClearLastOpt

OptXor:
    sInt64_XOR OutResult, TempVal
    jmp     ClearLastOpt

RealSwitches:

SwitchB:
    mov     al, 2
    mov     [OutStyle], al
    ret

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
    mov		si,CommandLineErrorMsg
DieNow:
    WriteStr	si
    WriteStr    ErrorMessage
    Terminate   100

OverFlowError:
    mov		si,OverFlowErrorMessage
    jmp		DieNow

DivZeroError:
    mov		si,DivZeroErrorMessage
    jmp		DieNow

NoOptError:
    mov		si, NoOptErrorMessage
    jmp		DieNow


OverFlowErrorMessage:
  db 'overflow',0

NoOptErrorMessage:
  db 'no operator',0

DivZeroErrorMessage:
  db 'divide by zero',0

ErrorMessage:
  db ' error',CRLF,0

Int64_Procs

OutResult:
    dq 0
TempVal:
    dq 0
%endif
; -----------------------------------------------------------------------------
LastOpt:
    dw OptNone

NeedOpt:
    db 0

OutStyle:
    db 0

    HelpSwitchHandler 'vmath'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  0,  0, 0

OptionsTable:

    TableData '/B', SwitchB
    TableData '/H', SwitchH
    TableData '/D', SwitchD
    TableData '/?', SwitchHelp
    TableData 'ADD', OptPlus
    TableData '+', OptPlus
    TableData 'SUB', OptMinus
    TableData '-', OptMinus
    TableData 'MUL', OptMultiply
    TableData '*', OptMultiply
    TableData 'DIV', OptDivide
    TableData '/', OptDivide
    TableData 'MOD', OptMod
    TableData '\', OptMod
    TableData 'SHR', OptShr
    TableData 'SHL', OptShl
    TableData 'AND', OptAnd
    TableData 'OR', OptOr
    TableData 'XOR', OptXor
    TableEnd
