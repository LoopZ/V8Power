@echo off

REM Test for Presence of V8Power Tools

:CheckPresence
verrlvl 255
if errorlevel 255 goto ClearError

:V8Missing
echo V8Power Tools were not found.
goto DontDoAnything

:ClearError
verrlvl 0
if errorlevel 1 goto V8Missing
echo V8Power Tools are installed.

:StartBatch
REM Do Some Stuff Here

:DontDoAnything
