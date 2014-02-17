@ECHO OFF
REM -- Custom CMD Window for WSJT-X Build using CMake
REM -- Part of the WSJT Documentation project
REM -- Change color so users know this is *not* a normal CMD Window
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 1B
TITLE WSJT Environment
CLS
REM -- Be careful with variables, if incorrect, WSJT Env Terminal will fail.
SET TARGET=%~dp0
IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
SET BASED=%TARGET%
SET CMAKED=%BASED%\CMake\bin
SET SVND=%BASED%\SlikSvn\bin
SET QTD=%BASED%\Qt5\5.2.1\mingw48_32\bin
SET TOOLSD=%BASED%\Qt5/Tools/mingw48_32\bin
SET PATH=%BASED%;%CMAKED%;%SVND%;%QTD%;%TOOLSD%;%PATH%
CD /D %BASED%

REM -- CHECK REQUIRED TOOLS
cmake --version >nul 2>null || SET APP=CMake && GOTO ERROR1
qmake --version || SET APP=QMake && GOTO ERROR1
svn --version >nul 2>null || SET APP=SVN && GOTO ERROR1
mingw32-make --version >nul 2>null || SET APP=Mingw32-Make && GOTO ERROR1
gfortran --version >nul 2>null || SET APP=Gfortran && GOTO ERROR1
gcc --version >nul 2>null || SET APP=GCC && GOTO ERROR1
g++ --version >nul 2>null || SET APP=G++ && GOTO ERROR1
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
EXIT /B 1

REM - CONTUNE MAIN SCRIPT
:CONTINUE
CLS
ECHO.
ECHO ---------------------------
ECHO Build Environment is Using
ECHO ---------------------------
  cmake --version |findstr "cmake"
  qmake --version |findstr "QMake"
  svn --version |findstr "svn,"
  mingw32-make -v |findstr "Make"
  gfortran --version |findstr "Built"
  gcc --version |findstr "gcc"
  g++ --version |findstr "g++"
ECHO.
ECHO To Build WSJT-X using CMake
ECHO ---------------------------
ECHO * Release: wsjtx-build-cmake.bat -r
ECHO * Debug  : wsjtx-build-cmake.bat -d
ECHO.
C:\Windows\System32\cmd.exe /A /Q /K
