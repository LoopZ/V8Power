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
pause
vcls /b Blue /f Yellow
pause
vcls /b Green /f LightCyan
pause
vcls /a 0x07

vcursor %CURSOR%
set CURSOR=
cd ..
:Done