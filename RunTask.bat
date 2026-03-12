@echo off
setlocal enabledelayedexpansion

set project=""
set task=""
set folder=""

REM Call itself multiple time to run multiple tasks at once if the param is a string
if not "%1"=="" (
	set "firstparam=%~1"
	if not "!firstparam:~1!"=="" (
		for /l %%a in (0,1,100) do (
			set "char=!firstparam:~%%a,1!"
			if not "!char!"=="" (
				rem run wt --help to understand this
				wt -w 0 new-tab cmd /k runtask !char! %2
			) else (
				goto end
			)
		)
	)
)

if "%1"==""      goto help
if "%1"=="h"     goto help
if "%1"=="-h"    goto help
if "%1"=="help"  goto help

if "%1"=="i" (
	set "project=Intranet"
	set "task=npm run start-intranet-localdev"
	set "folder=ngsites"
	goto run
)

if "%1"=="b" (
	set "project=B2B"
	set "task=npm run start-b2b-localdev"
	set "folder=ngsites"
	goto run
)

if "%1"=="c" (
	set "project=B2C"
	set "task=npm run start-b2c-localdev"
	set "folder=ngsites"
	goto run
)

if "%1"=="d" (
	set "project=NaarGo"
	set "task=npm run start-localdev"
	set "folder=NaarGo"
	goto run
)

if "%1"=="d" (
	set "project=Print"
	set "task=npm run dev:smart"
	set "folder=print"
	goto run
)

if "%1"=="u" (
	set "project=Update API"
	set "task=npm run dev:updateApi"
	set "folder=ngsites"
	goto run
)

if "%1"=="a" (
	set "project=NaarApi"
	set "task=dotnet run"
	set "folder=api\NaarApi"
	goto run
)

if "%1"=="g" (
	set "project=Naar.NaarGo"
	set "task=dotnet run"
	set "folder=api\Naar.NaarGo"
	goto run
)

if "%1"=="z" (
	set "project=NaarAzureAgent"
	set "task=dotnet run"
	set "folder=api\NaarAzureAgent"
	goto run
)

if "%1"=="f" (
	set "project=NaarFunctions"
	set "task=func start --port 7200"
	set "folder=api\NaarFunctions"
	goto run
)

if "%1"=="p" (
	set "project=NaarAzurePricer"
	set "task=func start --port 7100"
	set "folder=api\NaarAzurePricer"
	goto run
)

if "%1"=="s" (
	set "project=NaarSearch"
	set "task=dotnet run"
	set "folder=api\NaarSearch"
	goto run
)

if "%1"=="l" (
	set "project=NaarLRT"
	set "task=dotnet run"
	set "folder=api\NaarLRT"
	goto run
)

echo [91mInvalid parameter %1%[0m

:help
echo         PARAMS:
echo ^|---------^|------------------^|
echo ^| Command ^| Task             ^|
echo ^|---------^|------------------^|
echo ^|    i    ^| INTRANET         ^|
echo ^|    b    ^| B2B              ^|
echo ^|    c    ^| B2C              ^|
echo ^|    s    ^| NaarGo (SUPPORT) ^|
echo ^|    d    ^| PRINT (DOCS)     ^|
echo ^|    u    ^| UPDATE API       ^|
echo ^|---------^|------------------^|
echo ^|    a    ^| NaarApi          ^|
echo ^|    g    ^| NaarGo           ^|
echo ^|    z    ^| NaarAzureAgent   ^|
echo ^|    f    ^| NaarFunctions    ^|
echo ^|    p    ^| NaarAzurePricer  ^|
echo ^|    l    ^| NaarLRT          ^|
echo ^|---------^|------------------^|
goto end


:run
set root="D:\Progetti"
if not "%2"=="" (
	set "root=%2"
	echo [93mUsing custom root %2...[0m
)
cd /d %root%\%folder%
echo [96mRunning %project%...[0m

title %project%
%task%
goto end


:end