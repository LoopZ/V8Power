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
set EX11_InDOSBox=yes
echo. | set /p EX11_InDOSBox=
if "%EX11_InDOSBox%" == "yes" goto DOSBox
goto NotDOSBox

:DOSBox
echo This example will not work inside DOSBox or without "SET /P"
goto DontDoAnything

:NotDOSBox
echo No| set /p EX11_InDOSBox=
if not "%EX11_InDOSBox%" == "No" goto DOSBox

:StartBatch
set EX11_COUNTER=0x0100
vecho "Running through Vesa Modes"
vpause /t 5

:LoopBatch
vmode %EX11_COUNTER%
vecho "This is Mode %EX11_COUNTER%"
vpause /t 5
vmath %EX11_COUNTER% + 1 /h | set /p EX11_COUNTER=
if not "%EX11_COUNTER%" == "0x0111" goto LoopBatch

REM Do Some Stuff Here

:DoneBatch
vecho Done.

REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

REM Restore the original cursor size and shape.
set EX02_InDOSBOX=

:DontDoAnything