@echo off

call mkClean.bat
call mkV8.bat

if not exist DIST mkdir DIST
copy BIN\*.* DIST
rem del BIN\*.*
rem rmdir BIN
copy LICENSE DIST
if exist README.TXT copy README.TXT DIST\V8POWER.TXT
if not exist README.TXT copy README.md DIST\V8POWER.md
