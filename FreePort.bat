@echo off
setlocal enabledelayedexpansion

if '%1'=='' goto help
if '%1'=='h' goto help
if '%1'=='-h' goto help
if '%1'=='help' goto help

if "%1"=="l" goto list
if "%1"=="-l" goto list
if "%1"=="list" goto list

set kill=0
if "%2"=="k" set kill=1
if "%2"=="-k" set kill=1
if "%2"=="kill" set kill=1
goto find


:help
echo LIST ALL LOCAL PORTS:          freeport l
echo KILL PROCESS:                  freeport [port] k
goto end


:list
@REM netstat -ano | find "LISTEN" | find "127.0.0.1:"
netstat -ano | find "LISTEN" | find "[::1]"
goto end


:find
for /f "tokens=5" %%a in ('netstat -ano ^| find "LISTEN" ^| find "[::1]:%1"') do (
	set "pid=%%a"
	echo Found process !pid!
	set /a count+=1
)
if "!count!"=="1" if "%kill%"=="1" (
	echo [96mKilling process !pid!
	taskkill /PID !pid! /f
)
if "!count!"=="0" (
	echo No processes found
)
goto end

:end