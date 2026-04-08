@echo off
if "%~1"=="" goto launch
if exist "D:\Progetti\%~1\" (
    cd /d "D:\Progetti\%~1"
) else if exist "D:\Personale\%~1\" (
    cd /d "D:\Personale\%~1"
) else (
    echo Folder "%~1" not found in D:\Progetti or D:\Personale
    exit /b 1
)
:launch
claude --dangerously-skip-permissions