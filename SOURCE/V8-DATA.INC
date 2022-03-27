; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM 2.14rc0

DATA_SEGMENT

%idefine ApplicationDataBlock

%ifdef Require_PlaceHolderApplication
Message_PlaceHolderApplication:
    DB "This program is only a placeholder executable. ",0x0d,0x0a
    DB "Eventually, it will be replaced by a program",0x0d,0x0a
    DB "that actually does something at a later time.$"
%endif