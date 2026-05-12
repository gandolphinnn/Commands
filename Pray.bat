@echo off
if "%~1"=="" (
	rem No parameter provided, defaulting to just D:\
	cd /d "D:\"
) else if exist "D:\%~1\" (
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