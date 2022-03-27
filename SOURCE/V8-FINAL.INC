; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM 2.14rc0

CODE_SEGMENT

%ifndef Require_Terminate
    ; Terminate           0
    %idefine Require_Terminate
%endif

%ifdef Require_Terminate
    proc_Terminate:
        DOS_Terminate   al
%endif

%ifndef ApplicationDataBlock
    %include 'V8-DATA.INC'
%endif

BSS_SEGMENT

HEAP_SEGMENT