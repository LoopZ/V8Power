; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput
%idefine SuperVGA

%include "COMMON.INC"

    call        ReadMode
    mov         [ModeFirst], ax
    mov         [FontFirst], bx

    CommandLineParser       ; insert code for command line parsing

GoodBye:
    mov     ax, [FontCurrent]
    cmp     ax, [FontFirst]
    jne     .SetNewMode
    mov     ax, [ModeCurrent]
    cmp     ax, [ModeFirst]
    jne     .SetNewMode
    cmp	    [HadOpts], byte 0
    jne	    .Finished
    mov     si, BW40Msg
    test    ax, ax
    jz      .PrintMode
    mov     si, CO40Msg
    cmp     ax, 0x01
    je      .PrintMode
    mov     si, CO80Msg
    cmp     ax, 0x03
    je      .PrintMode
    mov     si, BW80Msg
    jb      .PrintMode
    mov     si, MonoMsg
    cmp     ax, 0x07
    je      .PrintMode
    StdOutHexWord
    jmp     .ROMFontSize
.PrintMode:
    StdOutStr si

.ROMFontSize:
    mov	    ax, [FontCurrent]
    cmp     al, 0x08
    je      .PrintFont
    cmp     al, 0x0e
    je      .PrintFont
    cmp     al, 0x10
    je      .PrintFont
    jmp     .NoROMFont
.PrintFont:
    push    ax
    StdOutStr PlusFontMsg
    pop     ax
    StdOutIntWord ax
.NoROMFont:
    StdOutCRLF
    jmp     .Done
.SetNewMode:
    call    WriteMode
.Finished:
    xor     al, al
.Done:
    Terminate al

InvalidMode:
    mov     al, 100
    jmp     GoodBye.Done

ReadMode:
    %ifdef SuperVGA
        call    ReadModeSVGA
        cmp     ax, 0x100
        jge     .Done
    %endif
    mov     ah, 0x0f
    int     0x10
    xor     ah, ah
    cmp     al, 0x07
    jle     .Normal
    mov     ax, 0xffff
    jmp     .Done
.Normal:
    push        es
    mov         bx, 0x0040
    push        bx
    pop         es
    mov         bh, [es:0x0085]
    pop         es
    cmp         bh, 0x08
    je          .KnownFont
    cmp         bh, 0x0e
    je          .KnownFont
    cmp         bh, 0x10
    je          .KnownFont
    xor         bh, bh
.KnownFont:
    xchg	bh, bl
.Done:
    xor         bh, bh
    mov         [ModeCurrent], ax
    mov         [FontCurrent], bx
    ret

WriteMode:
    mov     ax, [ModeCurrent]
    cmp     ax, 0xffff
    je      InvalidMode
    cmp     ax, 0x0100
    jb      .StandardMode
    %ifdef SuperVGA
        jmp    WriteModeSVGA
    %else
    	jmp    InvalidMode
    %endif
.StandardMode:
    mov     ah, 0x00
    int     0x10
    ; ret

WriteFont:
    mov     ax, [FontCurrent]
    mov     bl, 0x12
    cmp     al, 0x08
    je      .LoadROMFont
    mov     bl, 0x11
    cmp     al, 0x0e
    je      .LoadROMFont
    mov     bl, 0x14
    cmp     al, 0x10
    jne     .Done
.LoadROMFont:
    mov     al, bl
    mov     ah, 0x11
    mov     bl, 0
    int     0x10
    ; fix cursor
    mov     ah, 0x03
    mov     bh, 0
    int     0x10
    push    cx
    mov     cx, 0x2000
    mov     ah, 0x01
    int     0x10
    pop     cx
    int     0x10
.Done:
    ret

ReadModeSVGA:
    push    di
    mov     ax, 0x4f00
    mov     di, SVGABuffer
    int     0x10
    cmp     ax, 0x004f
    jne     .NoVesa
    ; quick dirty VESA test
    mov     dx, [SVGABuffer]
    cmp     dx, 'VE'
    jne     .NoVesa
    mov     dx, [SVGABuffer + 2]
    cmp     dx, 'SA'
    jne     .NoVesa
    ; get mode
    mov     ax, 0x4f03
    int     0x10
    cmp     ax, 0x004f
    jne     .NoVesa
    mov     ax, bx
    jmp     .Done
.NoVesa:
    xor     ax, ax
.Done:
    pop     di
    ret

WriteModeSVGA:
    push    di
    mov     ax, 0x4f00
    mov     di, SVGABuffer
    int     0x10
    cmp     ax, 0x004f
    jne     .NoVesa
    ; quick dirty VESA test
    mov     dx, [SVGABuffer]
    cmp     dx, 'VE'
    jne     .NoVesa
    mov     dx, [SVGABuffer + 2]
    cmp     dx, 'SA'
    jne     .NoVesa
    ; get mode
    mov     ax, 0x4f02
    mov     bx, [ModeCurrent]
    int     0x10
    cmp     ax, 0x004f
    je      .Done
    pop     di
    StdOutStr FailVesaMsg
    Terminate 100
.NoVesa:
    StdOutStr NoVesaMsg
    Terminate 101
.Done:
    pop     di
    ret

    LookupParamProc
    NumberParamProc

OptVesa:
    push    es
    push    si
    push    di
    mov     ax, 0x4f00
    mov     di, SVGABuffer
    int     0x10
    cmp     ax, 0x004f
    jne     .NoVesa
    ; quick dirty VESA test
    mov     dx, [SVGABuffer]
    cmp     dx, 'VE'
    jne     .NoVesa
    mov     dx, [SVGABuffer + 2]
    cmp     dx, 'SA'
    jne     .NoVesa

;    xor     ax, ax
;.LowModes:
;    push    ax
;    call    VesaModeInfo
;    pop	    ax
;    inc     ax
;    cmp     ax, 0x100
;    jb      .LowModes

    les     si, [SVGABuffer + 0x0e]
.Looping:
    mov     ax, [es:si]
    cmp     ax, 0xffff
    je      .Done
    call    VesaModeInfo
    add     si, 2
    jmp     .Looping
.NoVesa:
    pop     di
    StdOutStr NoVesaMsg
    push    di
.Done:
    pop     di
    pop     si
    pop     es
    jmp	    GoodBye.Finished

VesaModeInfo:
    push    es
    push    cs
    pop     es
    mov     di, SVGAMode
    push    ax
    push    di
    mov     cx, 0x0080
    xor	    ax, ax
    cld
    rep     stosw
    pop     di
    pop     cx
    mov	    ax, 0x4f01
    int     0x10
    cmp     ax, 0x004f
    jne     .Done
    mov			ax, cx
    StdOutHexWord 	ax
    StdOutStr	  	ModeSepMsg
    mov			ax, [SVGAMode+0x12]
    StdOutIntWord 	ax
    StdOutChar		'x'
    mov			ax, [SVGAMode+0x14]
    StdOutIntWord 	ax
    StdOutCRLF
.Done:
    pop   es

OptIngore:
    ret

OptBW40:
    mov     ax, 0x0000
    jmp     SetModeCurrent

OptColor40:
    mov     ax, 0x0001
    jmp     SetModeCurrent

OptBW80:
    mov     ax, 0x0002
    jmp     SetModeCurrent

OptColor80:
    mov     ax, 0x0003
    jmp     SetModeCurrent

OptMono80:
    mov     ax, 0x0007

SetModeCurrent:
    mov         [ModeCurrent], ax
    ret

OptFont8:
    mov     al, 0x08
    jmp     SetFontCurrent

OptFont14:
    mov     al, 0x0e
    jmp     SetFontCurrent

OptFont16:
    mov     al, 0x10

SetFontCurrent:
    xor     ah, ah
    mov     [FontCurrent], ax
    ret

SwitchF:
    mov     ax, 0xffff
    mov     [ModeFirst], ax
    ret

NoSwitch:
    or		[HadOpts], byte 1
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    mov         bx, [ModeCurrent]
    jmp         ax

.NotOption:
    NumberParam
    jnc		SetModeCurrent

.InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

    HelpSwitchHandler 'vmode'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData 'F', 0, SwitchF
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
    TableData 'B40',    OptBW40
    TableData 'B80',    OptBW80
    TableData 'BW40',   OptBW40
    TableData 'BW80',   OptBW80
    TableData 'BW',     OptBW80
    TableData 'C40',    OptColor40
    TableData 'C80',    OptColor80
    TableData 'CO40',   OptColor40
    TableData 'CO80',   OptColor80
    TableData 'COLOR',  OptColor80
    TableData 'MONO',   OptMono80
    TableData 'FONT8',  OptFont8
    TableData 'FONT14', OptFont14
    TableData 'FONT16', OptFont16
    TableData 'F8',     OptFont8
    TableData 'F14',    OptFont14
    TableData 'F16',    OptFont16
    TableData 'VESA',   OptVesa
    TableData '+',      OptIngore
    TableEnd

PlusFontMsg:
    DB ' + Font',0
BW40Msg:
    DB 'BW40',0
BW80Msg:
    DB 'BW80',0
CO40Msg:
    DB 'CO40',0
CO80Msg:
    DB 'CO80',0
MonoMsg:
    DB 'MONO',0

%ifdef SuperVGA
FailVesaMsg:
    DB 'Bad VESA mode.',CRLF,0
NoVesaMsg:
    DB 'No VESA support.',CRLF,0
ModeSepMsg:
    DB ' - ',0
GraphicsModeMsg:
    DB ' Graphics',0
TextModeMsg:
    DB ' Text',0
%endif

HadOpts:
    db      0

ModeCurrent:
    dw      0
ModeFirst:
    dw      0
FontCurrent:
    dw      0
FontFirst:
    dw      0

%ifdef SuperVGA
section .bss

SVGABuffer:
    resb 0x100
SVGAMode:
    resb 0x100

%endif