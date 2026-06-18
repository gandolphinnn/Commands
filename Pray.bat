@echo off
setlocal
if not "%~1"=="" goto withArg

rem No parameter: show the interactive folder picker
set "PRAYSEL=%TEMP%\PraySelection.txt"
if exist "%PRAYSEL%" del "%PRAYSEL%" >nul 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PraySelect.ps1" -OutFile "%PRAYSEL%"
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
goto launch

:withArg
if exist "D:\%~1\" (
    rem Folder exists directly under D:\
    cd /d "D:\%~1"
) else if exist "D:\Progetti\%~1\" (
    rem Folder exists under D:\Progetti
    cd /d "D:\Progetti\%~1"
) else if exist "D:\Personale\%~1\" (
    rem Folder exists under D:\Personale
    cd /d "D:\Personale\%~1"
) else (
    echo Folder "%~1" not found in D:\, D:\Progetti or D:\Personale
    exit /b 1
)

:launch
claude --dangerously-skip-permissions
