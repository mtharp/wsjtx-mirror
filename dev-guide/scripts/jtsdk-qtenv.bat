@ECHO OFF
REM -- JTSDK-QT Custom Environment
REM -- Part of the JTSDK project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 0B
TITLE JTSDK-QT Development Environment

REM -- SET PATH VARS
SET LANG=en_US
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET SVND=%BASED%\subversion\bin
SET CMAKED=%BASED%\cmake\bin
SET HAMLIBD=%BASED%\hamlib3\mingw32\bin
SET FFTWD=%BASED%\fftw3f
SET NSISD=%BASED%\NSIS
SET INNOD=%BASED%\inno5
SET GCCD=%BASED%\qt5\Tools\mingw48_32\bin
SET QT5D=%BASED%\qt5\5.2.1\mingw48_32\bin
SET SRCD=%BASED%\src
SET TOOLS=%BASED%\tools
SET SCRIPTS=%TOOLS%\scripts
SET LIBRARY_PATH=""
SET PATH=%BASED%;%SVND%;%CMAKED%;%HAMLIBD%;%FFTWD%;%GCCD%;%NSISD%;%INNOD%;%QT5D%;%SRCD%;%TOOLS%;%SCRIPTS%;%WINDIR%;%WINDIR%\System32
CD /D %BASED%

REM -- DOSKEY BUILD COMMAND
DOSKEY checkout="%BASED%\jtsdk-cmakeco.bat" $1
DOSKEY build="%BASED%\jtsdk-cmake.bat" $1 $2
DOSKEY wsjtxrc="%BASED%\jtsdk-wsjtxrc.bat" $1
DOSKEY env-info=CALL %SCRIPTS%\jtsdk-qtinfo.bat
DOSKEY build-help=CALL %SCRIPTS%\jtsdk-qtbuild-help.bat
DOSKEY vinfo=CALL %SCRIPTS%\script-versions.bat

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