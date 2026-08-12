@echo off
setlocal enabledelayedexpansion

set "BASE_PATH=%~1"
if "%BASE_PATH%"=="" set "BASE_PATH=."

if not exist "%BASE_PATH%" (
    echo Errore: la cartella "%BASE_PATH%" non esiste.
    exit /b 1
)

echo Controllo repository Git in: %BASE_PATH%
echo -----------------------------------------

set "found=0"

for /d %%D in ("%BASE_PATH%\*") do (
    if exist "%%D\.git" (
        set "hasChanges=0"
        set "hasUnpushed=0"
        set "msg="

        for /f "delims=" %%S in ('git -C "%%D" status --porcelain 2^>nul') do (
            set "hasChanges=1"
        )

        for /f "delims=" %%U in ('git -C "%%D" log "@{u}.." --oneline 2^>nul') do (
            set "hasUnpushed=1"
        )

        if "!hasChanges!"=="1" set "msg=!msg! [modifiche non committate]"
        if "!hasUnpushed!"=="1" set "msg=!msg! [commit non pushati]"

        if not "!msg!"=="" (
            echo %%D: !msg!
            set "found=1"
        )
    )
)

if "!found!"=="0" (
    echo Nessuna modifica o commit in sospeso trovati.
)

endlocal