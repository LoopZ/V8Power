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
REM Test if running under the standard DOSBox command shell or if any other
REM command shell that does not support SET /P
set SetPCheck=n
echo. | set /p SetPCheck=
if "%SetPCheck%" == "n" goto SmallCursor
echo y| set /p SetPCheck=
if "%SetPCheck%" == "y" goto SaveCursor

:SmallCursor
set SavedCursor=small
goto StartBatch

:SaveCursor
vcursor | set /p SavedCursor=

:StartBatch
vcursor hide

REM Do Some Stuff Here
echo Cursor hidden with a 2 second delay
vdelay 2000

:CleanUpBatch
REM Restore the cursor size and shape.
vcursor %SavedCursor%
set SetPCheck=
set SavedCursor=

:DontDoAnything