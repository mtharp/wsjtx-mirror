@ECHO OFF
REM -- WSJT-X CMake Build Setup
REM -- Part of the WSJT Documentation project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 1B
TITLE WSJT-X CMake Build Setup
SET TARGET=%~dp0
REM -- To Set a difference install location, edit SET TARGET=%~dp0
REM -- Example(s): SET TARGET=C:\Users\ki7mt\Documents
REM --             SET TARGET=F:\
REM --             SET TARGET=F:\
REM --             SET TARGET=G:\tools

REM - No Other Edits should be required
IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
SET BASED=%TARGET%\wsjt-env
SET MK_LVL1=downloads fftw3f hamlib src
SET MK_LVL2=wsjtx-build\Debug wsjtx-build\Release
SET MK_LVL3=wsjtx-install\Debug wsjtx-install\Release
SET DIR_LIST=%MK_LVL1% %MK_LVL2% %MK_LVL3%

REM -- Start Main Script
CLS
ECHO -------------------------------
ECHO WSJT-X CMake Build Script Setup
ECHO -------------------------------
ECHO.
IF NOT EXIST %BASED%\NUL (GOTO SETUPDIR) ELSE (GOTO DIRCHECK)

REM -- Setup ALl Directory's
:SETUPDIR
ECHO %BASED% - Was Not Found, Creating Directory Structure
C:
mkdir %BASED% & CD /D %BASED%
FOR %%f IN (%DIR_LIST%) DO (
ECHO    creating - %BASED%\%%f
mkdir %%f
)
ECHO.
GOTO GETFILES

REM -- Check All Base Directory's
:DIRCHECK
ECHO Checking Base Directory's
FOR %%d IN (%DIR_LIST%) DO ( 
IF NOT EXIST %BASED%\%%d (
ECHO   creating %BASED%\%%d
MKDIR %BASED%\%%d) ELSE (
ECHO   %BASED%\%%d .. OK )
)
GOTO GETFILES

REM -- Download Build Scripts
:GETFILES
CD %BASED%
ECHO.
ECHO Downloaing WSJT-X Build Files
SET WSJTURL=svn://svn.berlios.de/wsjt/branches/doc/dev-guide/source
REM -- Use force to pull new updates from SVN
SET CHECKOUT=svn export -q --force %WSJTURL%
SET FILE_LIST=wsjtx-env.txt wsjtx-build-cmake.txt wsjtx-toolchain.cmake
FOR %%f IN (%FILE_LIST%) DO (
ECHO   downloading: %%f
%CHECKOUT%/%%f %BASED%/
)
ECHO.
ECHO ----------------------------------
ECHO WSJT-X Build Script Setup Complete
ECHO ----------------------------------
ECHO.
PAUSE
GOTO EOF

:EOF
ENDLOCAL
EXIT /B 0
