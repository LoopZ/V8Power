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
set SetPCheck=n
echo. | set /p SetPCheck=
if "%SetPCheck%" == "n" goto SetPFailure
echo y| set /p SetPCheck=
if not "%SetPCheck%" == "y" goto SetPFailure
vcursor | set /p SavedCursor=
goto StartBatch

:SetPFailure
set SetPCheck=
vecho Unable to run example. /fYellow "SET /P" /fGray support is required.
goto DontDoAnything

:StartBatch
vcursor hide

REM Clear entire screen and fill with character 0xb0.
REM ASCII values can easily be found using the "vinfo ascii" to display
REM the ascii/hex table.
vcls /fGray /bBlue /c0xb0

REM Draw a frame to contain our question and choices
vframe /x20 /y7 /h12 /w40 /fBlack /bGray Double Shadow

REM Cursor is inside frame by default. So, just ask our question.
vecho
vecho /fBlue "  Do you like pizza?"

REM Separate the question from choices.
vline hidden

REM Display the choices.
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
vchoice /fLightGreen /bBlack /t15 /d3 /q | set /p MyChoice=

REM error 100 is always a bad parameter regardless of what tool is called.
if errorlevel 100 goto AbortBatch

vcls /fGray /bBlack
vecho 'You have chosen "' /bBlue /fYellow "%MyChoice%" /fGray /bBlack /s- '"'
vdelay 2000

:DoneBatch
REM Batch file has completed.
goto CleanUpBatch

:AbortBatch
REM Abort and cleanup

:CleanUpBatch
set MyChoice=

REM Clear the screen with DOS default text attribute Light Grey on Black.
vcls /a0x07

REM Restore the cursor size and shape.
vcursor %SavedCursor%
set SetPCheck=
set SavedCursor=

:DontDoAnything