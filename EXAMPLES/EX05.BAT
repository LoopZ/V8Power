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
REM not exist and "Absolutely" will become choice 1.

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

REM error 100 is always a bad parameter regardless of what tool is called.
if errorlevel 100 goto AbortBatch

if errorlevel 4 goto CHOICE4
if errorlevel 3 goto CHOICE3
if errorlevel 2 goto CHOICE2
if errorlevel 1 goto CHOICE1

REM Should never get here.
goto AbortBatch

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
goto CleanUpBatch

:AbortBatch
REM Abort and cleanup

:CleanUpBatch
REM Clear the screen with DOS default text attribute Light Grey on Black.
vcls /a0x07

REM Restore the cursor size and shape.
vcursor %SavedCursor%
set SetPCheck=
set SavedCursor=

:DontDoAnything