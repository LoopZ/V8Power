; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

    mov     ax, [DelayTime]
    call    DelayFunc

    Terminate 0

DelayFunc:
	mov  		dx, ax
	cmp			dx, 0x0000
	je			.NoDelay
	mov         al, [DelayMode]
	cmp         al, 0
	je          .Delay8086
	cmp         al, 2
	je          .Delay286
	Is286
	cmp			ax, 0x0001
	je			.Delay286
.Delay8086:
	DelayTicks	dx
	jmp			.NoDelay
.Delay286:
	DelayTimer	dx
	jc          .Delay8086
.NoDelay:
    ret

SwitchD:
    mov         al, 1
    mov         [DelayMode], al
    ret

SwitchS:
    mov         al, 0
    mov         [DelayMode], al
    ret

SwitchI:
    mov         al, 2
    mov         [DelayMode], al
    ret

NoSwitch:
    NumberParam
    call        DelayFunc
    xor         ax, ax
    mov         [DelayTime], ax
    ret

    IdleCPUHandler
    HelpSwitchHandler 'vdelay'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'D',  0, SwitchD
    SwitchData  'S',  0, SwitchS
    SwitchData  'I',  0, SwitchI
    HelpSwitchData
    SwitchData  0,  0, 0


DelayMode:
    DB 0

DelayTime:
    DW 1000
