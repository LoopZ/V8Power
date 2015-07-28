@echo off

if not exist BIN call mkDemo.bat

cd bin

rem redirect does not work in dos box
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
