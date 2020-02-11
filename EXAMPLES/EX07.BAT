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
vcls
set MyCounter=0
vecho "Counting from 0 to 15" /p

:LoopBatch
vecho "Number " /bGray /f %MyCounter% "%MyCounter% " /fGray /bBlack 8^)
vmath %MyCounter% + 1 | set /p MyCounter=
if not "%MyCounter%" == "16" goto LoopBatch

:DoneBatch
vecho

:CleanUpBatch
set MyCounter=
set SetPCheck=

:DontDoAnything