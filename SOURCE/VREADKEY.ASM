; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%include "COMMON.INC"

%define opTimeOut   0x0100
%define opSilent    0x0200
%define opPurge     0x1000

    CommandLineParser       ; insert code for command line parsing

    call        .GetTicker
    
    test        [OPTIONS], word opPurge
    jz          .WaitLoop
   
   DumpKeystrokes
    
.WaitLoop:
    mov         ax, 0x0100
    int         0x16
    jnz         .KeyPressed
    test        [OPTIONS], word opTimeOut
    jz          .WaitLoop
    cmp         [WAIT_DELAY], word 0
    je          .TimeOut
    IdleCPU
    call        .GetTicker
    jnc         .WaitLoop
    dec         word [WAIT_DELAY]    
    jmp         .WaitLoop
    
.GetTicker:
    push        es
    mov         ax, 0x0040
    mov         es, ax
    mov         ax, [es:0x006c]
    cmp         [TICKER], ax
    je          .NoTick
    mov         [TICKER], ax
    stc
    jmp         .Ticker_Done
.NoTick:
    clc
.Ticker_Done:
    pop         es
    ret

.KeyPressed:    
    mov         ax, 0x0000
    int         0x16
    jmp         .SetKeyCode
    
.TimeOut:
    mov         ax, [DEFAULT_CODE]
    
.SetKeyCode:
    test        al, al
    jz          .KeepHigh
    xor         ah, ah
.KeepHigh:
    mov         [KEYCODE], ax
    
.StandardCodes:
    test        [OPTIONS], word opSilent
    jnz         .Silent
    StdOutHexWord null
    StdOutCRLF
        
.Silent:
    mov         ax, [KEYCODE]
    test        ah, ah
    jz          .Goodbye
    mov         al, ah
    or          al, 0x80
.Goodbye:
    Terminate   al

IdleCPUHandler

HelpSwitchHandler 'vreadkey'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData 'N', 0, SwitchN ; no standard output
    SwitchData 'D', 1, SwitchD ; delay time in seconds (0-3600 seconds)
    SwitchData 'R', 1, SwitchR ; timeout return code
    SwitchData 'P', 0, SwitchP ; purge any pending keystrokes
    HelpSwitchData
    SwitchData  0,  0, 0

SwitchP:
    or  [OPTIONS], word opPurge
    ret

SwitchN:
    or  [OPTIONS], word opSilent
    ret
    
SwitchR:
    NumberParam
    mov         [DEFAULT_CODE], ax
    or          [OPTIONS], word opTimeOut
    ret
    
SwitchD:
    NumberParam
    cmp         ax, 3600
    jbe         .OK
    mov         ax, 3600
.OK:
    pushf
    push        cx
    push        dx
    mov         dx, 182
    mov         cx, 10
    mul         dx
    div         cx
.SetValue:
    mov         [WAIT_DELAY], ax
    or          [OPTIONS], word opTimeOut
    pop         dx
    pop         cx
    popf
    ret
    
NoSwitch:

InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100
    
section .data

OPTIONS:        dw 0
KEYCODE:        dw 0

DEFAULT_CODE:   dw 0
WAIT_DELAY:     dw 30
TICKER:         dw 0
