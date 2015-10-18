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
set EX02_InDOSBox=y
echo. | set /p EX02_InDOSBox=
if "%EX02_InDOSBox%" == "y" goto DOSBox
goto NotDOSBox

:DOSBox
set EX02_CURSOR=small
goto StartBatch

:NotDOSBox
echo No| set /p EX02_InDOSBox=
if not "%EX02_InDOSBox%" == "No" goto DOSBox
vcursor | set /p EX02_CURSOR=
goto StartBatch

:StartBatch
vcursor hide

REM Do Some Stuff Here

:DoneBatch
REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

REM Restore the original cursor size and shape.
vcursor %EX02_CURSOR%
set EX02_InDOSBOX=
set EX02_CURSOR=

:DontDoAnything