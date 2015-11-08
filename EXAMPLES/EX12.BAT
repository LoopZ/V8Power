@echo off

goto StartBatch

* Englishese Stuff *

HELLO.EN="Hello my friend."
WORK.EN="Doing Stuff with '%1'..."
BYE.EN="Later Dude!"

* Broken Spanish Stuff *

HELLO.ES="Buenos dias amigo."
WORK.ES="Hacer cosas con '%1'..."
BYE.ES="Asta la vista!"

* The Batch file *
:StartBatch

REM Test for Presence of V8Power Tools
if errorlevel 255 goto ClearError

:CheckPresence
verrlvl 255
if errorlevel 255 goto V8Present

:V8Missing
echo V8Power Tools were not found.
goto Done

:ClearError
verrlvl 0
if errorlevel 1 goto V8Missing

:V8Present
verrlvl 0

REM Configure the Language/String file to point to ourself.
set MYSELF=%0
if not exist %MYSELF% set MYSELF=%0.BAT
if not exist %MYSELF% goto Missing

if "%LANG%" == "" set LANG=EN

REM Show the text.
vecho /t %MYSELF% HELLO.%LANG%
vecho /t %MYSELF% WORK.%LANG% "V8Power Tools"
vecho /t %MYSELF% BYE.%LANG%
goto Done

:Missing
vecho /fRed "Unable to find myself."

:Done
set MYSELF=