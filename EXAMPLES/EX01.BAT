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
set EX01_InDOSBox=y
echo. | set /p EX01_InDOSBox=
if "%EX01_InDOSBox%" == "y" goto DOSBox
goto NotDOSBox

:DOSBox
echo This Example is running inside DOSBox.
goto StartBatch

:NotDOSBox
echo No| set /p EX01_InDOSBox=
if not "%EX01_InDOSBox%" == "No" goto NoSetP
echo We are not using DOSBox.
goto StartBatch

:NoSetP
echo Advanced "SET /P" not functional.
goto StartBatch

:StartBatch
REM Do Some Stuff Here

:DoneBatch
REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

set EX01_InDOSBOX=

:DontDoAnything