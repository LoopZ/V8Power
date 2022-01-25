@echo off

if "%1" == "" goto NoOpts

set _VNLS.LNG=en

:OptRepeater
if "%1" == "" goto end

vfdutil /e %1 | set /p _VNLS.EXT=

if "%_VNLS.EXT%" == "" goto NoFileExt
if /I "%_VNLS.EXT%" == "DEF" goto DoneGuessLang
if /I "%_VNLS.EXT%" == "BAT" goto DoneGuessLang
set _VNLS.LNG=%_VNLS.EXT%
goto DoneGuessLang
:NoFileExt
vfdutil /n %1 | set /p _VNLS.NAME=
if /I "%_VNLS.NAME%" == "%1" goto GuessLang
goto DoneGuessLang

:GuessLang
set _VNLS.LNG=%_VNLS.NAME%
shift
goto OptRepeater

:DoneGuessLang
vecho /g /p
vgotoxy up up
vline
vgotoxy down

vfont /d

set _VNLS.FNT=
set _VNLS.V8F=
if /I "%_VNLS.LNG%" == "EN" goto ReadyToDisplay

IF /I "%_VNLS.LNG%" == "TR" set _VNLS.FNT=CP857
IF /I "%_VNLS.LNG%" == "FR" set _VNLS.FNT=CP850
IF /I "%_VNLS.LNG%" == "DE" set _VNLS.FNT=CP858
IF /I "%_VNLS.LNG%" == "RU" set _VNLS.FNT=CP866

if "%_VNLS.FNT%" == "" goto NoFont

rem Find and load font
set _VNLS.V8F=%_VNLS.FNT%.V8F
if exist %_VNLS.V8F% goto FontFound
vfdutil /p %0 | set /p _VNLS.V8F=
set _VNLS.V8F=%_VNLS.V8F%\%_VNLS.FNT%.V8F
if exist %_VNLS.V8F% goto FontFound
vfdutil /s %_VNLS.FNT%.V8F | vstr /b /l 0 | set /p _VNLS.V8F=
if exist %_VNLS.V8F% goto FontFound
goto MissingFont

:FontFound
vfont %_VNLS.V8F%
goto ReadyToDisplay

:NoFont
set _VNLS.V8F=
vecho /g /fLightRed Unknown language "%_VNLS.LNG%" /fGray
goto ReadyToDisplay

:MissingFont
set _VNLS.V8F=
vecho /g /fLightRed Unknown to locate "%_VNLS.FNT%" font for language "%_VNLS.LNG%" /fGray
goto ReadyToDisplay

:ReadyToDisplay
if "%_VNLS.FNT%" == "" set _VNLS.FNT=CP437
vecho /n /g "Font: %_VNLS.FNT%"
if "%_VNLS.V8F%" == "" vecho /n /c32 /s- /fDarkGray ( /fYellow "no font loaded" /fDarkGray ) /fGray
vecho /fGray /p /g "Language: %_VNLS.LNG%"
vecho /g "File: %1"
type %1 | vstr /L total | set /p _VNLS.CNT=
vecho /g "Lines: %_VNLS.CNT%" /p
set _VNLS.LINE=0
if "%_VNLS.LINE%" == "%_VNLS.CNT%" goto DoneShowing

:RunThroughFile
set _VNLS.WAIT=no
type %1 | vstr /L %_VNLS.LINE% | set /p _VNLS.ALL=
if "%_VNLS.ALL%" == "" goto NextLine
echo %_VNLS.ALL% | vstr /f = 1 | set /p _VNLS.ID=
if "%_VNLS.ID%" == "" goto NextLine
echo %_VNLS.ID% | vstr /s " " "" | set /p _VNLS.VAL=
if not "%_VNLS.VAL%" == "%_VNLS.ID%" goto NextLine
echo %_VNLS.ALL% | vstr /f = 1-2 | set /p _VNLS.VAL=
if "%_VNLS.VAL%" == "%_VNLS.ID%" goto NextLine
set _VNLS.WAIT=yes

vecho /g /n /fGray Line /fCyan # /s- "%_VNLS.LINE%"
vecho /g /fGray , ID= /s- /fLightGreen "%_VNLS.ID%" /fGray
vecho /g /t %1 %_VNLS.ID% Var1 Var2 Var3 Var4 Var5 Var6 Var7 Var8 Var9

:NextLine
vmath %_VNLS.LINE% + 1 | set /p _VNLS.NEXT=
if "%_VNLS.NEXT%" == "" goto NextLine
set _VNLS.LINE=%_VNLS.NEXT%
set _VNLS.NEXT=
if "%_VNLS.LINE%" == "%_VNLS.CNT%" goto DoneShowing
if "%_VNLS.WAIT%" == "no" goto RunThroughFile
vecho /fGray /bBlue /e /n /g /fDarkGray Press a key, CTRL+C to abort /fGray
vpause CTRL-C
if Errorlevel 1 goto End
vgotoxy sol
vecho /n /g /fgray /bBlack /e
goto RunThroughFile

:DoneShowing
if "%_VNLS.WAIT%" == "no" goto End
vecho /fGray /bRed /e /n /g /fWhite End of File, Press a key, CTRL+C to abort /fGray
vpause CTRL-C
if Errorlevel 1 goto End
vgotoxy sol
vecho /n /g /fgray /bBlack /e
shift
goto OptRepeater

:NoOpts
echo please specify file name and/or language to use

:End
vfont /d
set _VNLS.LNG=
set _VNLS.FNT=
set _VNLS.V8F=
set _VNLS.EXT=
set _VNLS.NAME=
set _VNLS.CNT=
set _VNLS.LINE=
set _VNLS.ALL=
set _VNLS.ID=
set _VNLS.VAL=
set _VNLS.WAIT=

