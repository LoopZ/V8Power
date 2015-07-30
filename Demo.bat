@echo off

if not exist BIN\NUL goto MakeDemo
goto DoDemo

:MakeDemo
if not exist mkV8.bat goto NoJoy
call mkV8.bat
goto DoDemo

:NoJoy
echo Unable to do demo.
goto :Done

:DoDemo
if not exist BIN\VCURSOR.COM goto NoJoy

cd bin

rem redirect does not work in DosBox, so preset it to small
set CURSOR=small
vcursor | set /p CURSOR=

vcursor hide

pause
vcls /b Red /f White
vdelay 1000
vcls /b Green /f LightCyan
vdelay 1000
vcls /b Blue /f Yellow
vgotoxy /x20 /y20
vecho /n "You have just experienced a blue screen. " 
vdelay 1000
vecho /fGray "(" /fWhite "Of Life!" /fgray ')'
vdelay 2000
vframe /bGray /fBlack /x10/y5/w60/h10 SingleSides
vecho /fRed "There is a box on it!"
vdelay 2000
vecho /fBlue "You can write text to it!"
vdelay 1000
vcls /b Green /f LightCyan
vecho "This screen is environmently friendly."
vdelay 2000
vcls /a 0x07
vecho "Goodbye."

vcursor %CURSOR%
set CURSOR=
cd ..
:Done