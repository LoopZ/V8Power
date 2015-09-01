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
set EX02_InDOSBox=yes
echo. | set /p EX02_InDOSBox=
if "%EX01_InDOSBox%" == "yes" goto DOSBox
goto NotDOSBox

:DOSBox
set EX02_CURSOR=small
goto StartBatch

:NotDOSBox
vcursor /q | set /p EX02_CURSOR=
goto StartBatch

:StartBatch
vcursor hide

REM Do Some Stuff Here

:DoneBatch

:AbortBatch

REM Restore the original cursor size and shape.
vcursor %EX02_CURSOR%
set EX02_InDOSBOX=
set EX02_CURSOR=

:DontDoAnything