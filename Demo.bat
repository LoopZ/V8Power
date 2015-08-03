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
vecho /FBlack "Something " /fRed '1.0' /fBlack " Installation"

rem Temporary bottom menu bar
vgotoxy /x1/y25
vcls /bGray /fBlack EOL
vgotoxy /g /x2 /y25
vecho /n "Previous " /fWhite "(" /fRed "Alt+P" /fWhite ")"
vecho /n " | "
vecho /n "Next " /fWhite "(" /fRed "Alt+N" /fWhite ")"
vgotoxy /x68 /y25
vecho /n "Quit " /fWhite "(" /fRed "Alt+Q" /fWhite ")"
vdelay 1000

rem make top left frame and put some text there
vframe /bGray /fRed /x4 /y5 /w35 /h10 Single Shadow
vcls /L /fBlack
vecho "Top Left frame."

rem make top right frame and put some text there
vframe /bGray /fRed /x42 /y5 /w35 /h10 Double Shadow
vcls /L /fBlack
vecho "Top Right frame."
vpcspkr 200:200 200 200:200 200 200:200 200
vpcspkr	150:100 100 250:100 100 200:200 200
vpcspkr 150:100 100 250:100 100 200:200 200 0

rem back to Top Left Frame
vgotoxy /g /x5 /y6 
vgotoxy /l eot next next
vecho /fRed "Blah, Blah, Blah."
vdelay 500

rem back to Top Left Frame
vgotoxy /g /x43 /y6 
vgotoxy /l eot next next
vecho /fBlue "Blah, Blah, Blah."
vdelay 500

rem back and forth a bit
vgotoxy /g /x5 /y6 /l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /g /x43 /y6 /l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /g /x5 /y6 /l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /g /x43 /y6 /l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /g /x5 /y6 /l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /g /x43 /y6 /l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /g /x5 /y6 /l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /g /x43 /y6 /l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /g /x5 /y6 /l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /g /x43 /y6 /l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /g /x5 /y6 /l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /g /x43 /y6 /l eot next next
vecho /fBlue "More, More, More."
vdelay 250

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