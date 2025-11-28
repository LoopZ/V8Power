; Copyright (C) 2016-2025 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine ASCII_Table

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

    ; mov     ax, [OptionProcessed]
    ; cmp     ax, 0xffff
    ; jne     Done

    ; PlaceHolder

Done:
    mov         al, [ExitCode]
DoneTerminate:
    Terminate   al

%include "DSKTLS.INC"
%include "MACHINES.INC"
%include "V8-VBIOS.INC"

%ifdef ASCII_Table
ShowAscii:
    mov         al, 0x20
    WriteChar   0x09
    WriteChar   0x09
    WriteChar   0x09
    WriteChar   0x09
    WriteChar   0x09
    mov         bx, 0x30

.ShowAscii_1:
    push        bx
    mov         al, 0x20
    WriteChar   0x09
    mov         al, '+'
    WriteChar   0x09
    mov         al, 0x30
    WriteChar   0x09
    pop         bx
    push        bx
    mov         al, bl
    WriteChar   0x09
    pop         bx
    inc         bx
    cmp         bx, 0x3a
    jne         .ShowAscii_2
    add         bx, 0x27
.ShowAscii_2:
    cmp         bx, 0x67
    jne         .ShowAscii_1
    xor         bx, bx
.ShowAscii_3:
    push        bx
    WriteStr    .ShowAscii_CRLF
    pop         bx
    push        bx
    mov         ax, bx
    push        ax
    mov         al, '0'
    WriteChar   0x09
    mov         al, 'x'
    WriteChar   0x09
    pop         ax
    mov         cl, 4
    shr         al, cl
    cmp         al, 0x0a
    jl         .ShowAlpha
    add         al, 0x07
.ShowAlpha:
    add         al, 0x30
    WriteChar   0x09
    mov         al, '0'
    WriteChar   0x09
    mov         al, 0x20
    WriteChar   0x09

    pop         bx
    xor         cx, cx
.ShowAscii_4:
    push        bx
    push        cx
    mov         ax, bx
    add         ax, cx
    push        ax
    mov         al, 0x20
    WriteChar   0x09
    WriteChar   0x09
    WriteChar   0x09
    pop         ax
    WriteChar   0x09
    pop         cx
    pop         bx
    inc         cx
    cmp         cx, 0x10
    jne         .ShowAscii_4
    add         bx, cx
    cmp         bx, 0x100
    jl          .ShowAscii_3
    StdOutCRLF
    ret
.ShowAscii_CRLF:
    db          CRLF,0
%endif

SwitchV:
    ; mov         [OptionProcessed], cx
    mov         al, 1
    mov         [QueryMode], al
    ret

SwitchD:
    ; mov         [OptionProcessed], cx
    DiskStatus      [di]
    cmp         al, 0
    je          .Skip
    mov         [ExitCode], al
.Skip:
    mov         ah, [QueryMode]
    cmp         ah, 1
    jne         .Done
    DiskStatusMessage  al
.Done:
    ret

SwitchM:
    mov			[GeneralEM], byte 0
    ; mov         [OptionProcessed], cx
SwitchM2:
    push ds
    push es
    DetectMachine
    pop  es
    pop  ds
    cmp         al, 0
    je          .Skip
    mov         [ExitCode], al
.Skip:
    mov         ah, [QueryMode]
    cmp         ah, 1
    jne         .Done
    MachineStatusMessage  al
.Done:
    ret

SwitchP:
    mov			[GeneralEM], byte 0
    ; mov         [OptionProcessed], cx
    push ds
    push es
    jmp         DetectCPU

SwitchT:
    mov			[GeneralEM], byte 1
    jmp			SwitchM2

SwitchC:
;    StdOutStr   0x81
;    StdOutCRLF
;    mov         di, 0x80
    xor         ax, ax
.Repeat:
    lodsb
    StdOutIntWord
    push        ax
    StdOutChar ' '
    pop         ax
    cmp         al,0
    jne         .Repeat
    StdOutCRLF
    Terminate 0

SwitchJ:
	push 		ax
	mov			al, 0x01
	mov			[CaseSpecific], al
	pop			ax
SwitchK:
    NumberParam
    inc			ax
    xor 		ah, ah
    mov         cx, ax
.Repeat:
    lodsb
    test		al, al
    jz			.NotFound
    loop        .Repeat
    mov			cl, [CaseSpecific]
    test		cl, cl
    jnz			.CheckVerbose
    cmp			al, 0x60
    jbe			.CheckVerbose
    cmp			al, 0x7b
    jae			.CheckVerbose
    sub			al, 0x20
.CheckVerbose:
    mov			cl, [QueryMode]
    test		cl, cl
    jz			.NotFound
    push 		ax
    StdOutChar  al
    StdOutCRLF
    pop			ax
.NotFound:
    Terminate   al

NoSwitch:
    LookupParam OptionsTable
    cmp         ax, 0xffff
    je          .NotOption
    ; mov         [OptionProcessed], ax
    jmp         ax

.NotOption:
    NumberParam
    ; do something with ax

InvalidOption:
    WriteStr    CommandLineErrorMsg
    Terminate   100

    HelpSwitchHandler 'vinfo'

ShowByte:
    push    cx
    StdOutHexByte none
    pop     cx
    ret

ShowWord:
    push    ax
    mov     al, ah
    call    ShowByte
    pop     ax
    call    ShowByte
    ret

ShowRAMline:
    push    bx
    cmp     ax, 0xffff
    je      .NoSkip
    test    dx, dx
    jnz     .NoSkip
    mov     si, bx
    mov     cx, 0x08
    mov     bx, 0xffff
.Skippy:
    lodsw
    and     bx, ax
    or      dx, ax
    loop    .Skippy
    jz      .CanSkip
    cmp     bx, 0xffff
    jne     .NoSkip
.CanSkip:
    cmp     [cs:Skipper], byte 1
    jb      .SkipBlank
    ja      .NoSkip
    jmp     .SkipRet
.SkipBlank:
    mov     [cs:Skipper], byte 1
    call    .CRLF
.SkipRet:
    pop     bx
    ret

.NoSkip:
    pop     bx
    mov     [cs:Skipper], byte 0
    mov     ax, ds
    call    ShowWord
    StdOutChar ':'
    xchg    ax, bx
    call    ShowWord
    xchg    ax, bx
    StdOutChar ' '
    StdOutChar ' '
    mov     si, bx
    mov     cx, 0x10
.HexBytes:
    lodsb
    call    ShowByte
    StdOutChar ' '
    loop    .HexBytes
    StdOutChar ' '
    StdOutChar ' '
    mov     si, bx
    mov     cx, 0x10
.CharBytes:
    lodsb
    cmp       al, 7 ; bell
    je        .Hidden
    cmp       al, 8 ; backspace
    je        .Hidden
    cmp       al, 9 ; tab
    je        .Hidden
    cmp       al, 10 ; Carriage Return
    je        .Hidden
    cmp       al, 11 ; Vertical Tab
    je        .Hidden
    cmp       al, 12 ; Form Feed
    je        .Hidden
    cmp       al, 13 ; LineFeed
    je        .Hidden
    cmp       al, 26 ; EOF
    je        .Hidden

    StdOutChar al
    jmp        .Shown
.Hidden:
    StdOutChar '.'
.Shown:
    loop     .CharBytes
.CRLF:
    StdOutChar 13
    StdOutChar 10
    ret

ShowURAM:
    mov     ax, 0xa000
    xor     dx,dx
    jmp     ShowRAM.Prepare

ShowRAM:
    mov     dl, 1
    xor     ax, ax
.Prepare:
    mov     [cs:Skipper], byte 2
    push    ds
    mov     cx, ax
    xor     bx, bx
.cycle:
    cld
    push    cx
    push    ax
    test    dl, dl
    jnz      .All
    cmp     ax, 0xb800
    jb      .All
    cmp     ax, 0xbfff
    ja      .All
    jmp     .NotDisplay
.All:
    push    dx
    mov     ds, ax
    call    ShowRAMline
    pop     dx
.NotDisplay:
    pop     ax
    pop     cx
    inc     ax
    loopnz  .cycle
    pop     ds
    ret

SwitchU:
    cld
    push    di
    mov     si, di
.Loopy:
    lodsb
    cmp     al, 0
    je      .Done
    cmp     al, 0x61
    jb      .NoCase
    cmp     al, 0x7a
    ja      .NoCase
    sub     al, 0x20
.NoCase:
    stosb
    jmp     .Loopy
.Done:
    pop     di
    mov     bl, 1
    mov     ax, 0xa000
    jmp     SearchRAM

SwitchR:
    mov     bl, 0
    xor     ax, ax

SearchRAM:
    cld
    mov     si, di
    mov     es, ax
    xor     ax, ax
    mov     di, ax
.CheckPos:
    push    di
    push    si
.CheckLoop:
    lodsb
    mov     ah, [es:di]
    inc     di

    cmp     al, 13
    je      .Same
    cmp     al, 0
    je      .Same
    cmp     bl, 0
    je      .CheckChar

    cmp     ah, 0x61
    jb      .CheckChar
    cmp     ah, 0x7a
    ja      .CheckChar
    sub     ah, 0x20
.CheckChar:
    cmp     al, ah
    jne     .Diff
    jmp     .CheckLoop
.Same:
    pop     si
    pop     di
    push    di
    push    si
    mov     ax, es
    call    ShowWord
    StdOutChar ':'
    mov     ax, di
    call    ShowWord
    StdOutChar 13
    StdOutChar 10

    push    es
    push    ds

    push    es
    pop     ds

    push    bx
    xor     bx, bx
    call    ShowRAMline
    mov     ax, ds
    inc     ax
    mov     ds, ax
    call    ShowRAMline
    pop     bx

    pop     ds
    pop     es
.Diff:
    pop     si
    pop     di
    inc     di
    cmp     di, 0x0010
    jb      .CheckPos
    xor     di, di
    push    es
    pop     ax
    inc     ax
    push    ax
    pop     es
    cmp     ax, 0xffff
    jne     .CheckPos

    Terminate   0

SwitchG:
    Probe_Display_Adapter
    mov     ah, [QueryMode]
    cmp     ah, 0
    je      .SwitchGExit
    push    ax
    mov     ah, al
    mov     di, .DisplayTypes
    cmp     ah, 9
    jna     .Find
    xor     ah, ah
.Find:
    cmp     ah, 0
    je      .Print
    mov     al, [di]
    inc     di
    cmp     al, 0
    jne     .Find
    dec     ah
    jmp     .Find
.Print:
    ; dec         di
    StdOutStr   di
    StdOutCRLF
    pop  ax
.SwitchGExit:
    Terminate al

.DisplayTypes:
    db 'Unknown',0
    db 'MDA',0
    db 'HGC',0
    db 'HGCPlus',0
    db 'InColor',0
    db 'CGA',0
    db 'EGA',0
    db 'MCGA',0
    db 'VGA',0
    db 'VESA/SuperVGA',0

SwitchE:
    ; mov         [OptionProcessed], cx
    NumberParam
    dec         al
    jo          SwitchError
    add         al, 0x80
    jo          SwitchError
    mov         [DRIVE_ID], al

    mov             cx, 3
.ReadRetry:
    push            cx
    ZeroMemory      Buffer, 512
    mov             ax, 0x0201
    mov             cx, 0x0001
    xor             dh, dh
    mov             dl, [DRIVE_ID]
    mov             bx, Buffer
    int             0x13
    pop             cx
    jnc             .ReadOK
    jcxz            .ReadFail
    dec             cx
    mov             dl, [DRIVE_ID]
    mov             ah, 0x00
    int             0x13
    jmp            .ReadRetry
.ReadFail:
    mov             al, ah
    mov             di, Msg_Error
    push        ax
    mov         ah, [QueryMode]
    cmp         ah, 0
    pop         ax

    je          DoneTerminate
    push        ax
    StdOutStr   di
    pop         ax
    StdOutIntByte al
    StdOutCRLF
    mov         al, 100
    je          DoneTerminate

.ReadOK:
    ; StdOutHexAsciiDump Buffer, Buffer + 512
    ; StdOutCRLF

    ; Maybe also validate the signature 55h AAh at the end.
    cld
    mov             si, Buffer
    xor             al, al
    mov             cx, 512
.Scan:
    lodsb
    test             al, 0xff
    loopz           .Scan
    mov             al, 0
    mov             di, Msg_MBR_Empty
    cmp             cx, 0
    je              .Result
    mov             al, 5
    mov             di, Msg_No_MBR_Code
    cmp             cx, 0x3f
    jbe             .Result
    mov             al, 10
    mov             di, Msg_Found_MBR_Code
.Result:
    mov             [ExitCode], al
    mov             ah, [QueryMode]
    cmp             ah, 0
    je              .Done
    push            ax
    StdOutStr       di
    StdOutCRLF
    pop             ax
.Done:
;    jmp             DoneTerminate
     ret

Msg_Error:
    db  "Error #",0
Msg_MBR_Empty:
    db "MBR is empty",0
Msg_No_MBR_Code:
    db "No MBR Code",0
Msg_Found_MBR_Code:
    db "MBR Code Present",0

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    SwitchData 'D', 1, SwitchD
    SwitchData 'V', 0, SwitchV
    SwitchData 'M', 0, SwitchM
    SwitchData 'P', 0, SwitchP
    SwitchData 'C', 0, SwitchC
    SwitchData 'U', 1, SwitchU
    SwitchData 'R', 1, SwitchR
    SwitchData 'G', 0, SwitchG
    SwitchData 'E', 1, SwitchE
    SwitchData 'K', 1, SwitchK
    SwitchData 'J', 1, SwitchJ
    SwitchData 'T', 0, SwitchT
    HelpSwitchData
    SwitchData  0,  0, 0

OptionsTable:
%ifdef ASCII_Table
    TableData "ASCII", ShowAscii
    TableData "RAM", ShowRAM
    TableData "URAM", ShowURAM
%endif
    TableEnd

;OptionProcessed:
;    dw 0xffff
QueryMode:
    db  0
CaseSpecific:
    db  0
ExitCode:
    db  0
SavedInt24:
    dw 0, 0
Drive:
    db 0
DRIVE_ID:
    db 0
Skipper:
    db 0
GeneralEM:
	db 0

EndOfCode:

Buffer:
