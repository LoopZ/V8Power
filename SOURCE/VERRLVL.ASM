; Copyright (C) 2016-2022 Jerome Shidel
; Open source see License file

; NASM for DOS

%idefine NoVideoOutput

%include "COMMON.INC"

    CommandLineParser       ; insert code for command line parsing

    mov     al, [ExitCode]
    Terminate al

NoSwitch:
    NumberParam
    mov     [ExitCode], al
    ret

    HelpSwitchHandler 'verrlvl'

CommandLineSwitches:
    SwitchData  0,  0, NoSwitch
    HelpSwitchData
    SwitchData  0,  0, 0

ExitCode:
    db 0
