@echo off

REM Test for Presence of V8Power Tools
if errorlevel 255 goto ClearError

:CheckPresence
verrlvl 255
if errorlevel 255 goto V8Present

:V8Missing
echo V8Power Tools were not found.
goto DontDoAnything

:ClearError
verrlvl 0
if errorlevel 1 goto V8Missing

:V8Present
verrlvl 0

REM Test if running under DOSBox
set EX08_InDOSBox=y
echo. | set /p EX08_InDOSBox=
if "%EX08_InDOSBox%" == "y" goto DOSBox
goto NotDOSBox

:DOSBox
echo This example will not work inside DOSBox or without "SET /P"
goto DontDoAnything

echo No| set /p EX08_InDOSBox=
if not "%EX08_InDOSBox%" == "No" goto DOSBox
vcursor | set /p EX08_CURSOR=
goto StartBatch

:StartBatch
vcursor hide

REM Clear entire screen and fill with character 0xb0.
REM ASCII values can easily be found using the "vinfo ascii" to display
REM the ascii/hex table.
vcls /fGreen /bBlue /c0xb0

REM Draw a frame to contain text and such.
vframe /h10 /w40 /c /y 5 /fBlack /bGray Double Shadow
vecho /fRed "Doing Progress"

REM Draw a frame to contain progress bar.
vframe /w60 /h3 /c /y20 /bBlue /fYellow Hidden Shadow

set EX08_COUNTER=0

:LoopBatch
REM Goto Global 40x21, Switch to Local, goto Start of Page
vgotoxy  /x40 /y21 /l sop

REM Draw Progress bar of COUNTER
vprogres /fYellow %EX08_COUNTER%

REM goto global 40x6, then local mode, end of text, next position.
vgotoxy /x40 /y6 /l eot next

REM Write ASCII 0x020 (Space) then conuter value, no CRLF.
vecho /n /fBlue /c 0x20 %EX08_COUNTER%

vmath %EX08_COUNTER% + 1 | set /p EX08_COUNTER=
if not "%EX08_COUNTER%" == "111" goto LoopBatch

vecho
vecho /fRed "You must always give 110% effort."

vdelay 3000

:DoneBatch
REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

vcls /a0x07

REM Restore the original cursor size and shape.
vcursor %EX08_CURSOR%
set EX08_CURSOR=
set EX08_COUNTER=

:DontDoAnything
set EX08_InDOSBOX=
