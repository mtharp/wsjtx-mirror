@ECHO OFF
REM -- JTSDK-QT Custom Environment
REM -- Part of the JTSDK project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 1B
TITLE JTSDK-QT Development Environment

REM -- STRIP TRAILING "\" FROM PATH IF EXISTS SET BASE DIRECTORY
SET TARGET=%~dp0
IF %TARGET:~-1%==\ (SET BASED=%TARGET:~0,-1%) ELSE (SET BASED=%TARGET%)

REM -- SET PATH VARS
SET SVND=%BASED%\subversion\bin
SET CMAKED=%BASED%\cmake\bin
SET GCCD=%BASED%\mingw48_32\bin
SET QT5D=%BASED%\qt5\5.2.1\mingw48_32\bin
SET SRCD=%BASED%\src
SET TOOLS=%BASED%\tools
SET SCRIPTS=%TOOLS%\scripts
SET PATH=%BASED%;%SVND%;%CMAKED%;%GCCD%;%QT5D%;%SRCD%;%TOOLS%;%SCRIPTS%;%WINDIR%;%WINDIR%\System32
CD /D %BASED%

REM -- DOSKEY BUILD COMMAND
DOSKEY build="%BASED%\jtsdk-cmake.bat" $1 $2
DOSKEY env-info=CALL %SCRIPTS%\jtsdk-qtinfo.bat

REM -- CHECK CRITICAL TOOLS CAN BE FOUND
svn --version >nul 2>null || SET APP=SVN && GOTO ERROR1
rm null
GOTO CONTINUE

REM - TOOL CHAIN ERROR MESSAGE
:ERROR1
COLOR 1C
CLS
ECHO.
ECHO ------------------------------
ECHO       TOOL CHAIN ERROR
ECHO ------------------------------
ECHO :: %APP%Was Not Found.
ECHO.
ECHO Please check your tool chain
ECHO PATH variables and re-start
ECHO    WSJT Env Terminal
ECHO.
PAUSE
ENDLOCAL
COLOR
EXIT /B 1

REM - CONTUNE MAIN SCRIPT
:CONTINUE
CALL %SCRIPTS%\jtsdk-qtinfo.bat
ECHO.
%WINDIR%\System32\cmd.exe /A /Q /K