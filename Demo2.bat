@echo off
rem Please note, that the only reason this demo uses very poor and 
rem inconsistent command formating, is demonstrate the flexibility
rem of the V8Power Tools option parsing.

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

rem DosBOX Test
set DBTEST=yes
echo. | set /p DBTEST=
if "%DBTEST%" == "yes" goto DosBOX
vcursor | set /p CURSOR=
goto NotDosBOX
:DosBOX
set CURSOR=small
:NotDosBOX

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

vcls 	/a0x07
vecho Goodbye...
rem restore the cursor size and shape
vcursor %CURSOR%
set CURSOR=
set	DBTEST=
cd ..
:Done