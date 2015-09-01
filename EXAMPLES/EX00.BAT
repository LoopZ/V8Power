@echo off

if errorlevel 255 goto ClearError

:CheckPresence
verrlvl 255
if errorlevel 255 goto V8Present
goto V8Missing

:ClearError
verrlvl 0
if errorlevel 1 goto V8Missing

:V8Present
echo V8Power Tools are installed.
verrlvl 0

REM Do Some Stuff Here

goto Done

:V8Missing
echo V8Power Tools were not found.

:Done
