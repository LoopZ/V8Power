@echo off
rem VTEST demo and test verification.

if not "%_XERR%" == "" goto Test
set _XBAT=CALL %0
set _XERR=0

REM Tests that return True

%_XBAT% /z
%_XBAT% /n test
%_XBAT% /n test
%_XBAT% /n 34
%_XBAT% /f EX13.*
%_XBAT% /d *.*
%_XBAT% /v 0x16
%_XBAT% /v 0
%_XBAT% /v -75

%_XBAT% 0 /eq 0
%_XBAT% 0 /eq -0
%_XBAT% 1 /eq 1
%_XBAT% -1 /eq -1

%_XBAT% 0 /ne -1
%_XBAT% -1 /ne 0
%_XBAT% -1 /ne -5
%_XBAT% 1 /ne 5

%_XBAT% 0 /lt 1
%_XBAT% -1 /lt 0
%_XBAT% -5 /lt -1
%_XBAT% 1 /lt 5

%_XBAT% 0 /le 1
%_XBAT% -1 /le 0
%_XBAT% -5 /le -1
%_XBAT% 1 /le 5

%_XBAT% 0 /le 0
%_XBAT% 0 /le -0
%_XBAT% 1 /le 1
%_XBAT% -1 /le -1

%_XBAT% 1 /gt 0
%_XBAT% 0 /gt -1
%_XBAT% -1 /gt -5
%_XBAT% 5 /gt 1

%_XBAT% 1 /ge 0
%_XBAT% 0 /ge -1
%_XBAT% -1 /ge -5
%_XBAT% 5 /ge 1

%_XBAT% 0 /ge 0
%_XBAT% 0 /ge -0
%_XBAT% 1 /ge 1
%_XBAT% -1 /ge -1


%_XBAT% 1 /ge 0 /ge -1
%_XBAT% -1 /le 0 /le 1

%_XBAT% /f %0 /or /f %0.bat

REM Tests that return False
set _XERR=1

%_XBAT%
%_XBAT% /n
%_XBAT% /v
%_XBAT% /not /z
%_XBAT% /v above
%_XBAT% /c /f ex13.*
%_XBAT% 0 /ge 1
%_XBAT% 1 /le 0
%_XBAT% 0 /ge 1 /ge 2
%_XBAT% 1 /le 0 /le -1
%_XBAT% 0 /ge 1 /ge 0
%_XBAT% 1 /le 0 /le 1
%_XBAT% 5 /ge 1 /ge 5
%_XBAT% -5 /le 0 /le -1
%_XBAT% /f %0 /and /f %0.bat
%_XBAT% /f %0.bat /and /f %0


if "%_FAIL%" == "" goto Success
goto Failed

:Test
set /e _RES=VTEST /tf %1 %2 %3 %4 %5 %6 %7 %8 %9
if "%_XERR%" == "%ERRORLEVEL%" goto Correct
echo WRONG	, VTEST %1 %2 %3 %4 %5 %6 %7 %8 %9
set _FAIL=FAILED
goto End
:Correct
echo %_RES%	, VTEST %1 %2 %3 %4 %5 %6 %7 %8 %9
goto End

:Failed
echo At least one test failed.
goto Done
:Success
echo All tests completed successfully.
:Done
set _XBAT=
set _XERR=
set _FAIL=

:End