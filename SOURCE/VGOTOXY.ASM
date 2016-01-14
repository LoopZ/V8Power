; Copyright (C) 2016 Jerome Shidel
;
;   This program is free software; you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation; either version 2 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License along
;   with this program; if not, write to the Free Software Foundation, Inc.,
;   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

; NASM for DOS 

%include "COMMON.INC"

ProgramMain:
    WhereXY
    mov         [CurrentXY], dx
    CommandLineParser       ; insert code for command line parsing
    GotoXY      [CurrentXY]
    Terminate 0

NoSwitch:   
    LookupParam OptionalTable
    jmp         DoWhatNow
    
SwitchQ:
    LookupParam QueryTable

DoWhatNow:
    cmp         ax, 0xffff
    je          .NotFound
    jmp         ax
.NotFound:
    WriteStr    CommandLineErrorMsg
    Terminate   100
    ret
    
XYSwitchHandlers

; LocalSwitchHandlers Don't use CurrentXY
SwitchL:
    mov     ax, [WindMin]
    mov     dx, [CurrentXY]
    add     dh, ah
    add     dl, al
    mov     [CurrentXY], dx
    mov     ah, 0x02
    mov     bh, [VideoPage]
    int     0x10
    FrameBounds
    mov     ax, [WindMin]
    mov     dx, [CurrentXY]
    sub     dh, ah
    sub     dl, al
    mov     [CurrentXY], dx
    ret
    
SwitchG:
    mov     ax, [WindMin]
    mov     dx, [CurrentXY]
    add     dh, ah
    add     dl, al
    mov     [CurrentXY], dx
    mov     ah, 0x02
    mov     bh, [VideoPage]
    int     0x10
    mov     ax, 0x0000
    mov     [WindMin], ax
    mov     ax, [ScreenMax]
    mov     [WindMax], ax
    mov     ax, [WindMin]
    mov     dx, [CurrentXY]
    sub     dh, ah
    sub     dl, al
    mov     [CurrentXY], dx
    ret

WhereXProc:
    mov         al, [CurrentXY]
    jmp         WhereOutProc
WhereYProc:
    mov         al, [CurrentXY+1]
WhereOutProc:
    inc         al
    StdOutHexByte
    StdOutCRLF
    ret
    
OptionSor:
    mov         al, 0
    mov         [CurrentX], al
    ret
    
OptionEor:
    mov         al, [WindMaxX]
    mov         ah, [WindMinX]
    sub         al, ah
    mov         [CurrentX], al
    ret
        
OptionSop:
    xor         ax, ax
    mov         [CurrentXY], ax
    ret
    
OptionEop:
    mov         ax, [WindMax]
    mov         bx, [WindMin]
    sub         ah, bh
    sub         al, bl
    mov         [CurrentXY], ax
    ret
        
OptionUp:
    mov         al, [CurrentY]
    cmp         al, 0
    je          OptionNoMove
    dec         al
    mov         [CurrentY], al
    ret
    
OptionDown:
    mov         ah, [WindMaxY]
    mov         al, [WindMinY]
    sub         ah, al
    mov         al, [CurrentY]
    cmp         al, ah
    jge         OptionNoMove
    inc         al
    mov         [CurrentY], al
    ret

OptionLeft:
    mov         al, [CurrentX]
    cmp         al, 0
    je          OptionNoMove
    dec         al
    mov         [CurrentX], al
    ret

OptionRight:
    mov         ah, [WindMaxX]
    mov         al, [WindMinX]
    sub         ah, al
    mov         al, [CurrentX]
    cmp         al, ah
    jge         OptionNoMove
    inc         al
    mov         [CurrentX], al
    ret
    ret
    
OptionNoMove:
    ret
    
OptionSot:
    mov         bx, [WindMin]
    mov         cx, [WindMax]
    sub         ch, bh
    sub         cl, bl
    xor         dx, dx
SearchStart:
    mov         [CurrentXY], dx
.TestLoop:
    push        bx
    push        cx
    push        dx
    add         dh, bh
    add         dl, bl  
    mov         ah, 0x02
    mov         bh, [VideoPage]
    int         0x10
    mov         ah, 0x08
    int         0x10
    pop         dx
    pop         cx
    pop         bx
    cmp         al, 0x20
    jne         .TestDone
    call        OptionNext
    cmp         dx, cx
    je          .TestDone
    jmp         .TestLoop
.TestDone:
    ret
    
OptionEot:
    mov         bx, [WindMin]
    mov         cx, [WindMax]
    sub         ch, bh
    sub         cl, bl
    mov         dx, cx
    xor         cx, cx
SearchEnd:
    mov         [CurrentXY], dx
.TestLoop:
    push        bx
    push        cx
    push        dx
    add         dh, bh
    add         dl, bl  
    mov         ah, 0x02
    mov         bh, [VideoPage]
    int         0x10
    mov         ah, 0x08
    int         0x10
    pop         dx
    pop         cx
    pop         bx
    cmp         al, 0x20
    jne         .TestDone
    call        OptionPrev
    cmp         dx, cx
    je          .TestDone
    jmp         .TestLoop
.TestDone:
    ret
    
OptionSol:
    mov         bx, [WindMin]
    mov         cx, [WindMax]
    mov         dx, [CurrentXY]
    xor         dl, dl
    sub         ch, bh
    jmp         SearchStart
    
OptionEol:
    mov         bx, [WindMin]
    mov         cx, [WindMax]
    mov         dx, [CurrentXY]
    mov         dl, cl
    sub         dl, bl
    mov         cx, dx
    xor         cl, cl
    jmp         SearchEnd
    
OptionNext:
    push        bx
    push        cx
    mov         bx, [WindMin]
    mov         cx, [WindMax]
    mov         dx, [CurrentXY]
    add         dh, bh
    add         dl, bl
    cmp         dl, cl
    jl          .MoreX
    cmp         dh, ch
    jl          .MoreY
    jmp         .Done
.MoreY: 
    mov         dl, bl
    inc         dh
    jmp         .Done
.MoreX:
    inc         dl      
.Done:  
    sub         dh, bh
    sub         dl, bl
    mov         [CurrentXY], dx
    pop         cx
    pop         bx
    ret
    
OptionPrev:
    push        bx
    push        cx
    mov         bx, [WindMin]
    mov         cx, [WindMax]
    mov         dx, [CurrentXY]
    add         dh, bh
    add         dl, bl
    cmp         dl, bl
    jg          .LessX
    cmp         dh, bh
    jg          .LessY
    jmp         .Done
.LessY: 
    mov         dl, cl
    dec         dh
    jmp         .Done
.LessX:
    dec         dl      
.Done:  
    sub         dh, bh
    sub         dl, bl
    mov         [CurrentXY], dx
    pop         cx
    pop         bx
    ret
    ret
    
    HelpSwitchHandler

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch  
    SwitchData 'Q', 1, SwitchQ
    XYSwitchData
    LocalSwitchData
    HelpSwitchData
    SwitchData  0,  0, 0
    
QueryTable:
    TableData "X", WhereXProc
    TableData "WHEREX", WhereXProc
    TableData "Y", WhereYProc
    TableData "WHEREY", WhereYProc
    TableEnd    

OptionalTable:
    TableData "SOL",OptionSol
    TableData "EOL",OptionEol
    TableData "SOR",OptionSor
    TableData "EOR",OptionEor
    TableData "SOP",OptionSop
    TableData "EOP",OptionEop
    TableData "SOT",OptionSot
    TableData "EOT",OptionEot
    TableData "UP",OptionUp
    TableData "DOWN",OptionDown
    TableData "LEFT",OptionLeft
    TableData "RIGHT",OptionRight
    TableData "NEXT",OptionNext
    TableData "PREVIOUS",OptionPrev
    TableEnd
    