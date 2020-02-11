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
set SavedCursor=small
set SetPCheck=n
echo. | set /p SetPCheck=
if "%SetPCheck%" == "n" goto StartBatch
echo y| set /p SetPCheck=
if not "%SetPCheck%" == "y" goto StartBatch
vcursor | set /p SavedCursor=

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

:CleanUpBatch
REM Clear the screen with DOS default text attribute Light Grey on Black.
vcls /a0x07

REM Restore the cursor size and shape.
vcursor %SavedCursor%
set SetPCheck=
set SavedCursor=

:DontDoAnything