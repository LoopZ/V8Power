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
set EX05_InDOSBox=yes
echo. | set /p EX05_InDOSBox=
if "%EX01_InDOSBox%" == "yes" goto DOSBox
goto NotDOSBox

:DOSBox
set EX05_CURSOR=small
goto StartBatch

:NotDOSBox
vcursor /q | set /p EX05_CURSOR=
goto StartBatch

:StartBatch
vcursor hide

REM Clear entire screen and fill with character 0xb0.
REM ASCII values can easily be found using the "vinfo ascii" to display
REM the ascii/hex table.
vcls /fGray /bBlue /c0xb0

REM Draw a frame to contain our question and choices
vframe /x20 /y7 /h11 /w40 /fBlack /bGray Single Shadow

REM Cursor is inside frame by default. So, just ask our question.
vecho 
vecho /fBlue "  Do you like pizza?"

REM Separate the question from choices.
vline hidden

REM Display the choices.
REM Note: if you write do many choices, they will begin to scroll off. So,
REM the first choice "Leave me alone" will be missing and technically will
REM not exist and "Absolutely" will become choice 1
vecho "  Leave me alone."
vecho "  Absolutely!"
vecho "  Only on "/fGreen "Thursdays."
vecho "  Never on " /fRed "Wednesdays."
vecho
vecho "  How dare you ask me such a thing!"

REM vchoice will use the use the current cursor location to detect the 
REM area that contains the choices. Since the cursor is still inside the
REM frame and below the line, we can just call vchoice and set it's 
REM selected color and default value.
vchoice /fLightGreen /bBlack /t15 /d3

:DoneBatch
REM Batch file has completed.

:AbortBatch
REM Abort and cleanup

vcls /a0x07

REM Restore the original cursor size and shape.
vcursor %EX05_CURSOR%
set EX05_InDOSBOX=
set EX05_CURSOR=

:DontDoAnything