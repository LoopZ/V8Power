; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%include "COMMON.INC"

CommandLineParser
Terminate 0

NoSwitch:
    mov     bx, di
.FindColon:
    mov     al, [bx]
    cmp     al, ':'
    je      SoundAndDelay
    cmp     bx, si
    je      DelayOnly
    inc     bx
    jmp     .FindColon

SoundAndDelay:
    mov     cx, bx
    sub     cx, di
    push    bx
    NumberParam
    pop     bx
    mov     cx, ax
    push    cx
    inc     bx
    mov     di, bx
    mov     cx, si
    sub     cx, di
    NumberParam
    pop     cx
    call    Sound
    jmp     DoDelay

DelayOnly:
    NumberParam
    call    SoundOff
DoDelay:
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
.NoDelay:
    ret

Sound:
    push    ax
    cmp     cx, 0x0012
    jle     SoundOffInstead
    mov     dx, 0x0012
    mov     ax, 0x34DC
    div     cx
    push    ax
    mov     al, 10110110b
    mov     dx, 0x0043
    out     dx, al
    mov     dx, 0x0042
    pop     ax
    out     dx, al
    mov     al, ah
    out     dx, al
    mov     dx, 0x0061
    in      al, dx
    mov     al, 0x03
    out     dx, al
    pop     ax
ret

SoundOffInstead:
    pop     ax
SoundOff:
    push    ax
    mov     dx, 0x0061
    in      al, dx
    and     al, 11111101b
    out     dx, al
    mov     al, 10110110b
    mov     dx, 0x0043
    out     dx, al
    mov     dx, 0x0042
    mov     al, 0
    out     dx, al
    out     dx, al
    pop     ax
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

    IdleCPUHandler
    HelpSwitchHandler 'vpcspkr'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData  'D',  0, SwitchD
    SwitchData  'S',  0, SwitchS
    SwitchData  'I',  0, SwitchI
    HelpSwitchData
    SwitchData  0,  0, 0

DelayMode:
    DB 0
