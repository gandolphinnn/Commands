@echo off
setlocal enabledelayedexpansion

if "%1"=="" (
	set commitNumber=1
) else (
	set commitNumber=%1
)

git reset HEAD~%commitNumber%