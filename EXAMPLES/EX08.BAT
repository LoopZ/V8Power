@echo off

verrlvl 255
if errorlevel 255 goto ClearError

:V8Missing
echo V8Power Tools were not found.
goto DontDoAnything

:ClearError
verrlvl 0
if errorlevel 1 goto V8Missing

:V8Present
set SetPCheck=n
echo. | set /p SetPCheck=
if "%SetPCheck%" == "n" goto SetPFailure
echo y| set /p SetPCheck=
if not "%SetPCheck%" == "y" goto SetPFailure
vcursor | set /p SavedCursor=
goto StartBatch

:SetPFailure
set SetPCheck=
vecho Unable to run example. /fYellow "SET /P" /fGray support is required.
goto DontDoAnything

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

set MyProgress=0

:LoopBatch
REM Goto Global 40x21, Switch to Local, goto Start of Page
vgotoxy  /x40 /y21 /l sop

REM Draw Progress bar of MyProgress
vprogres /fYellow %MyProgress%

REM goto global 40x6, then local mode, end of text, next position.
vgotoxy /x40 /y6 /l eot next

REM Write ASCII 0x020 (Space) then conuter value, no CRLF.
vecho /n /fBlue /c 0x20 %MyProgress%

vmath %MyProgress% + 1 | set /p MyProgress=
if not "%MyProgress%" == "111" goto LoopBatch

vecho
vecho /fRed "You must always give 110% effort."

vdelay 3000

:DoneBatch
REM Batch file has completed.

:CleanUpBatch
set MyProgress=
vcls /a0x07
vcursor %SavedCursor%
set SetPCheck=
set SavedCursor=

:DontDoAnything