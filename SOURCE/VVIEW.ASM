; Copyright (C) 2024 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine DEBUG

%include "COMMON.INC"

%define opTimeOut   0x0100
%define opSilent    0x0200
%define opPurge     0x1000

    FrameBounds
    call            SwitchG ; default global mode
    
    DumpKeystrokes
    
    CommandLineParser        ; insert code for command line parsing

    Terminate   0
    
PointerError:
    Terminate   9
    
    IdleCPUHandler
    ColorSwitchHandlers
    LocalSwitchHandlers
    HelpSwitchHandler 'vview'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
;    SwitchData 'D', 1, SwitchD ; delay time in seconds (0-3600 seconds)
;    SwitchData 'R', 1, SwitchR ; timeout return code
    ColorSwitchData
    LocalSwitchData
    HelpSwitchData
    SwitchData  0,  0, 0
       
NoSwitch:

    push        ds
    pop         es
    ; copy filename
    mov         si, di
    mov         di, FileName   
    rep         movsb
    xor         al, al
    stosb
    pushall
    call        ViewFile
    popall
    ret
    
PtrToInt:
    ; remaps ES:DI from a seg:ofs pointer to flat 32-bit integer
    push    dx
    push    bx
    push    cx
    mov     dx, es
    mov     bx, dx
    push    cx
    mov     cl, 12
    shr     dx, cl
    mov     cl, 4
    shl     bx, cl
    pop     cx
    add     di, bx
    adc     dx, 0
    mov     es, dx
    pop     cx
    pop     bx
    pop     dx
    ret
    
IntToPtr:
    ; remaps ES:DI from a flat 32-bit integer to a seg:ofs pointer
    push    dx
    push    bx
    push    cx
    mov     dx, es
    test    dx, 0xfff0
    jnz     PointerError
    mov     bx, di
    
    push    cx
    mov     cl, 4
    shr     bx, cl
    mov     cl, 12
    shl     dx, cl
    pop     cx
    
    mov     cx, di
    and     cx, 0x000f
    add     dx, bx
    jc      PointerError
    mov     di, cx
    mov     es, dx
    pop     cx
    pop     bx
    pop     dx
    ret

    
ViewFile:
    mov     [FileHandle], word 0xffff
    mov     [FileError], word 0x0000
    mov     dx, FileName
    mov     ax, 0x3d00      ; open read only
    int     0x21
    jc      .OpenError
    mov     [FileHandle], ax
    mov     bx, ax
    xor     cx, cx
    mov     dx, cx
    mov     ax, 0x4202      ; Seek end of file for size
    int     0x21
    jc      .OpenError
    mov     [FileSize], ax
    mov     [FileSize+2], dx
    mov     [FilePos], ax
    mov     [FilePos+2], dx
    xor     ax,ax
    mov     [BufferCount], ax
    jmp     .FileDisplay
    
.OpenError:
    mov     [FileError], ax

.FileDisplay:

    mov         cx, [WindMin]
    mov         dx, [WindMax]

    call        HomePage
.Waiting:
    IdleCPU
    mov         ah, 0x01
    int         0x16
    jnz         .Keypress
    
.Keypress:
    mov         ah, 0x00
    int         0x16
    cmp         ah, 0x01
    je          .Key_Escape
    cmp         [FileHandle], word 0xffff
    je          .Waiting
    cmp         ah, 0x48
    je          .Key_Up
    cmp         ah, 0x50
    je          .Key_Down
    cmp         ah, 0x4b
    je          .Key_Left
    cmp         ah, 0x4d
    je          .Key_Right
    cmp         ah, 0x47
    je          .Key_Home
    cmp         ah, 0x4f
    je          .Key_End
    cmp         ah, 0x49
    je          .Key_PgUp
    cmp         ah, 0x51
    je          .Key_PgDn
    ;StdOutHexWord
    ;StdOutCRLF
    jmp         .Waiting
    
.Key_Up:
.Key_Down:
.Key_Left:
.Key_Right:
.Key_Home:
.Key_End:
.Key_PgUp:
.Key_PgDn:
    jmp         .Waiting
    
.Key_Escape: 
    mov         bx, [FileHandle]
    cmp         bx, 0xffff
    je          .DoNotClose
    mov         ah, 0x3e
    int         0x21    
.DoNotClose:
    ret
    
DrawError:
    ret
    
HomePage:
    xor         ax, ax
    mov         [Lines], ax
    mov         [Lines+2], ax
    call        Redraw
    ret
    
Redraw:
    cmp     [FileError], word 0
    jne     DrawError
    
    ; file home
    mov     ax, [Lines]
    mov     [FilePos], ax
    mov     ax, [Lines+2]
    mov     [FilePos+2], ax
       
    mov     cx, 1000
.Printing:
    call        ReadFile
    push        cx
    WriteChar
    pop         cx
    loop        .Printing
    
    ret
    
%idefine BufferSize 512 ; must be a power of 2
    
ReadFile:   ; Later Will Add Cached Buffered Reading
    ; returns al
    push    bx
    push    cx
    push    dx

    push    ax    
    mov     dx, [FilePos]
    mov     cx, [FilePos+2]
    cmp     [BufferCount], word 0
    je      .NeedBuff
    mov     ax, [BufferPos]
    mov     bx, [BufferPos + 2]
    ; Is NewPos Bellow Buffer?
    cmp     cx, bx
    jb      .NeedBuff
    cmp     dx, ax
    jb      .NeedBuff
    ; Is NewPos Above Buffer?
    add     ax, BufferSize
    adc     bx, 0
    cmp     cx, bx
    ja      .NeedBuff
    cmp     dx, ax
    jb      .InBuffer
.NeedBuff:
    ; Move Buffer
    mov     bx, [FileHandle]
    and     dx, (0x10000 - BufferSize)
    ; Seek for buffer read
    mov     ax, 0x4200    
    int     0x21
    jnc     .SeekOkay
.FileError:
    mov     [FileError], ax
    jmp     .Done
.SeekOkay:
    mov     [BufferPos], ax
    mov     [BufferPos+2], dx
    ; Load new buffer data
    mov     ah, 0x3f
    mov     cx, BufferSize
    mov     dx, BufferData
    int     0x21
    jc      .FileError
    mov     [BufferCount], ax
    ; For now... clear rest of buffer
    push    es
    push    di
    mov     cx, BufferCount
    sub     cx, ax
    jz      .Cleared
    push    cs
    pop     es
    mov     di, BufferData
    add     di, ax
    ; xor     al, al
    mov     al, 0xfe
    rep     stosb    
.Cleared:
    pop     di
    pop     es
.InBuffer:
    ; Since BufferSize is less than 0x10000 bytes, the High word of 
    ; FilePos and BufferPos must always be the same and no point in 
    ; subtracting them. So we will ignore them.
    mov     bx, [FilePos]
    sub     bx, [BufferPos]
    mov     bl, [BufferData + bx]
    ; move to new file position
    inc     word [FilePos]
    adc     word [FilePos + 2], 0
      
.Done:
    pop     ax
    mov     al, bl
    pop     dx
    pop     cx
    pop     bx
    ret
    
section .data

LineMax:        dw      1024
       
section .bss

FileHandle:     resw    1
FileError:      resw    1
FileSize:       resd    1
FilePos:        resd    1
BufferCount:    resw    1
BufferPos:      resd    1
BufferData:     resb    BufferSize
FileName:       resb    128
Lines:          resd    100
Widths:         resw    100
