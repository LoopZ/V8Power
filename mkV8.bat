@echo off

:Start
set MKV8_SELF=%0
if not exist %MKV8_SELF% set MKV8_SELF=%0.BAT
if exist %MKV8_SELF% goto Begin
set MKV8_STAGE=
echo Unable to locate this script for compiler messages.
goto ERROR

:Begin
set MKV8_ASM=NASM.EXE
if exist %DOSDIR%\LINKS\NASM.BAT set MKV8_ASM=call NASM
if exist %DOSDIR%\LINKS\NASM.COM set MKV8_ASM=NASM.COM

if not "%1" == "" goto %1
if not "%1" == "" goto AllDone

if "%1" == "" call mkClean.bat
if not exist BIN\NUL mkdir BIN

echo V8Power Tools for DOS!
echo.
call %MKV8_SELF% PreCompile VECHO
if ERRORLEVEL 1 goto Error
call %MKV8_SELF% PreCompile VFDUTIL
if ERRORLEVEL 1 goto Error
call %MKV8_SELF% PreCompile VEACH
if ERRORLEVEL 1 goto Error

:Loopy
veach /S/D SOURCE\*.ASM /X %MKV8_SELF% SubCompile *
if ERRORLEVEL 1 goto Error
goto Done

:PreCompile
set MKV8_STAGE=%2
set MKV8_CODE=%2.ASM
goto DoMessage
:SubCompile
if "%2" == "VECHO.ASM" goto VeryEnd
if "%2" == "VFDUTIL.ASM" goto VeryEnd
if "%2" == "VEACH.ASM" goto VeryEnd
set /e MKV8_STAGE=BIN\VFDUTIL.COM /n %2
if "%MKV8_STAGE" == "" goto SubCompile
set MKV8_CODE=%2
:DoMessage
if exist bin\vecho.com goto FancyMessage
echo (%MKV8_STAGE%) Cabin Fever...
goto DoCompile
:FancyMessage
vecho /g /n /fDarkGray (%MKV8_STAGE%) /fGray /t %MKV8_SELF% MSG_%MKV8_STAGE% %MKV8_STAGE%
if ERRORLEVEL 1 Echo missing message for %MKV8_STAGE%
:DoCompile

if exist BIN\%MKV8_STAGE%.COM del BIN\%MKV8_STAGE%.COM>NULL
%MKV8_ASM% -ISOURCE\ SOURCE\%MKV8_STAGE%.ASM -fbin -O9 -o BIN\%MKV8_STAGE%.COM
if ERRORLEVEL 1 goto CompileFail
if not exist BIN\%MKV8_STAGE%.COM CompileFail

:CompileOk
vecho /g /t %MKV8_SELF% MSG_SUCCESS
goto VeryEnd
:CompileFail
vecho /g /t %MKV8_SELF% MSG_FAIL
verrlvl 1>NULL
goto VeryEnd

### Displayed messages

MSG_SUCCESS=/f LightGreen /c32 Success /f Gray
MSG_FAIL=/f LightRed /c32 Failed! /f Gray
MSG_VECHO=Grabbing /fYellow keys /fGray /s- ...
MSG_VFDUTIL=Inspecting /fWhite tires /fGray /s- ...
MSG_VEACH=Examining /f lightred coolant /f Gray /s- ...
MSG_VASK=Studying /f 10 dipstick /f gray /s- ...
MSG_VCHKBOX=Checking /f yellow spark-plugs /f Gray /s- ...
MSG_VCHOICE=Cleaning /f 15 air filter /f gray /s- ...
MSG_VCLS=Testing /f 13 belts /f gray /s- ...
MSG_VCURSOR=Turning /f 10 the key /f gray /s- ...
MSG_VDELAY=Verifying /f 12 timing /f gray /s- ...
MSG_VDELETE=Adjusting /f 13 carburetor /f gray /s- ...
MSG_VERRLVL=Examining /f 9 gauges /f gray /s- ...
MSG_VFONT=Warming /f 0x0a engine /f gray /s- ...
MSG_VFRAME=Opening /f 14 map /f gray /s- ...
MSG_VGOTOXY=Planing /f10 waypoints /f gray /s- ...
MSG_VHDUTIL=Studying /f 12 route /f gray /s- ...
MSG_VINFO=Tuning /f 10 radio /f gray /s- ...
MSG_VINSERT=Referencing /f 11 Zen and the Art of Motorcycle Maintenance /f gray /s- ...
MSG_VLINE=Dawning /f 9 shades /f gray /s- ...
MSG_VMATH=Selecting /f 10 gear /f gray /s- ...
MSG_VMODE=Releasing /f 11 brakes /f gray /s- ...
MSG_VPAUSE=Reving /f 13 engine /f gray /s- ...
MSG_VPCSPKR=Spotting /f 10 gap /f gray /s- ...
MSG_VPROGRES=Engaging /f 12 signal /f gray /s- ...
MSG_VREADKEY=Releasing /f 14 clutch /f gray /s- ...
MSG_VSTR=Eyeing /f 0x0a surroundings /f gray /s- ...
MSG_VVER=Monitoring /f 5 traffic /f gray /s- ...
MSG_VVIEW=Mashing /f 12 accelerator /f gray /s- ...

:Error
if "%MKV8_STAGE%" == "" echo Script failure.
if not "%MKV8_STAGE%" == "" echo Error creating utility %MKV8_STAGE%.com.
goto AllDone

:Done
bin\vecho /g/s-
bin\vecho /g/s- /n /fLightCyan Vroom /fWhite "! "
bin\vecho /g/s- /n /fLightRed Vroom /fWhite "! "
bin\vecho /g/s- /fYellow "Lets roll" /fWhite "! " /fGray
if not exist BIN\NULL goto AllDone
copy LICENSE BIN >NUL
if exist README.TXT copy README.TXT BIN\V8POWER.TXT >NUL
if not exist README.TXT copy README.md BIN\V8POWER.md >NUL

:AllDone
set MKV8_SELF=
set MKV8_STAGE=
set MKV8_CODE=
set MKV8_ASM=

:VeryEnd
