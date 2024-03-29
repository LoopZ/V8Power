; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM 2.14rc0 for DOS

; DOS Program Prefix Segment Offset Definitions
; byte, CP/M exit INT 20h
%idefine PSP_INT20      0x00

; word, Segment of the first byte beyond the program
%idefine PSP_MEMTOP     0x02

; 5 bytes, Far call to DOS Function Dispatcher
%idefine PSP_DOSCALL    0x05

; dword, Terminate address for parent program
%idefine PSP_TERMINATE  0x0A

; dword, Control-Break address for parent program
%idefine PSP_BREAK      0x0E

; dword, Critical error address for parent program
%idefine PSP_ERROR      0x12

; word, Parent program PSP Segment
%idefine PSP_PARENT     0x16

; word, Environment Segment
%idefine PSP_ENV        0x2c

; byte, Number of bytes in command line
%idefine PSP_CMDLEN     0x80

; command line, ends in 0x0d
%idefine PSP_CMDLN      0x81

%imacro SHELLEXECBLOCK 0
        .ENVIRONMENT    resw 1
        .COMMANDPTR     resd 1
        .FCB1           resd 1
        .FCB2           resd 1
        .STACKPTR       resd 1
        .CODEPTR        resd 1
        .EXECLINE       resb 1 + 128 ; Not part of actual Paramblock
        .SAVESTACK      resd 1 ; Not part of actual Paramblock
%endmacro

struc tPARAMBLOCK
    SHELLEXECBLOCK
endstruc

%idefine PARAMBLOCK(x) tPARAMBLOCK. %+ x

; DOS Functions
%imacro DOS_Terminate 0-1
    %if %0 = 0
        mov         ax, 0x4c00
    %elifidni %1, al
        mov         ah, 0x4c
    %else
        mov         ah, 0x4c
        mov         al, %1
    %endif
    int             0x21
%endmacro


%imacro DOS_PrintString 0-1
    ; DS:DX = string pointer, string ends in $ character
    mov         ah, 0x09
    %ifnidni %1, dx
        mov     dx, %1
    %endif
    int         0x21
%endmacro

