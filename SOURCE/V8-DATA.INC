; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM 2.14rc0

DATA_SEGMENT

%idefine ApplicationDataBlock

%ifdef Require_PlaceHolderApplication
Message_PlaceHolderApplication:
    DB "This program is only a placeholder for an executable. Eventually, it will be",0x0d,0x0a
    DB "replaced by a functional program that actually does something useful. But, that",0x0d,0x0a
    DB "will not be until some time in the future. Hopefully.$"
%endif