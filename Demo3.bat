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
vcursor Full
vcls /bblue /fwhite

vframe /bGray /fBlack /x5/y5/w70/h15 Single
vgotoxy /x25/y13
vecho /n "First move to start of page."
vcls /l eol
vgotoxy /l sop
vdelay 2000

vgotoxy /x25/y13
vecho /n "Now move to end of page."
vcls /l eol
vgotoxy /l eop
vdelay 2000

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

vcls 	/a0x07
vecho Goodbye...
rem restore the cursor size and shape
vcursor %CURSOR%
set CURSOR=
cd ..
:Done