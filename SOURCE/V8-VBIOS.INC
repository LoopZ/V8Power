; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM 2.14rc0

%idefine VideoCardIsVESA       9
%idefine VideoCardIsVGA        8
%idefine VideoCardIsMCGA       7
%idefine VideoCardIsEGA        6
%idefine VideoCardIsCGA        5
%idefine VideoCardIsInColor    4
%idefine VideoCardIsHGCPlus    3
%idefine VideoCardIsHGC        2
%idefine VideoCardIsMDA        1
%idefine VideoCardIsUnknown    0

%imacro Probe_Display_Adapter 0

    %%Probe_VGA:                    ; 1897
        mov     ax,  0x1200         ; video subsystem config
        mov     bl,  0x36           ; enable/disable display refresh
                                    ; al=0 enable, al=1 disable
        int     0x10
        cmp     al,  0x12           ; check on success
        jne     %%Probe_MCGA

    %%Probe_VESA:
        push    di
        mov     ax, 0x4f00
        mov     di, %%VesaBuffer    ; ES:DI --> 256byte Buffer
        int     0x10
        pop     di
        cmp     ax, 0x004f
        jne     %%OnlyVGA
        ; quick dirty VESA test
        mov     dx, [%%VesaBuffer]
        cmp     dx, 'VE'
        jne     %%OnlyVGA
        mov     dx, [%%VesaBuffer + 2]
        cmp     dx, 'SA'
        jne     %%OnlyVGA
        mov     al,  VideoCardIsVESA
        jmp     %%Done

    %%OnlyVGA:
        mov     al, VideoCardIsVGA
        jmp     %%Done

    %%VesaBuffer:                   ; This needs moved to the an unintialized
        times 0x100 db 0            ; data area

    %%Probe_MCGA:                   ; 1987
        mov     ax,  0x1200         ; video subsystem config
        mov     bl,  0x32           ; enable/disable cpu access to video ram
                                    ; al=0 enable, al=1 disable
        int     0x10
        cmp     al,  0x12           ; check success
        jne     %%Probe_EGA
        mov     al, VideoCardIsMCGA
        jmp     %%Done

    %%Probe_EGA:                    ; 1984
        mov     ax,  0x1200         ; video subsystem config
        mov     bx,  0x0010         ; get video config
        int     0x10
        cmp     ah,  0x10           ; check success
        jne     %%Probe_CGA
        mov     al, VideoCardIsEGA
        jmp     %%Done

    %%Probe_Ports:
        mov     ax, 0x060a          ; change cursor bottom scan line
                                    ; set ah=06 for later
        mov     bl, al
        out     dx, al
        inc     dx
        in      al, dx              ; get current
        xchg    al, ah
        cmp     ah, al
        jne     %%Change_Value
        dec     al
        dec     bl
    %%Change_Value:
        out     dx, al
        mov     cx, 0x0050          ; small delay
    %%Probe_Delay:
        loop    %%Probe_Delay
        in      al, dx              ; get new value
        xchg    al, ah
        out     dx, al              ; restore old value
        cmp     ah, bl
        ret

    ; it should be possible to first get base port number
    ; of active 6845 controller from BDA at 0040:0063

    %%Probe_CGA:
        mov     dx, 0x3d4           ; video port
        call    %%Probe_Ports
        jne     %%Probe_Monochrome
        mov     al, VideoCardIsCGA
        jmp     %%Done

    %%Probe_Monochrome:
        mov     dx, 0x3b4           ; video port
        call    %%Probe_Ports

        jne     %%Probe_Failed      ; not 100% sure on this part

        ; jne     %%Probe_MDA
        ; mov     al, Monochrome
        ; jmp     %%Done

    %%Probe_MDA:
        mov     cx, 0xf000          ; watch for bit 7 to change
        mov     bx, 0x0080          ; stays the same on MDA
        mov     dx, 0x03ba
        xor     ax, ax
    %%Probe_Watching:
        in      al, dx
        test    ax, bx
        loopnz  %%Probe_Watching
        cmp     cx, 0
        jne     %%Probe_InColor
        mov     al, VideoCardIsMDA
        jmp     %%Done

    %%Probe_InColor:
        and     al, 01110000b       ; Al left over from chwecking status
        cmp     al, 01010000b       ; register in MDA Probe
        jne     %%Probe_HGCPlus
        mov     al, VideoCardIsInColor
        jmp     %%Done

    %%Probe_HGCPlus:
        cmp     al, 00010000b
        jne     %%Probe_HGC
        mov     al, VideoCardIsHGCPlus
        jmp     %%Done

    %%Probe_HGC:
        mov     al, VideoCardIsHGC
        jmp     %%Done

    %%Probe_Failed:
        xor     al,al

    %%Done:
        xor     ah,ah

%endmacro   ``