@echo off

REM Test for Presence of V8Power Tools, default DOSBox command shell and
REM the presence of "SET /P" support.

verrlvl 255
if errorlevel 255 goto ClearError

:V8Missing
echo V8Power Tools were not found.
goto DontDoAnything

:ClearError
verrlvl 0
if errorlevel 1 goto V8Missing

:V8Present
REM Test if running under the standard DOSBox command shell or if any other
REM command shell that does not support SET /P
set SetPCheck=n
echo. | set /p SetPCheck=
if "%SetPCheck%" == "n" goto SetPFailure
echo y| set /p SetPCheck=
if "%SetPCheck%" == "y" goto SetPSupport

:SetPFailure
echo This Example is running using a commmand shell that does not support "SET /P".
goto StartBatch

:SetPSupport
echo Advanced "SET /P" functionality supported.
goto StartBatch

:StartBatch
REM Do Some Stuff Here

:CleanUpBatch
set SetPCheck=

:DontDoAnything