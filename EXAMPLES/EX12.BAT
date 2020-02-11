@echo off

verrlvl 255
if errorlevel 255 goto ClearError

:V8Missing
echo V8Power Tools were not found.
goto DontDoAnything

:ClearError
verrlvl 0
if errorlevel 1 goto V8Missing

:V8Present
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
REM Configure the Language/String file to point to ourself.
set MySelf=%0
if not exist %MySelf% set MySelf=%0.BAT
if not exist %MySelf% goto Missing

set MyLang=%LANG%
if "%MyLang%" == "es" set MyLang=ES
if not "%MyLang%" == "ES" set MyLang=EN

REM Show the text.
vecho /t %MySelf% HELLO.%MyLang%
vecho /t %MySelf% WORK.%MyLang% "V8Power Tools"
vecho /t %MySelf% BYE.%MyLang%
goto Done

:Missing
vecho /fRed "Unable to find MySelf."

:Done
set MySelf=
set MyLang=
