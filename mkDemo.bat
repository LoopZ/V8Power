@echo off

call mkClean.bat
call mkV8.bat

cd bin
pause
vcls /b Red /f White
pause