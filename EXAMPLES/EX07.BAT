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
set EX07_InDOSBox=y
echo. | set /p EX07_InDOSBox=
if "%EX07_InDOSBox%" == "y" goto DOSBox
goto NotDOSBox

:DOSBox
echo This example will not work inside DOSBox or without "SET /P"
goto DontDoAnything

:NotDOSBox
echo No| set /p EX07_InDOSBox=
if not "%EX07_InDOSBox%" == "No" goto DOSBox

:StartBatch
vcls
set EX07_COUNTER=1
vecho "Counting to 10"

:LoopBatch
vecho /bGray /f %EX07_COUNTER% %EX07_COUNTER%
vmath %EX07_COUNTER% + 1 | set /p EX07_COUNTER=
if not "%EX07_COUNTER%" == "11" goto LoopBatch

REM Do Some Stuff Here

:DoneBatch
vecho Done.

REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

REM Restore the original cursor size and shape.
set EX07_InDOSBOX=

:DontDoAnything