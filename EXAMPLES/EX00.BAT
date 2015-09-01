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
echo V8Power Tools are installed.
verrlvl 0

:StartBatch
REM Do Some Stuff Here

:DoneBatch
REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

:DontDoAnything
