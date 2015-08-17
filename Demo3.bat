@echo off
rem Please note, the only reason this demo uses very poor and 
rem inconsistent command formating, is demonstrate the flexibility
rem of the V8Power Tools option parsing.

rem check for bin directory
if not exist BIN\NUL goto MakeDemo
goto LetsGo

rem build binaries
:MakeDemo
if not exist mkV8.bat goto NoJoy
call mkV8.bat
if ERRORLEVEL 1 goto NoJoy
goto LetsGo
:NoJoy
echo Unable to do demo.
goto Aborted

rem We can do demo
:LetsGo
cd bin

rem Check for DosBOX
rem DosBOX does not support I/O redirection so, cannot read values return 
rem as text from V8Power if it is running inside DosBOX.
set DBTEST=yes
echo. | set /p DBTEST=
if "%DBTEST%" == "yes" goto DosBOX
vcursor | set /p CURSOR=
goto NotDosBOX
:DosBOX
set CURSOR=small
:NotDosBOX

rem The Demo
vcursor hide
vcls /fWhite/bBlue

vline Single
vdelay 1000
vline  Double

:Done
vdelay 3000
rem Clear screen, restore the cursor size and shape
vcls 	/a0x07
vcursor %CURSOR%
set CURSOR=
set	DBTEST=
cd ..
:Aborted