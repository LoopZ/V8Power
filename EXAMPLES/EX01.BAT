@echo off

REM Test for Presence of V8Power Tools 
if errorlevel 255 goto ClearError

:CheckPresence
verrlvl 255
if errorlevel 255 goto V8Present

:V8Missing
echo V8Power Tools were not found.
goto AbortBatch

:ClearError
verrlvl 0
if errorlevel 1 goto V8Missing

:V8Present
echo V8Power Tools are installed.
verrlvl 0

REM Do Some Stuff Here

:Done

:AbortBatch