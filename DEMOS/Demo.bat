@echo off
rem Please note, the only reason this demo uses very poor and
rem inconsistent command formating, is demonstrate the flexibility
rem of the V8Power Tools option parsing.

if exist DEMOS\NUL cd DEMOS
if exist ..\BIN\VCLS.COM goto LetsGo
if exist ..\VCLS.COM goto LetsGo

:MissingTools
echo Unable to locate V8Power Tools.
echo You may need to build them using the mkV8.bat script.
goto Done

:LetsGo
cd ..
if exist BIN\VCLS.COM cd BIN

rem DosBOX Test
set DBTEST=y
echo. | set /p DBTEST=
if "%DBTEST%" == "y" goto DosBOX
vcursor | set /p MYCURSOR=
goto NotDosBOX
:DosBOX
set MYCURSOR=small
:NotDosBOX
vcursor hide

:StartUp
vcls /fGray /bBlue /c 0xb0
rem Title Bar
vgotoxy /x1/y1
vcls /b Gray /f Black EOL
vgotoxy /x 28 /y 1
vecho /f Black "Something " /fRed '1.0' /fBlack " Installation"

rem Temporary bottom menu bar
vgotoxy eop /x1
vcls /bGray /fBlack /c0 EOL
vgotoxy eop sor
vecho /n  "Previous " /fWhite "(" /fRed "Alt+P" /fWhite ")"
vgotoxy right
vecho /n "|"
vgotoxy right
vecho /n "Next " /fWhite "(" /fRed "Alt+N" /fWhite ")"
vgotoxy /x68
vecho /n "Quit " /fWhite "(" /fRed "Alt+Q" /fWhite ")"

vframe /bBlue /fGray /x16 /y7 /w48 /h11 Hidden Shadow
vframe /x18 /y7 /w44 /h11 DoubleSides
vcls /L /fYellow
vecho
vecho /fLightGreen " What would you like to see?"
vline Hidden Dumb

:TryAgain
vecho /fLightCyan  "   X. " /fYellow "Progress and Multi-Window Demo "
vecho /fLightGreen "   5) " /fYellow "Display Locations and Writing Demo "
vecho /fLightGreen "   b: " /fYellow "Cursor Movement Demo "
vecho
vgotoxy /l /x8
vecho /n /fWhite " 0" /fGray " - " /fLightRed "Return to "
vecho /n /fLightMagenta "DOS "

vchoice auto /d100/t15/fWhite/bRed

if errorlevel 4 goto AllDone
if ERRORLEVEL 3 goto PartC
if errorlevel 2 goto PartB
if errorlevel 1 goto PartA

rem goto TryAgain
goto NextPart
:PartA
vcls /fGray /bBlue /c 0xb0 /y2/h23

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
vprogres 0 left

rem back to Top Left Frame
vgotoxy /g /x5 /y6
vgotoxy /l eot next next
vecho /fRed "Blah, Blah, Blah."
vdelay 500
vgotoxy /x7 /y19
vprogres 1 left

rem back to Top Left Frame
vgotoxy /g /x43 /y6
vgotoxy /l eot next next
vecho /fBlue "Blah, Blah, Blah."
vdelay 500
vgotoxy /x7 /y19
vprogres 2 left

rem back and forth a bit
vgotoxy /x 5 /y 6 /l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 3 left

vgotoxy /x43/y6 /l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 4 left

vgotoxy /x5/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 5 right
vgotoxy /x43/y6/l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 6 right
vgotoxy /x5/y6/l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 7 right
vgotoxy /x43/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 8 right
vgotoxy /x5/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 9 right
vgotoxy /x43/y6/l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 10 right
vgotoxy /x5/y6/l eot next next
vecho /fBlue "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 11
vgotoxy /x43/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 12
vgotoxy /x5/y6/l eot next next
vecho /fRed "More, More, More."
vdelay 250
vgotoxy /x7 /y19
vprogres 15
vgotoxy /x43/y6/l eot next next
vecho /fBlue "More, More, More."

vgotoxy /x7 /y19
vprogres 49
vdelay 500
vgotoxy /x7 /y19
vprogres 50
vdelay 500
vgotoxy /x7 /y19
vprogres 51
vdelay 500
vgotoxy /x7 /y19
vprogres 52
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
vprogres 98
vdelay 1000
vgotoxy /x7 /y19
vprogres 99
vdelay 1000
vgotoxy /x7 /y19
vprogres 100
vdelay 3000

vgotoxy /x5/y6
vcls /l/fBlue
vecho "Now I will write " /fRed "V8Power Tools!"
vecho /n /fBlue "in the other box "
vecho /fBlack 10,000 /fBlue " times."
vgotoxy /x43/y6/l
vcls /l/fRed
vdelay 2000
vecho /fRed /r10000 "V8Power Tools! "
vgotoxy /x5/y6/l eot next
vecho
vecho
vecho /fRed "Pretty neat, eh?"
vdelay 2000

goto NextPart

:PartB
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
vcls /l
vdelay 2000
vecho "That was a local clear screen."
vdelay 2000
vcls /g
vdelay 1000
vecho "That was a global clear screen."
vdelay 2000

vcls /bblue
vframe /bGray /fWhite /x10/y5/w60/h15 Double
vecho "This is another box."
vdelay 1000
vgotoxy	/l /x 3 /y 3
vecho "This is Local position 3x3."
vdelay 1000
vgotoxy	/g /x 3 /y 3
vecho "This is global position 3x3."
vdelay 3000

vcls /bblue
vframe /bGray /fWhite /x15/y1/w10/h4 Double
vframe /bGray /fWhite /x5/y7/w20/h5 Double
vgotoxy /l /x1/y2
vecho "Box characters cause interesting things with the vecho command"
vgotoxy /g/x1/y1
vecho "Box characters cause interesting things with the vecho command"
vdelay 3000

vcls /b Green /f LightCyan
vecho "This screen is environmentally friendly."
vdelay 2000

goto NextPart

:PartC
vcursor Full
vcls /bblue /fwhite

vframe /bGray /fBlack /x5/y5/w70/h15 Single

vcls /l
vgotoxy /x25/y13
vecho /n "First move to start of line."
vgotoxy /l sol
vdelay 2000

vcls /l
vgotoxy /x25/y13
vecho /n "Now move to end of line."
vgotoxy /l eol
vdelay 2000

vcls /l
vgotoxy /x25/y13
vecho /n "Next move to start of row."
vgotoxy /l sor
vdelay 2000

vcls /l
vgotoxy /x25/y13
vecho /n "Now move to end of row."
vgotoxy /l eor
vdelay 2000

vcls /l
vgotoxy /x25/y13
vecho "Now move to start of page."
vgotoxy /l sop
vdelay 2000

vcls /l
vgotoxy /x25/y13
vecho "Now move to end of page."
vgotoxy /l eop
vdelay 2000

vcls /l
vgotoxy /x25/y12
vecho "Now move to start of text"
vgotoxy /x25/y14
vecho "(then -1)."
vgotoxy /l sot previous
vdelay 2000

vcls /l
vgotoxy /x25/y12
vecho "Now move to end of text"
vgotoxy /x25/y14
vecho "(then +1)."
vgotoxy /l eot next
vdelay 2000

vcls /l
vgotoxy /x15/y13
vecho /n "Finally, Lets Just move the cursor around a bit."
vdelay 1000
vgotoxy /l left
vdelay 200
vgotoxy /l left
vdelay 200
vgotoxy /l left
vdelay 200
vgotoxy /l left
vdelay 200
vgotoxy /l left
vdelay 200
vgotoxy /l left
vdelay 200
vgotoxy /l left
vdelay 200
vgotoxy /l left
vdelay 200

vgotoxy /l up
vdelay 200
vgotoxy /l up
vdelay 200
vgotoxy /l up
vdelay 200
vgotoxy /l up
vdelay 200
vgotoxy /l up
vdelay 200
vgotoxy /l up
vdelay 200

vgotoxy /l right
vdelay 200
vgotoxy /l right
vdelay 200
vgotoxy /l right
vdelay 200
vgotoxy /l right
vdelay 200
vgotoxy /l right
vdelay 200
vgotoxy /l right
vdelay 200
vgotoxy /l right
vdelay 200
vgotoxy /l right
vdelay 200

vgotoxy /l down
vdelay 200
vgotoxy /l down
vdelay 200
vgotoxy /l down
vdelay 200
vgotoxy /l down
vdelay 200
vgotoxy /l down
vdelay 200
vgotoxy /l down
vdelay 200

vdelay 1000

vcls /l
vgotoxy /x25/y13
vecho "All done."
vdelay 2000
vcursor hide
goto NextPart

:NextPart
goto StartUp

:AllDone
vcls /bBlue
vdelay 1000

vcls 	/a0x07
vecho Goodbye...
rem restore the cursor size and shape
vcursor %MYCURSOR%
set MYCURSOR=
set DOSBOX_TEST=
:Done
if not exist DEMOS cd ..
if exist DEMOS cd DEMOS
