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
vdelay 500
vcls /b Green /f LightCyan
vdelay 500
vcls /b Blue /f Yellow
vgotoxy /x20 /y20
vecho /n "You have just experienced a blue screen. " 
vdelay 3000
vecho /fGray "(" /fWhite "Of Life!" /fgray ')'
vdelay 2000
vframe /bGray /fBlack /x10/y5/w60/h8 Single
vecho /fRed "There is a box on it!"
vdelay 2000
vecho /fBlue "You can write text to it!"
vdelay 2000
vecho /n /fBlue "and more text!"
vdelay 1000
vecho /fRed "and more!"
vdelay 500
vecho /fRed "and more!"
vdelay 500
vecho /fRed "and more!"
vdelay 500
vecho /fBrown "(Oops, I ran out of room. So, I had to scroll a little.)" /fred "and more!"
vdelay 1000
vecho /n /fRed "and more!"
vdelay 1000
vgotoxy /x 30 /y 15
vecho /fRed /bWhite " Or not "
vdelay  2000
vecho "The text goes where you want it to!"
vdelay  1000
vecho "With very little effort."
vdelay  2000
vcls /b red
vframe /bBlue /fCyan /x20/y10/w40/h6 Double
vecho "This box has double sides box."
vdelay  3000
vframe /bBlue /fYellow /x20/y10/w40/h6 SingleSides
vecho "This box has single sides and double top and bottom edges."
vdelay  3000
vframe /bBlue /fWhite /x20/y10/w40/h6 DoubleSides
vecho "This box has double sides and single top and bottom edges."
vdelay  3000
vframe /bBlue /fLightGreen /x20/y10/w40/h6 Hidden
vecho "This hidden edge box. Great for making text areas with margins."
vdelay 3000
vcls /b Green /f LightCyan
vecho "This screen is environmently friendly."
vdelay 2000
vcls /a 0x07
vecho "Goodbye."

vcursor %CURSOR%
set CURSOR=
cd ..
:Done