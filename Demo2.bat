@echo off

if not exist BIN\NUL goto MakeDemo
goto Maybe

:MakeDemo
if not exist mkV8.bat goto NoJoy
call mkV8.bat

:Maybe
if not exist BIN\VCURSOR.COM goto NoJoy
goto LetsGo

:NoJoy
echo Unable to do demo.
goto Done

:LetsGo

cd bin

rem redirect does not work in DosBox, so preset it to small
set CURSOR=small
vcursor | set /p CURSOR=
vcursor hide

rem vdelay 2000

vcls /fGray /bBlue /c 0xb0
rem Title Bar
vgotoxy /x1/y1
vcls /bGray /fBlack EOL
vgotoxy /x 28 /y 1
vecho /FBlack "V8Power " /fRed '1.0' /fBlack " Installation"


vframe /bGray /fRed /x20 /y8 /w40 /h10 Single Shadow
vcls /L /fBlack
vecho "Blah, Blah, Blah, Blah, Blah, Blah, Blah."

rem Temporary bottom menu bar
vgotoxy /x1/y25
vcls /bGray /fBlack EOL
vgotoxy /g /x2 /y25
vecho /n "Previous " /fWhite "(" /fRed "Alt+P" /fWhite ")"
vecho /n " | "
vecho /n "Next " /fWhite "(" /fRed "Alt+N" /fWhite ")"
vgotoxy /x68 /y25
vecho /n "Quit " /fWhite "(" /fRed "Alt+Q" /fWhite ")"

rem back to Center Frame
vgotoxy /g /x21 /y9
vgotoxy /l eot next next
vecho /fRed "More, more more more."

vdelay 3000
vcls text
vdelay 1000
vcls 	/a0x07
vecho Goodbye...
rem restore the cursor size and shape
vcursor %CURSOR%
set CURSOR=
cd ..
:Done