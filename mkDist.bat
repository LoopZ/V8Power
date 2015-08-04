@echo off

call mkClean.bat
call mkV8.bat

if not exist DIST mkdir DIST
copy BIN\*.* DIST
copy LICENSE DIST
if exist README.TXT copy README.TXT DIST
if not exist README.TXT copy README.md DIST
