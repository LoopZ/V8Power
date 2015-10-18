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
set EX04_InDOSBox=y
echo. | set /p EX04_InDOSBox=
if "%EX04_InDOSBox%" == "y" goto DOSBox
goto NotDOSBox

:DOSBox
set EX04_CURSOR=small
goto StartBatch

:NotDOSBox
echo No| set /p EX04_InDOSBox=
if not "%EX04_InDOSBox%" == "No" goto DOSBox
vcursor | set /p EX04_CURSOR=
goto StartBatch

:StartBatch
vcursor hide

REM Clear entire screen and fill with character 0xb0.
REM ASCII values can easily be found using the "vinfo ascii" to display
REM the ascii/hex table.
vcls /fCyan /bBlue /c0xb0

REM Move cursor to end of page, then start of line
vgotoxy eop sol
vecho /n /fWhite "Press a key to continue... "
vpause /fYellow /t10

:DoneBatch
REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

vcls /a0x07

REM Restore the original cursor size and shape.
vcursor %EX04_CURSOR%
set EX04_InDOSBOX=
set EX04_CURSOR=

:DontDoAnything