@echo off
cls
color 0A
setlocal EnableDelayedExpansion

REM === CONFIG ===
set "name=Marco Sena"
set "email=marcosena@msn.com"

REM === COMMIT MESSAGE ===
set "comment=%~1"
if "%comment%"=="" set "comment=Update"

echo Directory: %CD%
echo Committer: %name% ^<%email%^>
echo Message: "%comment%"
echo.

REM === CHECK IF INSIDE GIT REPO ===
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo ERROR: Not inside a git repository!
    goto :end
)

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
            goto :end
        )
    )
) else (
    echo No remote configured. Skipping pull.
)
echo.

REM === ADD & COMMIT IF CHANGES ===
if "!hasChanges!"=="1" (
    echo Adding files...
    git add .
    if errorlevel 1 (
        echo ERROR: Add failed.
        goto :end
    )
    echo.

    echo Committing...
    git -c user.name="%name%" -c user.email="%email%" commit -m "%comment%"
    if errorlevel 1 (
        echo ERROR: Commit failed.
        goto :end
    )
    echo Commit successful.
)

REM === PUSH ONLY IF REMOTE EXISTS ===
if "!hasRemote!"=="1" (
    echo Pushing...
    git push
    if errorlevel 1 (
        echo ERROR: Push failed.
        goto :end
    ) else (
        echo Push successful.
    )
) else (
    echo No remote configured. Skipping push.
)
echo.

echo SUCCESS!

:end
echo.
pause
endlocal