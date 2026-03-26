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
for /f "delims=" %%b in ('git rev-parse --abbrev-ref HEAD') do set branch=%%b
echo Current branch: !branch!
echo.

REM === CHECK FOR CHANGES ===
echo Checking for changes...
git status --porcelain > tmp_git_status.txt

for %%A in (tmp_git_status.txt) do if %%~zA==0 (
    echo No changes to commit.
    del tmp_git_status.txt
    goto :end
)
del tmp_git_status.txt

echo Changes detected.
echo.

REM === PULL ===
echo Pulling latest changes...
git pull
if errorlevel 1 (
    echo ERROR: Pull failed. Resolve conflicts and try again.
    goto :end
)
echo.

REM === ADD ===
echo Adding files...
git add .
echo.

REM === COMMIT (WITHOUT TOUCHING GLOBAL CONFIG) ===
echo Committing...
git -c user.name="%name%" -c user.email="%email%" commit -m "%comment%"
if errorlevel 1 (
    echo ERROR: Commit failed.
    goto :end
)
echo.

REM === PUSH ===
echo Pushing...
git push
if errorlevel 1 (
    echo ERROR: Push failed.
    goto :end
)
echo.

echo SUCCESS: Commit and push completed!

:end
echo.
pause
endlocal