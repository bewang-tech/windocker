REM @echo off
set BASEDIR=%~dp0

if "%CYGWIN_HOME%" == "" set CYGWIN_HOME=%USERPROFILE%\dev-env\cygwin64

echo Starting Cygwin/X if it is not started ...
for /f "usebackq tokens=*" %%p in (`%CYGWIN_HOME%\bin\cygpath.exe -u %BASEDIR%cygwin-x.sh`) do set CYGWIN_X=%%p
if %ERRORLEVEL% NEQ 0 GOTO :CYGWIN_X_ERR

%CYGWIN_HOME%\bin\bash -l %CYGWIN_X%

if %ERRORLEVEL% NEQ 0 GOTO :ERR
echo Cygwin/X should be started! You can fix it in notification area.
GOTO END

:CYGWIN_X_ERR
echo Failed to run `%CYGWIN_HOME%\bin\cygpath.exe -u %BASEDIR%\cygwin-x.sh`!!!
GOTO END

:ERR
echo Failed to start Cygwin/X!!!

:END
