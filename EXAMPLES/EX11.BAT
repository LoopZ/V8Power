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
set EX11_COUNTER=0x0000
vecho "Running through Vesa Modes"
vecho Press CTRL+C at any time to abort.
vpause /d 2 CTRL-C
if errorlevel 200 goto AbortBatch

:LoopBatch
vmode C80
vmode vesa | vstr /l %EX11_COUNTER% | set /p EX11_VMODE=
if "%EX11_VMODE%" == "" goto DoneBatch

vecho /n "Trying Vesa Mode %EX11_VMODE% in "
vpause /d 2 CTRL-C
if errorlevel 200 goto AbortBatch

vmode %EX11_VMODE%

vecho /n "This is Vesa Mode %EX11_VMODE%. "

REM find screen dimensions
vgotoxy eop eor
vgotoxy /Qx | set /P EX11_MAXX=
vgotoxy /Qy | set /P EX11_MAXY=
REM convert from hex to decimal
vmath %EX11_MAXX% | set /P EX11_MAXX=
vmath %EX11_MAXY% | set /P EX11_MAXY=

vgotoxy /x1 /y2
vecho /fYellow :-) /p /fLightGreen Supports /fGray %EX11_MAXX% x %EX11_MAXY% text.

vpause /d 2 CTRL-C
if errorlevel 200 goto AbortBatch

vmath %EX11_COUNTER% + 1 /h | set /p EX11_COUNTER=
if not "%EX11_COUNTER%" == "1000" goto LoopBatch

:DoneBatch
vmode C80
vecho Done.
goto CleanUpBatch

:AbortBatch
vmode C80
vecho /fLightRed Aborted!
REM Abort and cleanup

:CleanUpBatch
set SetPCheck=
set EX11_COUNTER=
set EX11_VMODE=
set EX11_MAXX=
set EX11_MAXY=

:DontDoAnything