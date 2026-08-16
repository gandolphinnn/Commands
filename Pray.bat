@echo off
setlocal
set "HERE=%~dp0"

rem Parse args: a "-r" flag (in either position) plus an optional folder filter
set "RFLAG="
set "FLT="
if /i "%~1"=="-r" (
    set "RFLAG=1"
    set "FLT=%~2"
) else (
    set "FLT=%~1"
    if /i "%~2"=="-r" set "RFLAG=1"
)

rem Nothing at all -> full interactive picker (with the current dir as [here])
if not defined RFLAG if not defined FLT goto picker

rem "-r" alone -> resume the most recent session globally
if defined RFLAG if not defined FLT goto resumeGlobal

rem A filter was given (with or without -r): run the (filtered) picker
call :select -Filter "%FLT%"
if errorlevel 1 exit /b 1
if defined RFLAG goto resumeHere
goto launch

:picker
call :select -LaunchPath "%CD%"
if errorlevel 1 exit /b 1
goto launch

:resumeHere
rem Resume the most recent session of the selected folder
claude --continue --dangerously-skip-permissions
exit /b %errorlevel%

:launch
claude --dangerously-skip-permissions
exit /b %errorlevel%

:resumeGlobal
set "PRAYRES=%TEMP%\PrayResume.txt"
if exist "%PRAYRES%" del "%PRAYRES%" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%/scripts/PrayResume.ps1" -OutFile "%PRAYRES%"
if errorlevel 1 (
    echo No Claude session to resume.
    exit /b 1
)
set "RESLINE="
set /p RESLINE=<"%PRAYRES%"
del "%PRAYRES%" >nul 2>&1
if not defined RESLINE (
    echo No Claude session to resume.
    exit /b 1
)
for /f "tokens=1,2 delims=|" %%a in ("%RESLINE%") do (
    set "RESCWD=%%a"
    set "RESID=%%b"
)
cd /d "%RESCWD%"
claude --resume %RESID% --dangerously-skip-permissions
exit /b %errorlevel%

rem --- helper: run the picker with the given extra args, then cd into the choice
:select
set "PRAYSEL=%TEMP%\PraySelection.txt"
if exist "%PRAYSEL%" del "%PRAYSEL%" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%/scripts/PraySelect.ps1" -OutFile "%PRAYSEL%" %*
if errorlevel 1 (
    echo Cancelled.
    exit /b 1
)
set "TARGET="
set /p TARGET=<"%PRAYSEL%"
del "%PRAYSEL%" >nul 2>&1
if not defined TARGET (
    echo No selection.
    exit /b 1
)
cd /d "%TARGET%"
exit /b 0
