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
set EX11_InDOSBox=y
echo. | set /p EX11_InDOSBox=
if "%EX11_InDOSBox%" == "y" goto DOSBox
goto NotDOSBox

:DOSBox
echo This example will not work inside DOSBox or without "SET /P"
goto DontDoAnything

:NotDOSBox
echo No| set /p EX11_InDOSBox=
if not "%EX11_InDOSBox%" == "No" goto DOSBox

:StartBatch
set EX11_COUNTER=0x0000
vecho "Running through Vesa Modes"

:LoopBatch
vmode C80
vmode vesa | vstr /l %EX11_COUNTER% | set /p EX11_VMODE=
if "%EX11_VMODE%" == "" goto DoneBatch

vecho /n "Trying Vesa Mode %EX11_VMODE% in "
vpause /t 2

vmode %EX11_VMODE%

vecho /n "This is Vesa Mode %EX11_VMODE%. "
vpause /t 2

vmath %EX11_COUNTER% + 1 /h | set /p EX11_COUNTER=
if not "%EX11_COUNTER%" == "1000" goto LoopBatch

REM Do Some Stuff Here

:DoneBatch
vecho Done.

REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

REM Restore the original cursor size and shape.
set EX11_InDOSBOX=
set EX11_VMODE=

:DontDoAnything
