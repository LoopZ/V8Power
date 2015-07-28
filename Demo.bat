@echo off

if not exist BIN call mkDemo.bat

cd bin
pause
vcls /b Red /f White
pause
vcls /a 0x07
cd ..