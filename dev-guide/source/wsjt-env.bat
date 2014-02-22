@ECHO OFF
REM -- Custom CMD Window for WSJT-X Build using CMake
REM -- Part of the WSJT Documentation project
REM -- Change color so users know this is *not* a normal CMD Window
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 1B
TITLE WSJT Environment
REM -- Be careful with variables, if incorrect, WSJT Env Terminal will fail.
SET TARGET=%~dp0
IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
SET BASED=%TARGET%
SET SVND=%BASED%\subversion\bin
SET PATH=%BASED%;%SVND%;%PATH%
CD /D %BASED%

REM -- CHECK REQUIRED TOOLS
CLS
svn --version >nul 2>null || SET APP=SVN && GOTO ERROR1
GOTO CONTINUE

REM - TOOL CHAIN ERROR MESSAGE
:ERROR1
COLOR 1C
CLS
ECHO.
ECHO ------------------------------
ECHO       SVN NOT FOUND
ECHO ------------------------------
ECHO :: %APP%Was Not Found.
ECHO.
ECHO Please check your tool chain
ECHO PATH variables and re-start
ECHO    WSJT Env Terminal
ECHO.
PAUSE
ENDLOCAL
EXIT /B 1

REM - CONTUNE MAIN SCRIPT
:CONTINUE
CLS
ECHO ---------------------------
ECHO    Welcome to WSJT Env
ECHO ---------------------------
ECHO.
ECHO To Build WSJT-X using CMake
ECHO ---------------------------
ECHO * Release: wsjtx-build-cmake.bat -r
ECHO * Debug  : wsjtx-build-cmake.bat -d
ECHO.
C:\Windows\System32\cmd.exe /A /Q /K
