@echo off

if not "%1" == "" goto %1

if "%1" == "" call mkClean.bat
if not exist BIN mkdir BIN

echo V8 Power!

:vcls
set VSTAGE=vcls
echo Grabbing keys...
NASM.EXE -ISOURCE\ SOURCE\VCLS.ASM -fbin -O9 -o BIN\VCLS.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vecho
set VSTAGE=vecho
echo Inspecting tires...
NASM.EXE -ISOURCE\ SOURCE\VECHO.ASM -fbin -O9 -o bin\VECHO.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vframe
set VSTAGE=vframe
bin\vecho /g/s- "Examining " /f lightred coolant /f Gray ...
NASM.EXE -ISOURCE\ SOURCE\VFRAME.ASM -fbin -O9 -o BIN\VFRAME.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:verrlvl
set VSTAGE=vdelay
bin\vecho /g/s- "Studying " /f 10 "dipstick" /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VERRLVL.ASM -fbin -O9 -o BIN\VERRLVL.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vgotoxy
set VSTAGE=vgotoxy
bin\vecho /g/s- "Checking " /f yellow spark-plugs /f Gray ...
NASM.EXE -ISOURCE\ SOURCE\VGOTOXY.ASM -fbin -O9 -o BIN\VGOTOXY.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vdelay
set VSTAGE=vdelay
bin\vecho /g/s- "Cleaning " /f 15 "air filter" /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VDELAY.ASM -fbin -O9 -o BIN\VDELAY.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vmath
set VSTAGE=vmath
bin\vecho /g/s- /n "Studying "
bin\vecho /g/s- /f 13 belts /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VMATH.ASM -fbin -O9 -o BIN\VMATH.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vstr
set VSTAGE=vstr
bin\vecho /g/s- "Turning " /f 10 "the key" /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VSTR.ASM -fbin -O9 -o BIN\VSTR.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vchoice
set VSTAGE=vchoice
bin\vecho /g/s- "Verifying " /f 12 "timing" /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VCHOICE.ASM -fbin -O9 -o BIN\VCHOICE.COM
if not "%1" == "" goto Done

:vcursor
set VSTAGE=vcursor
bin\vecho /g/s- /n "Adjusting "
bin\vecho /g/s- /f 13 carburetor /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VCURSOR.ASM -fbin -O9 -o BIN\VCURSOR.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vprogres
set VSTAGE=vprogres
bin\vecho /g/s- "Studying " /f 9 gauges /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VPROGRES.ASM -fbin -O9 -o BIN\VPROGRES.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vinfo
set VSTAGE=vinfo
bin\vecho /g/s- "Warming " /f 0x0a "engine" /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VINFO.ASM -fbin -O9 -o BIN\VINFO.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vline
set VSTAGE=vline
bin\vecho /g/s- "Reading " /f 14 map /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VLINE.ASM -fbin -O9 -o BIN\VLINE.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vpcspkr
set VSTAGE=vpcspkr
bin\vecho /g/s- "Tuning " /f 10 radio /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VPCSPKR.ASM -fbin -O9 -o BIN\VPCSPKR.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vver
set VSTAGE=vver
bin\vecho /g/s- "Referencing " /f 11 "Zen and the Art of Motorcycle Maintenance" /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VVER.ASM -fbin -O9 -o BIN\VVER.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vpause
set VSTAGE=vpause
bin\vecho /g/s- "Dawning " /f 9 shades /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VPAUSE.ASM -fbin -O9 -o BIN\VPAUSE.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vmode
set VSTAGE=vmode
bin\vecho /g/s- "Selecting " /f 10 gear /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VMODE.ASM -fbin -O9 -o BIN\VMODE.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vask
set VSTAGE=vask
bin\vecho /g/s- "Releasing " /f 11 brakes /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VASK.ASM -fbin -O9 -o BIN\VASK.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vchkbox
set VSTAGE=vchkbox
bin\vecho /g/s- "Eyeing up " /f 0x0a "traffic" /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VCHKBOX.ASM -fbin -O9 -o BIN\VCHKBOX.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vfdutil
set VSTAGE=vfdutil
bin\vecho /g/s- "Releasing " /f 14 clutch /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VFDUTIL.ASM -fbin -O9 -o BIN\VFDUTIL.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

:vview
set VSTAGE=vview
bin\vecho /g/s- "Mashing " /f 12 accelerator /f gray ...
NASM.EXE -ISOURCE\ SOURCE\VVIEW.ASM -fbin -O9 -o BIN\VVIEW.COM
if ERRORLEVEL 1 goto Error
if not "%1" == "" goto Done

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
if not "%1" == "" dir BIN\%1.COM
if not "%1" == "" goto VeryEnd

:vdocs
if not exist BIN goto VeryEnd
copy LICENSE BIN
if exist README.TXT copy README.TXT BIN\V8POWER.TXT
if not exist README.TXT copy README.md BIN\V8POWER.md

:VeryEnd
set VSTAGE=