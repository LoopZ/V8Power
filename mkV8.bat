@echo off

set ASM=NASM.EXE
if exist %DOSDIR%\LINKS\NASM.BAT set ASM=call NASM
if exist %DOSDIR%\LINKS\NASM.COM set ASM=NASM.COM

if not "%1" == "" goto %1
if not "%1" == "" goto VeryEnd

if "%1" == "" call mkClean.bat
if not exist BIN\NUL mkdir BIN

echo V8Power Tools for DOS!

:vcls
set VSTAGE=vcls
echo Grabbing keys...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vecho
set VSTAGE=vecho
echo Inspecting tires...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vframe
set VSTAGE=vframe
bin\vecho /g/s- "Examining " /f lightred coolant /f Gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:verrlvl
set VSTAGE=verrlvl
bin\vecho /g/s- "Studying " /f 10 "dipstick" /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vgotoxy
set VSTAGE=vgotoxy
bin\vecho /g/s- "Checking " /f yellow spark-plugs /f Gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vdelay
set VSTAGE=vdelay
bin\vecho /g/s- "Cleaning " /f 15 "air filter" /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vmath
set VSTAGE=vmath
bin\vecho /g/s- /n "Testing "
bin\vecho /g/s- /f 13 belts /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vstr
set VSTAGE=vstr
bin\vecho /g/s- "Turning " /f 10 "the key" /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vchoice
set VSTAGE=vchoice
bin\vecho /g/s- "Verifying " /f 12 "timing" /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vcursor
set VSTAGE=vcursor
bin\vecho /g/s- /n "Adjusting "
bin\vecho /g/s- /f 13 carburetor /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vprogres
set VSTAGE=vprogres
bin\vecho /g/s- "Examining " /f 9 gauges /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vinfo
set VSTAGE=vinfo
bin\vecho /g/s- "Warming " /f 0x0a "engine" /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vline
set VSTAGE=vline
bin\vecho /g/s- "Opening " /f 14 map /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:veach
set VSTAGE=veach
bin\vecho /g Planing /f10 waypoints /s-/f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vwhat
rem set VSTAGE=vwhat
rem bin\vecho /g/s- /n "Studying "
rem bin\vecho /g/s- /f 12 route /f gray ...
rem %ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
rem if ERRORLEVEL 1 goto Error
rem if not exist BIN\%VSTAGE%.COM goto Error
rem if not "%1" == "" goto Done

:vpcspkr
set VSTAGE=vpcspkr
bin\vecho /g/s- "Tuning " /f 10 radio /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vver
set VSTAGE=vver
bin\vecho /g/s- "Referencing " /f 11 "Zen and the Art of Motorcycle Maintenance" /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vpause
set VSTAGE=vpause
bin\vecho /g/s- "Dawning " /f 9 shades /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vmode
set VSTAGE=vmode
bin\vecho /g/s- "Selecting " /f 10 gear /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vask
set VSTAGE=vask
bin\vecho /g/s- "Releasing " /f 11 brakes /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vinsert
set VSTAGE=vinsert
bin\vecho /g/s- "Reving " /f 13 engine /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vfont
set VSTAGE=vfont
bin\vecho /g/s- "Spotting " /f 10 gap /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vdelete
set VSTAGE=vdelete
bin\vecho /g/s- "Engaging " /f 12 signal /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vfdutil
set VSTAGE=vfdutil
bin\vecho /g/s- "Releasing " /f 14 clutch /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

goto Skippy
:vchkbox
set VSTAGE=vchkbox
bin\vecho /g/s- "Eyeing " /f 0x0a "surroundings" /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vreadkey
set VSTAGE=vreadkey
bin\vecho /g/s- "Monitoring " /f 5 traffic /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:vview
set VSTAGE=vview
bin\vecho /g/s- "Mashing " /f 12 accelerator /f gray ...
%ASM% -ISOURCE\ SOURCE\%VSTAGE%.ASM -fbin -O9 -o BIN\%VSTAGE%.COM
if ERRORLEVEL 1 goto Error
if not exist BIN\%VSTAGE%.COM goto Error
if not "%1" == "" goto Done

:Skippy
set VSTAGE=
bin\vecho /g/s-
bin\vecho /g/s- /n /fLightCyan Vroom /fWhite "! "
bin\vecho /g/s- /n /fLightRed Vroom /fWhite "! "
bin\vecho /g/s- /fYellow "Lets roll" /fWhite "! " /fGray

goto Done
:Error
echo Error creating utility %VSTAGE%.com.
goto VeryEnd

:Done
if not "%1" == "" echo.

if not "%1" == "" dir BIN\%1.COM | grep -i "%1"
if "%2" == "" goto NoMore
%0 %2 %3 %4 %5 %6 %7 %8 %9

:NoMore

rem if not "%1" == "" goto VeryEnd
:vdocs
if not exist BIN goto VeryEnd
copy LICENSE BIN >NUL
if exist README.TXT copy README.TXT BIN\V8POWER.TXT >NUL
if not exist README.TXT copy README.md BIN\V8POWER.md >NUL

:VeryEnd
set VSTAGE=
set ASM=

