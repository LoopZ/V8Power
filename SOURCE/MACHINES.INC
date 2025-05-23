; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%imacro DetectMachine 0

cpu 8086
use16

    mov         si, DOSBOXString
    mov         bx, 0xfe00
    mov         es, bx
    mov         cx, 0x0100
    call        SearchString
    jnc         NotDOSBox
    mov         ax, 101
    jmp         %%DetectDone

NotDOSBox:
    mov         si, QEMUString
    mov         bx, 0xf000
    mov         es, bx
    mov         cx, 0xf000
    call        SearchString
    jnc         NotQEMUBox
    mov         ax, 102
    jmp         %%DetectDone

NotQEMUBox:
    mov         si, VBOXString1
    mov         bx, 0xffe0
    mov         es, bx
    mov         cx, 0x0200
    call        SearchString
    jnc         NotVBOX1
    mov         ax, 103
    jmp         %%DetectDone

NotVBOX1:
    mov         si, VBOXString2
    mov         bx, 0xffe0
    mov         es, bx
    mov         cx, 0x0200
    call        SearchString
    jnc         NotVBOX2
    mov         ax, 103
    jmp         %%DetectDone

NotVBOX2:
    mov         si, VMString
    mov         bx, 0xf000
    mov         es, bx
    mov         cx, 0xf000
    call        SearchString
    jnc         NotVMware
    mov         ax, 104
    jmp         %%DetectDone

NotVMware:

;OtherEmulation:
;    cld
;    mov         al, 0x90
;    mov         cx, 0x0008
;    mov         di, $
;    rep         stosb
;    jmp         VirtualMachine
;    nop
;    nop


DetectCPU:
    ; Test Pre-186, CL is AND with 0x0f prior to/during shr
    mov         cl, 0x20
    mov         ax, 0x0001
    shr         ax, cl
    cmp         ax, 0x0000
    jne         .186orBetter
    xor         al, al
    jmp         .Done
.186orBetter:
    ; At least a 80186
    ; Pre-286 updates the Stack Pointer before push
    mov         ax, sp
    push        sp
    pop         bx
    cmp         ax, bx
    je          .286orBetter
    mov         ax, 1
    jmp         .Done
.286orBetter:
    ; At least a 286
    ; Check push/pop of upper flag bits for 386 or better
cpu 286

    pushf
    mov         ax, 0x7000
    push        ax
    popf
    pushf
    pop         ax
    popf
    and         ah, 0x70
    cmp         ah, 0x70
    je          .386orBetter
    mov         al, 2
    jmp         .Done
.386orBetter:
    ; At least a 386
    ; Test setting AC Flag
cpu 386

    mov         bx, sp
    and         sp, 0xfffc
    push        ebx

    pushfd
    pushfd
    pop         eax
    or          eax, 0x40000
    push        eax
    popfd
    pushfd
    pop         eax
    popfd

    test        eax, 0x40000

    jnz         .486orBetter

    mov         al, 3
    jmp         .Done32
.486orBetter:

cpu 486
    ; At least a 486
    ; Test setting ID Flag Bit

    pushfd
    pushfd
    mov         ecx, 0x00200000
    mov         ebx, [esp]
    xor         [esp], ecx
    popfd
    pushfd
    pop         eax
    xor         eax, [esp]
    popfd
    and         eax, ecx
    and         ebx, ecx
    cmp         eax, ebx
    jne         .UseCPUid
.IsAtleast486:
    mov         al, 4
    jmp         .Done32

.UseCPUid:

cpu 586

;    mov         eax, 0
;    cpuid
;    mov         [CPUname], ebx
;    mov         [CPUname + 4], edx
;    mov         [CPUname + 8], ecx

    mov         eax, 1
    cpuid
    shr         ax, 0x08
    and         ax, 0x0f
    cmp			ax, 0x04
    jb			.IsAtleast486

.Done32:

cpu 386

    pop         ebx
    mov         sp, bx

cpu 8086

.Done:

;    push        ax
;    mov         bx, CPUname
;    call        PrintStr
;    mov         dl, 32
;    int         0x21
;    pop         ax
    jmp         %%DetectDone

;VirtualMachine:
;    mov         ax, 200
;    jmp         %%DetectDone

SearchString:
    cld
    xor         bx, bx
    xor         di, di
.Looping:
    mov         dl, [cs:si+bx]
    cmp         dl, 0
    je          .Found
    mov         dh, [es:di+bx]
    cmp         dh, 0x61
    jb          .NotLower
    cmp         dh, 0x7a
    ja          .NotLower
    sub         dh, 0x20
.NotLower:
    cmp         dl, dh
    jne         .NotMatch
    inc         bx
    jmp         .Looping
.NotMatch:
    xor         bx, bx
    inc         di
    loop        .Looping
    clc
    ret
.Found:
    stc
    ret

DOSBOXString:
    db 'THE DOSBOX TEAM', 0
QEMUString:
    db 'QEMU',0
VBOXString1:
    db 'ORACLE VM VIRTUALBOX',0
VBOXString2:
    db 'ORACLE VIRTUALBOX',0
VMString:
    db 'VMWARE VIRTUAL PLATFORM',0

%%DetectDone:

%endmacro

%imacro MachineStatusMessage 1
    mov         al, %1
    mov         bx, %%Messages
%%ScanLoop:
    mov         ah, [bx]
    inc         bx
    cmp         al, ah
    je          %%Found
    cmp         ah, 0
    je          %%NotFound
%%ScanNext:
    mov         ah, [bx]
    inc         bx
    cmp         ah, 0
    jne         %%ScanNext
    jmp         %%ScanLoop

%%Found:
    WriteStr    bx
%%NotFound:
    WriteStr    %%MsgCRLF
    jmp         %%Done
%%MsgCRLF:
    db CRLF,0
%%Messages:
    db   1, '80186',0
    db   2, '80286',0
    db   3, '80386',0
    db   4, '80486',0
    db   5, '80586',0
    db   6, '80686',0
    db 101, 'DOSBox',0
    db 102, 'QEMU', 0
    db 103, 'VirtualBox', 0
    db 104, 'VMware',0
;    db 200, 'Emulation',0
    db   0, '8086',0
%%Done:

%endmacro

