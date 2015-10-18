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
set EX10_InDOSBox=y
echo. | set /p EX10_InDOSBox=
if "%EX10_InDOSBox%" == "y" goto DOSBox
goto NotDOSBox

:DOSBox
set EX10_CURSOR=small
goto StartBatch

:NotDOSBox
echo No| set /p EX10_InDOSBox=
if not "%EX10_InDOSBox%" == "No" goto DOSBox
vcursor | set /p EX10_CURSOR=
goto StartBatch

:StartBatch
vcursor hide

REM Clear entire screen and fill with character 0xb0.
REM ASCII values can easily be found using the "vinfo ascii" to display
REM the ascii/hex table.
vcls /fGray /bBlue /c0xb0

REM Draw a frame to contain our question and choices
vframe /x20 /y7 /h12 /w40 /fBlack /bGray Single Shadow

REM Cursor is inside frame by default. So, just ask our question.
vecho
vecho /fBlue "  Do you like pizza?"

REM Separate the question from choices.
vline hidden

vgotoxy /x21/y11

REM Display the choices.
vecho /fBlack /bGray "  Leave me alone."
vecho /fBlack /bGray "  Absolutely!"
vecho /fBlack /bGray "  Only on "/fGreen "Thursdays."
vecho /fBlack /bGray "  Never on " /fRed "Wednesdays."
vecho
vecho /fBlack /bGray "  How dare you ask me such a thing!"

REM Polling should start at 1.
set POLLING=1
:PollingLoop

REM vchoice will use the use the current cursor location to detect the
REM the background color. So move cursor to end and use that color.
vgotoxy /x40/y11 /l eop
vchoice /fLightGreen /bBlack /t15 /d5 /p %POLLING%

REM errorlevel 101-199 is a Polling result, not a selection.
if errorlevel 105 goto POLLING105
if errorlevel 104 goto POLLING104
if errorlevel 103 goto POLLING103
if errorlevel 102 goto POLLING102
if errorlevel 101 goto POLLING101

REM error 100 is always a bad parameter regardless of what tool is called.
if errorlevel 100 goto AbortBatch

if errorlevel 5 goto CHOICE5
if errorlevel 4 goto CHOICE4
if errorlevel 3 goto CHOICE3
if errorlevel 2 goto CHOICE2
if errorlevel 1 goto CHOICE1

REM Should never get here.
goto AbortBatch

:POLLING101
set POLLING=1
vframe /w60/h3/c/y21 /a0x17 hidden shadow
vecho /n /fWhite "Choice 1 - Don't bug me!"
goto PollingLoop

:POLLING102
set POLLING=2
vframe /w60/h3/c/y21 /a0x17 hidden shadow
vecho /n /fLightCyan "Choice 2 - Awesome, lets eat!"
goto PollingLoop

:POLLING103
set POLLING=3
vframe /w60/h3/c/y21 /a0x17 hidden shadow
vecho /n /fLightMagenta "Choice 3 - I'm antisocial."
goto PollingLoop

:POLLING104
set POLLING=4
vframe /w60/h3/c/y21 /a0x17 hidden shadow
vecho /n /fLightGreen "Choice 4 - I'm on a diet."
goto PollingLoop

:POLLING105
set POLLING=5
vframe /w60/h3/c/y21 /a0x17 hidden shadow
vecho /n /fLightRed "Choice 5 - I'm offended you would ask."
goto PollingLoop

:CHOICE5
vcls /fWhite /bBlack
vecho "Choice 5"
vdelay 2000
goto DoneBatch

:CHOICE4
vcls /fWhite /bBlack
vecho "Choice 4"
vdelay 2000
goto DoneBatch

:CHOICE3
vcls /fWhite /bBlack
vecho "Choice 3"
vdelay 2000
goto DoneBatch

:CHOICE2
vcls /fWhite /bBlack
vecho "Choice 2"
vdelay 2000
goto DoneBatch

:CHOICE1
vcls /fWhite /bBlack
vecho "Choice 1"
vdelay 2000
goto DoneBatch

:DoneBatch
REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

vcls /a0x07

REM Restore the original cursor size and shape.
vcursor %EX10_CURSOR%
set EX10_InDOSBOX=
set EX10_CURSOR=

:DontDoAnything