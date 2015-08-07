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

rem goto SkipPartA

vcls /fGray /bBlue /c 0xb0
rem Title Bar
vgotoxy /x1/y1
vcls /b Gray /f Black EOL
vgotoxy /x 28 /y 1
vecho /f Black "Something " /fRed '1.0' /fBlack " Installation"

rem Temporary bottom menu bar
vgotoxy /x1/y25
vcls /bGray /fBlack /c0 EOL
vgotoxy /g /x2 /y25
vecho /n  "Previous " /fWhite "(" /fRed "Alt+P" /fWhite ")"
vgotoxy right
vecho /n "|"
vgotoxy right
vecho /n "Next " /fWhite "(" /fRed "Alt+N" /fWhite ")"
vgotoxy /x68 /y25
vecho /n "Quit " /fWhite "(" /fRed "Alt+Q" /fWhite ")"
vdelay 1000

rem make top left frame and put some text there
vframe /bGray /fBlue /x4 /y5 /w35 /h10 Single Shadow
vcls /L /fBlack
vecho "Top Left frame."

rem make top right frame and put some text there
vframe /bGray /fRed /x42 /y5 /w35 /h10 Double Shadow
vcls /L /fBlack
vecho "Top Right frame."
vpcspkr 200:200 200 200:200 200 200:200 200
vpcspkr	150:100 100 250:100 100 200:200 200
vpcspkr 150:100 100 250:100 100 200:200 200 0

rem Progress bar frame
vframe /bBlue /fLightCyan /x6 /y18 /w70 /h3 Hidden Shadow
vprogress 0 left

rem back to Top Left Frame
vgotoxy /g /x5 /y6 
vgotoxy /l eot next next
vecho /fRed "Blah, Blah, Blah."
vdelay 500
vgotoxy /x7 /y19
vprogress 1 left

rem back to Top Left Frame
vgotoxy /g /x43 /y6 
vgotoxy /l eot next next
vecho /fBlue "Blah, Blah, Blah."
vdelay 500
vgotoxy /x7 /y19
vprogress 2 left

rem back and forth a bit
vgotoxy /x 5 /y 6 /l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 3 left

vgotoxy /x43/y6 /l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 4 left

vgotoxy /x5/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 5 right
vgotoxy /x43/y6/l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 6 right
vgotoxy /x5/y6/l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 7 right
vgotoxy /x43/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 8 right
vgotoxy /x5/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 9 right
vgotoxy /x43/y6/l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 10 right
vgotoxy /x5/y6/l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 11
vgotoxy /x43/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 12
vgotoxy /x5/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogress 15
vgotoxy /x43/y6/l eot next next
vecho /fBlue "More, More, More."

vgotoxy /x7 /y19
vprogress 49
vdelay 500
vgotoxy /x7 /y19
vprogress 50
vdelay 500
vgotoxy /x7 /y19
vprogress 51
vdelay 500
vgotoxy /x7 /y19
vprogress 52
vdelay 500

vgotoxy /x5/y6/l eot 
vecho
vecho
vecho /fBlue "Faster, faster and faster."
vgotoxy /x43/y6/l eot
vecho
vecho
vecho /fRed "Faster, faster and faster."
vgotoxy /x5/y6/l eot next next
vecho /fRed "Faster, faster and faster."
vgotoxy /x43/y6/l eot next next
vecho /fBlue "Faster, faster and faster."
vgotoxy /x5/y6/l eot next next
vecho /fBlue "Faster, faster and faster."
vgotoxy /x43/y6/l eot next next
vecho /fRed "Faster, faster and faster."
vgotoxy /x5/y6/l eot next next
vecho /fRed "Faster, faster and faster."
vgotoxy /x43/y6/l eot next next
vecho /fBlue "Faster, faster and faster."
vgotoxy /x5/y6/l eot next next
vecho /fBlue "Faster, faster and faster."
vgotoxy /x43/y6/l eot next next
vecho /fRed "Faster, faster and faster."
vgotoxy /x5/y6/l eot next next
vecho /fRed "Faster, faster and faster."
vgotoxy /x43/y6/l eot next next
vecho /fBlue "Faster, faster and faster."

vgotoxy /x7 /y19
vprogress 98
vdelay 1000
vgotoxy /x7 /y19
vprogress 99
vdelay 1000
vgotoxy /x7 /y19
vprogress 100
vdelay 2000

:SkipPartA
vcls /fGray /bBlue /c 0xb0 /y2/h23

vdelay 3000

:AllDone
vcls text
vdelay 1000

vcls 	/a0x07
vecho Goodbye...
rem restore the cursor size and shape
vcursor %CURSOR%
set CURSOR=
cd ..
:Done