; Copyright (C) 2024 Jerome Shidel
; Open source see License file

; NASM for DOS

; %idefine DEBUG

%idefine UseDirectVideo

; %idefine PageScroll

%include "COMMON.INC"

%define opTimeOut   0x0100
%define opSilent    0x0200
%define opPurge     0x1000

%idefine SPACE_CHAR 0x20

%ifdef UseDirectVideo
SetDirectVideo:
    push        es
    mov         ax, 0x0040
    mov         es, ax
    mov         al, [es:0x0049]
    cmp         al, 0x07
    je          .CheckPort
    cmp         al, 0x03
    ja          .Failed    
.CheckPort:
    mov         ax, 0xb800
    cmp         [es:0x0063], word 0x03d4
    je          .SetPtrData
    mov         ax, 0xb000
    cmp         [es:0x0063], word 0x03b4
    jne          .Failed
.SetPtrData:
    mov         [VSEG], ax
    mov         ax, [es:0x004e] ; page offset
    mov         [VOFS], ax
    mov         ax, [es:0x004a] ; columns
    add         ax, ax
    mov         [VBPR], ax
.Failed:
    pop         es
%endif

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
    %ifdef UseDirectVideo
        GotoXY      [WindMax]
    %endif
    popall
    ret
    
ViewFile:
    mov     al, [WindMaxX]
    sub     al, [WindMinX]
    inc     al
    mov     [Limit.X], al
    mov     al, [WindMaxY]
    sub     al, [WindMinY]
    inc     al
    mov     [Limit.Y], al
    
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
    call        GoHome

.Waiting:
    DumpKeystrokes
    cmp     [FileError], word 0
    je      .WaitLoop
    call    ShowError
    
.WaitLoop:
    IdleCPU
    mov         ah, 0x01
    int         0x16
    jz         .WaitLoop
    
.Keypress:
    mov         ah, 0x00
    int         0x16
    cmp         ah, 0x01
    je          .Key_Escape
    cmp         [FileHandle], word 0xffff
    je          .Waiting
    cmp         [FileError], word 0
    jne         .Waiting
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
    jmp         .Waiting
    
.Key_Up:
    call        GoUp
    jmp         .Refresh

.Key_Down:
    call    GoDown
    jc      .Waiting
    jmp     .Refresh
    
.Key_Left:
    cmp     [Offset.X], word 0
    je      .Waiting
    dec     word [Offset.X]
    jmp     .Refresh
    
.Key_Right:
    mov     ax, [Offset.X]
    add     al, [Limit.X]
    adc     ah, 0
    
    cmp     ax, [LineMax]
    ja      .Waiting
    inc     word [Offset.X]
    jmp     .Refresh
    
.Key_Home:
    mov         ax, [Offset.X]
    or          ax, [Offset.X+2]
    jz          .Waiting
    call        GoHome
    jmp         .Waiting
    
.Key_End:
    call        GoEnd
    jmp         .Refresh
    
.Key_PgUp:
    xor         ch, ch
    mov         cl, [Limit.Y]
.GoingUp:
    push        cx
    call        GoUp
    jc          .NoUp
    %ifdef PageScroll
        call        Redraw
    %endif    
.NoUp:
    pop         cx
    loop        .GoingUp
    %ifndef PageScroll
        call        Redraw
    %endif    
    jmp         .Waiting
    
.Key_PgDn:
    xor         ch, ch
    mov         cl, [Limit.Y]
.GoingDn:
    push        cx
    call        GoDown
    jc          .NoDn
    %ifdef PageScroll
        call        Redraw
    %endif    
.NoDn:
    pop         cx
    loop        .GoingDn
    %ifndef PageScroll
        call        Redraw
    %endif    
    jmp         .Waiting
    
.Key_Escape: 
    mov         bx, [FileHandle]
    cmp         bx, 0xffff
    je          .DoNotClose
    mov         ah, 0x3e
    int         0x21    
.DoNotClose:
    ret
    
.Refresh:
    call        Redraw
    jmp         .Waiting
    
DrawError:
    ret
        
Redraw:
    cmp     [FileError], word 0
    jne     DrawError
    
    ; file home
    mov     ax, [Offset.Start]
    mov     [FilePos], ax
    mov     ax, [Offset.Start+2]
    mov     [FilePos+2], ax
       
    xor     cx, cx
    mov     [LineMax], cx
    mov     cl, [Limit.Y]
    mov     [Draw.Y], byte 0
.Lines:
    
    push        cx
    call        DrawLine    
    pop         cx
    inc         byte [Draw.Y]
    loop        .Lines

    mov         ax, [FilePos]
    mov         [Offset.End], ax
    mov         ax, [FilePos+2]
    mov         [Offset.End+2], ax
    ret
    
DrawLine:
    cmp         [FileError], word 0
    jne         .Done
    xor         bx, bx
    xor         dx, dx
    mov        [Draw.X], dl
.NextChar:
    call        CompareEOF
    jb          .Not_EOF    
    mov         al, 0x0a
    jmp         .EOL
.Not_EOF:
    test         bx, bx
    jnz         .TabExpansion
    call        ReadFile
    jc          .Done
    cmp         al, 0x0d
    je          .EOL_CR
    cmp         al, 0x0a
    je          .EOL
    jmp         .CheckVisible
.TabExpansion:
    mov         al, SPACE_CHAR
    dec         bx
.CheckVisible:    
    cmp         al, 0x09
    jne         .NotTab
    push        ax
    push        dx
    mov         ax, dx
    xor         dx, dx
    mov         bx, 8
    div         bx
    sub         bx, dx
    pop         dx
    pop         ax
    jmp         .Not_EOF
.NotTab:
    cmp         dx, [Offset.X]
    jb          .NoDisplay
    call        PutChar
.NoDisplay:
    inc         dx
    test        bx, bx
    jnz         .Not_EOF
    jmp         .NextChar

.EOL_CR:
    call        ReadFile
    jc          .Done
    cmp         al, 0x0a
    je          .EOL
    sub         [FilePos], word 1
    sbb         [FilePos+2], word 0
.EOL:
    cmp         dx, [LineMax]
    jbe         .NoNewMax
    mov         [LineMax], dx
.NoNewMax:
    call        ClearEOL
.Done:
    ret
    
ClearEOL:  
    mov         al, [Draw.X]
    cmp         al, [Limit.X]
    jae         .Done
    mov         al, SPACE_CHAR
    call        PutChar
    jmp         ClearEOL
.Done:
    ret    

PutChar:
    mov         ah, [Draw.X]
    cmp         ah, [Limit.X]
    jae         .Done
%ifdef UseDirectVideo
    cmp         [VSEG], word 0
    je          .UseBIOS
    push        dx
    push        es
    push        di
    mov         ah, [TextAttr]
    push        ax
    les         di, [VPTR]    
    mov         al, [Draw.Y]
    add         al, [WindMinY]
    mov         dh, [VBPR]
    mul         dh
    add         di, ax
    xor         dh, dh
    mov         dl, [Draw.X]
    add         dl, [WindMinX]
    add         di, dx
    add         di, dx    
    pop         ax
    stosw
    pop         di
    pop         es
    pop         dx
    inc         byte [Draw.X]
    jmp         .Done
%endif
.UseBIOS:
    push        bx
    push        dx
    push        ax
    mov         dx, [Draw.XY]
    call        GotoXYProc
    inc         byte [Draw.X]
    pop         ax   
    mov         ah, 0x09
    mov         bh, [VideoPage]
    mov         bl, [TextAttr]
    mov         cx, 0x0001
    int         0x10
    pop         dx
    pop         bx
.Done:
    ret

CompareEOF:
    mov         ax, [FileSize+2]
    cmp         [FilePos+2], ax
    jne         .Done
    mov         ax, [FileSize]
    cmp         [FilePos], ax
.Done:
    ret
    
AtEOF:
    mov         ax, [FileSize+2]
    cmp         [Offset.End+2], ax
    jne         .Done
    mov         ax, [FileSize]
    cmp         [Offset.End], ax
.Done:
    ret


GoHome:
    xor         ax, ax
    mov         [Offset.X], ax
    mov         [Offset.Start], ax
    mov         [Offset.Start+2], ax
    call        Redraw
    ret

GoDown:
    call        AtEOF
    jae         .EOF
    %ifndef PageScroll
        mov         ax, [Offset.End]
        mov         dx, [Offset.End+2]    
        call        ScanEOL
        jc          .EOF
        mov         [Offset.End], ax
        mov         [Offset.End+2], dx    
    %endif
    mov         ax, [Offset.Start]
    mov         dx, [Offset.Start+2]    
    mov         [FilePos], ax
    mov         [FilePos+2], dx
    call        ScanEOL
    mov         [Offset.Start], ax
    mov         [Offset.Start+2], dx
    jmp         .Done
.EOF:
    stc
.Done:    
    ret
    
ScanEOL:
.NextChar:
    call        ReadFile
    jc          .Done
    cmp         al, 0x0a
    je          .EOL    
    cmp         al, 0x0d
    jne         .NextChar
.EOL_CR:
    call        ReadFile
    jc          .Done
    cmp         al, 0x0a
    je          .EOL
    sub         [FilePos], word 1
    sbb         [FilePos+2], word 0
.EOL:
    mov         ax, [FilePos]
    mov         dx, [FilePos+2]
    clc
.Done:
    ret
    
GoUp:
    mov         ax, [Offset.Start]
    mov         [FilePos], ax
    mov         dx, [Offset.Start+2]
    mov         [FilePos+2], dx
    call         .GetPrev
    jc          .NoUp
    cmp         al, 0x0a
    jne         .CheckCR
    call         .GetPrev
    jc          .NoUp
.CheckCR:
    cmp         al, 0x0d
    jne         .TestStop
    call         .GetPrev
    jc          ScanEOL.EOL
.TestStop:
    mov         bx, [FilePos]
    or          bx, [FilePos]
    jz          .NoUp
    cmp         al, 0x0a
    je          .Stop
    cmp         al, 0x0d
    je          .Stop
    call         .GetPrev
    jc          ScanEOL.EOL    
    jmp         .TestStop
.NoUp:
    xor         ax, ax
    mov         [Offset.Start], ax
    mov         [Offset.Start+2], dx
    ;  stc
    ret
.Stop:
    add         [FilePos], word 1
    adc         [FilePos+2], word 0
    mov         ax, [FilePos]
    mov         [Offset.Start], ax
    mov         dx, [FilePos+2]
    mov         [Offset.Start+2], dx
    clc
    ret        
    
.GetPrev:
    mov         ax, [FilePos]
    or          ax, [FilePos+2]
    jnz         .Fetch
    stc
    ret
.Fetch:
    sub         [FilePos], word 1
    sbb         [FilePos+2], word 0
    call        ReadFile
    jc          .NoUp
    sub         [FilePos], word 1
    sbb         [FilePos+2], word 0
    clc
    ret    
    
GoEnd:
    mov         ax, [FileSize]
    mov         dx, [FileSize + 2]
    mov         [Offset.Start], ax
    mov         [Offset.Start+2], dx
    xor         cx, cx
    mov         cl, [Limit.Y]
.GoingEnd:
    push        cx
    call        GoUp
    pop         cx
    loop        .GoingEnd
    ret
    
%idefine BufferSize 1024 ; must be a power of 2
    
ReadFile:   ; Later might add cached buffer reading
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
    clc
.Done:
    pop     ax
    mov     al, bl
    pop     dx
    pop     cx
    pop     bx
    ret
    
ShowError:
    xor             dx, dx
    mov             [Draw.XY], dx
    mov             si, MSG_ERROR
    call            PutStr
    
    mov             ax, [FileError]
	mov		        cx, 4
.Loopy:
	push	        cx
	push	        ax
	dec		        cx
	mov		        ax, 4
	mul		        cx
	mov		        cx, ax
	pop		        ax
	push	        ax
	shr		        ax, cl
	and		        ax, 0x0f
	cmp		        al, 9
	jle		        .Digit
	add		        al, 0x57
	jmp		        .Show
.Digit:
	add	        	al, 0x30
.Show:
    call            PutChar
	pop		        ax
	pop		        cx
	loop	        .Loopy
    

    call            PutStr
    push            si
    mov             si, FileName
    call            PutStr
    pop             si
    call            PutStr
    cmp             [FileError], word 2
    jne             .NotError2
    mov             si, MSG_ER2
    call            PutStr
.NotError2:
    cmp             [FileError], word 3
    jne             .NotError3
    mov             si, MSG_ER3
    call            PutStr
.NotError3:
    xor             ch, ch
    mov             cl, [Limit.Y]
.ClearAll:
    push            cx
    call            ClearEOL
    pop             cx
    mov             [Draw.X], byte 0
    inc             byte [Draw.Y]
    loop            .ClearAll
    ret    
    
PutStr:
    lodsb
    test        al, al
    jnz         .Draw
    ret
.Draw:
    call        PutChar
    jmp         PutStr
    
section .data

MSG_ERROR:      db "Error 0x",0
                db " with file '",0
                db "'",0
MSG_ER2:        db ': File not found',0
MSG_ER3:        db ': Path not found',0

%ifdef UseDirectVideo
VPTR:
VOFS:           dw      0x0000
VSEG:           dw      0x0000
VBPR:           dw      0x0000
%endif
           
section .bss

Limit.XY:
Limit.X:        resb    1
Limit.Y:        resb    1
Draw.XY:        
Draw.X:         resb    1
Draw.Y:         resb    1

Offset.X:       resw    1
Offset.Start:   resd    1
Offset.End:     resd    1
LineMax:        resw    1

FileName:       resb    128
FileHandle:     resw    1
FileError:      resw    1
FileSize:       resd    1
FilePos:        resd    1
BufferCount:    resw    1
BufferPos:      resd    1
BufferData:     resb    BufferSize
