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
set EX03_InDOSBox=y
echo. | set /p EX03_InDOSBox=
if "%EX03_InDOSBox%" == "y" goto DOSBox
goto NotDOSBox

:DOSBox
set EX03_CURSOR=small
goto StartBatch

:NotDOSBox
echo No| set /p EX03_InDOSBox=
if not "%EX03_InDOSBox%" == "No" goto DOSBox
vcursor | set /p EX03_CURSOR=
goto StartBatch

:StartBatch
vcursor hide

REM Clear entire screen and fill with character 0xb0.
REM ASCII values can easily be found using the "vinfo ascii" to display
REM the ascii/hex table.
vcls /fGray /bBlue /c0xb0

REM Draw the Title Bar
vgotoxy /x1 /y1
vcls /bGray /fBlack EOL
vgotoxy /x22 /y1
vecho /fBlack "Some kind of program " /fRed '1.2.3' /fBlack " Installer"

REM Move cursor to end of the page, then column 1. You should use this
REM method to prevent issues if the screen is not using 25 rows of text.
vgotoxy eop /x1

REM Clear from cursor to end of line using a NULL Character in preparation
REM for buttons and hot-key sequences.
vcls /bGray /fBlack /c0 EOL

REM Wait for 5 seconds
vdelay 5000

:DoneBatch
REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

REM Clear the screen with DOS default text attribute Light Grey on Black.
vcls /a0x07

REM Restore the original cursor size and shape.
vcursor %EX03_CURSOR%
set EX03_InDOSBOX=
set EX03_CURSOR=

:DontDoAnything