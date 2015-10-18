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
set EX09_InDOSBox=y
echo. | set /p EX09_InDOSBox=
if "%EX09_InDOSBox%" == "y" goto DOSBox
goto NotDOSBox

:DOSBox
echo This example will not work inside DOSBox or without "SET /P"
goto DontDoAnything

:NotDOSBox
echo No| set /p EX09_InDOSBox=
if not "%EX09_InDOSBox%" == "No" goto DOSBox
vcursor | set /p EX09_CURSOR=
goto StartBatch

:StartBatch
vcursor hide

REM Draw welcome text and 4 blank lines.
vecho /fYellow "Scanning Hard Disk Drives"
vecho
vecho
vecho
vecho

REM move up 3 lines and store location
vgotoxy up up up /Qy | set /p EX09_LINE=

REM goto end of page, start of row, then up one line
vgotoxy eop sor up

REM draw the separator line and return to location
vline
vgotoxy /y %EX09_LINE%

set EX09_COUNTER=0

:LoopBatch
REM Save Current Line
vgotoxy /Qy | set /p EX09_LINE=

REM Update Progress Bar
vgotoxy eop sor
vmath %EX09_COUNTER%  * 4 | set /p EX09_AMOUNT=
vprogress /fGreen %EX09_AMOUNT%

REM Return to screen line
vgotoxy /y %EX09_LINE%

REM Compute Drive Letter
vmath %EX09_COUNTER% + 65 | set /p EX09_DRIVE=
vstr /c %EX09_DRIVE% | set /p EX09_DRIVE=

REM Show what we are doing now.
vecho /n /fGray "Scanning Drive " /fYellow %EX09_DRIVE% /fGray "..."

REM Get the drive status.
vinfo /d %EX09_DRIVE%

if errorlevel 15 goto NoSuchDrive
if errorlevel 5 goto NotFormatted
if errorlevel 4 goto NetworkDrive
if errorlevel 3 goto DiscDrive
if errorlevel 2 goto FloppyDrive

vgotoxy /x1
vecho /n /fGray "Drive " /fWhite %EX09_DRIVE% /fGray " appears, " /fGreen "OK"
vecho /fGray "."
goto Continued

:NoSuchDrive
REM Just Ignore it.
goto Continued

:NotFormatted
vgotoxy /x1
vecho /n /fGray "Drive " /fWhite %EX09_DRIVE% /fGray " appears, "
vecho /fLightRed "UNFORMATTED" /fGray "."
goto Continued

:NetworkDrive
vgotoxy /x1
vecho /n /fGray "Drive " /fWhite %EX09_DRIVE% /fGray " is "
vecho /fLightMagenta "Remote" /fGray "."
goto Continued

:DiscDrive
vgotoxy /x1
vecho /n /fGray "Drive " /fWhite %EX09_DRIVE% /fGray " is a "
vecho /fLightCyan "CD/DVD" /fGray " drive."
goto Continued

:FloppyDrive
vgotoxy /x1
vecho /n /fGray "Drive " /fWhite %EX09_DRIVE% /fGray " uses "
vecho /fLightBlue "Removable" /fGray " media."
goto Continued

:Continued

REM Increment the counter and see if we are done.
vmath %EX09_COUNTER% + 1 | set /p EX09_COUNTER=
if not "%EX09_COUNTER%" == "26" goto LoopBatch

REM Since VCLS starts knowing entire screen, there is a better way
REM of doing this to clear the vline an vprogres bar.
vgotoxy eop /qX | set /p EX09_WIDTH=
vgotoxy up /qY | set /p EX09_LINE=

vcls /x1 /y %EX09_LINE% /h2 /w %EX09_WIDTH% /a 0x07

REM Go to Last text on screen, then start of that line.
vgotoxy eot sol

REM clear from cursor to end of line.
vcls eol

vecho
vecho "Scan complete."

:DoneBatch
REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

REM Restore the original cursor size and shape.
vcursor %EX09_CURSOR%
set EX09_CURSOR=
set EX09_COUNTER=
set EX09_AMOUNT=
set EX09_WIDTH=
set EX09_LINE=
set EX09_DRIVE=

:DontDoAnything
set EX09_InDOSBOX=
