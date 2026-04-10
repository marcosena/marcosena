@echo off
cls
color 0A
setlocal EnableDelayedExpansion

REM === CONFIG ===
set "name=Marco Sena"
set "email=marcosena@msn.com"

REM === ROOT DIRECTORY ===
set "root=%CD%"

REM === COMMIT MESSAGE ===
set "comment=%~1"
if "%comment%"=="" set "comment=Update"

echo Root Directory: %root%
echo Committer: %name% ^<%email%^>
echo Message: "%comment%"
echo.

REM === PROCESS CURRENT DIRECTORY FIRST ===
call :ProcessRepo "%root%"

REM === LOOP ALL SUBDIRECTORIES ===
for /d /r "%root%" %%D in (*) do (
    call :ProcessRepo "%%D"
)

echo ==========================================
echo DONE: All repositories processed!
echo ==========================================
pause
endlocal
goto :eof

:ProcessRepo
set "repoPath=%~1"

if not exist "%repoPath%\.git" (
    goto :eof
)

echo ==================================================
echo Processing repo: %repoPath%
echo ==================================================

pushd "%repoPath%"

REM === CURRENT BRANCH ===
set "branch="
for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set "branch=%%b"
if "!branch!"=="" set "branch=main"
echo Current branch: !branch!
echo.

REM === CHECK CHANGES ===
set "hasChanges=0"
git status --porcelain | findstr . >nul
if errorlevel 1 (
    echo No changes to commit.
    echo Will only sync and push existing local commits, if any.
    echo.
) else (
    set "hasChanges=1"
    echo Changes detected.
    echo.
)

REM === CHECK REMOTE ===
set "hasRemote=0"
git remote | findstr . >nul
if not errorlevel 1 set "hasRemote=1"

REM === PULL (REBASE) ONLY IF REMOTE EXISTS ===
if "!hasRemote!"=="1" (
    echo Pulling latest changes with rebase...
    git rev-parse --verify origin/!branch! >nul 2>&1
    if errorlevel 1 (
        echo No remote branch exists. Skipping pull.
    ) else (
        git pull --rebase --autostash
        if errorlevel 1 (
            echo ERROR: Pull failed.
        )
    )
) else (
    echo No remote configured. Skipping pull.
)

REM === ADD & COMMIT IF CHANGES ===
if "!hasChanges!"=="1" (
    echo Adding files...
    git add .
    if errorlevel 1 (
        echo ERROR: Add failed.
    ) else (
        echo.
        echo Committing...
        git -c user.name="%name%" -c user.email="%email%" commit -m "%comment%"
        if errorlevel 1 (
            echo ERROR: Commit failed.
        ) else (
            echo Commit successful.
        )
    )
)

REM === PUSH ONLY IF REMOTE EXISTS ===
if "!hasRemote!"=="1" (
    echo Pushing...
    git push
    if errorlevel 1 (
        echo ERROR: Push failed.
    ) else (
        echo Push successful.
    )
) else (
    echo No remote configured. Skipping push.
)

popd
echo.
goto :eof