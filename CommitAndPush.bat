@echo off

set name="Marco Sena"
set email="marcosena1976@gmail.com"
set sslVerify=true

set comment=%1
if "%comment%"=="" set comment=Update

echo The current directory is %CD%
echo The Committer Name is %name%
echo The Committer Email is %email%
echo The sslVerify %sslVerify%
echo The comment is: '%comment%'
echo.

git config --global user.name %name%
git config --global user.email %email%
git config --global http.sslVerify %sslVerify%

echo Actual git config
git config --global user.name
git config --global user.email
git config --global http.sslVerify
echo.

echo The current branch is
git branch
echo.

echo Status...
git status
echo.

echo Pull...
git pull
echo.

echo Adding...
git add .
echo Added
echo.

echo Committing...
git commit -m %comment%
rem git commit --author="%name% <%email%>" -m %comment%
echo Committed
echo.

echo Pushing...
git push
echo Pusched
echo.

echo Status...
git status
echo.

set name="Marco Sena"
set email="marco.sena@external.eni.com"

git config --global user.name %name%
git config --global user.email %email%
git config --global http.sslVerify false

echo Actual git config
git config --global user.name
git config --global user.email
git config --global http.sslVerify
echo.

echo End Commit And Push
echo.