@ECHO OFF
REM -- WSJT-X Windows Build Script Using CMake
REM -- Part of the WSJT Documentation Project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 1B
TITLE WSJT-X CMake Build Script

REM -- TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI GOTO DCLICKERROR

REM -- START MAIN SCRIPT
SET TARGET=%~dp0
IF %TARGET:~-1%==\ (SET BASED=%TARGET:~0,-1%) ELSE (SET BASED=%TARGET%) 

REM -- SET BUILD TOOL PATHS
SET APP_NAME=wsjtx
SET APP_DIR=%BASED%\%APP_NAME%
SET SRCD=%BASED%\src
SET BUILDD=%BASED%\%APP_NAME%\wsjtx-build
SET INSTALLD=%BASED%\%APP_NAME%\wsjtx-install
SET TCHAIN=%BASED%\%APP_NAME%\wsjtx-toolchain.cmake
SET SVND=%BASED%\subversion\bin
SET CMAKED=%BASED%\cmake\bin
SET DLLD=%BASED%\qt5\5.2.1\mingw48_32\bin
SET LIBD=%BASED%\qt5\Tools\mingw48_32\bin
SET PLUG=%BASED%\qt5\5.2.1\mingw48_32\plugins\platforms
SET PATH=%BASED%;%SRCD%;%BUILDD%;%INSTALLD%;%TCHAIN%;%SVND%;%CMAKED%;%DLLD%;%LIBD%;%PATH%

REM -- CHECK TOOLS CAN GE REACHED
cmake --version >nul 2>null || SET APP=CMake && GOTO ERROR1
svn --version >nul 2>null || SET APP=SVN && GOTO ERROR1
mingw32-make --version >nul 2>null || SET APP=Mingw32-Make && GOTO ERROR1
gfortran --version >nul 2>null || SET APP=Gfortran && GOTO ERROR1
g++ --version >nul 2>null || SET APP=G++ && GOTO ERROR1

REM -- SET WSJTX CHECKOUT
SET WSJTXCO=svn co svn://svn.code.sf.net/p/wsjt/wsjt/branches/wsjtx

REM -- SET FILES NEEDED AFTER:  mingw32-make install
SET CPTXT=*.txt *.dat *.conf
SET CPLA=qwin*
SET CPQT=Qt5Core.dll Qt5Gui.dll Qt5Multimedia.dll Qt5Network.dll Qt5Widgets.dll
SET CPICU=icu*.dll
SET CPLIB=libgcc_s_dw2-1.dll libgfortran-3.dll libstdc++-6.dll libquadmath-0.dll libwinpthread-1.dll
SET RBCPY=ROBOCOPY /NS /NC /NFL /NDL /NP

REM -- START MAIN BUILD
CD %BASED%
CLS
ECHO -------------------------------
ECHO WSJT-X CMake Build Script
ECHO -------------------------------
ECHO.
REM - Make sure WSJT-X Directories are there
IF NOT EXIST %SRCD%\NUL mkdir %SRCD%
IF NOT EXIST %APP_DIR%\NUL mkdir %APP_DIR%

REM -- CHECKOUT TOOLCHAIN FILE - Still in %BASED%\wsjtx directory
ECHO.
ECHO Downloaing Latest ToolChain File

SET WSJTURL=svn://svn.code.sf.net/p/wsjt/wsjt/branches/doc/dev-guide/source
SET TCHAIN_FILE=wsjtx-toolchain.cmake
REM -- Use force to pull new updates from SVN
SET CHECKOUT=svn export -q --force %WSJTURL%
ECHO   downloading: %TCHAIN_FILE%
%CHECKOUT%/%TCHAIN_FILE% %BASED%/%APP_NAME%/

REM - Set user build selection or default to Release
IF /I [%1]==[-d] (SET OPTION=Debug) ELSE (SET OPTION=Release)
CD %SRCD%
ECHO   Checking out: %APP_NAME%
ECHO.
%WSJTXCO%
IF NOT EXIST %BUILDD%\%OPTION%\NUL mkdir %BUILDD%\%OPTION%
CD %BUILDD%\%OPTION%

cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/wsjtx

REM -- MAKE INSTALL :: Builds to install\{Release, Debug}\bin
mingw32-make -j4 install

REM -- POST BUILD COPY
CD %BASED%
%RBCPY% %SRCD%\wsjtx %INSTALLD%\%OPTION%\bin %CPTXT% /XF CMake* *.cmake
%RBCPY% %DLLD% %INSTALLD%\%OPTION%\bin %CPICU% %CPQT%
%RBCPY% %PLUG% %INSTALLD%\%OPTION%\bin\platforms %CPLA%
%RBCPY% %LIBD% %INSTALLD%\%OPTION%\bin %CPLIB%
GOTO EOF

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
CLS
EXIT /B 1

REM - DOUBLE-CLICK ERROR MESSAGE
:DCLICKERROR
CLS
@ECHO OFF
ECHO -------------------------------
COLOR 1C
ECHO        Execution Error
ECHO -------------------------------
ECHO.
ECHO Please Run from WSJT Enviroment
ECHO.
ECHO  Use: %~dp0\wsjt-env.bat
ECHO.
PAUSE
GOTO EOF

:SVNERROR1
CLS
ECHO -------------------------------
ECHO       SVN Execution Error
ECHO -------------------------------
ECHO.
ECHO Subversion returned with an error.
ECHO    ~~ Performing Cleanup ~~
ECHO Rerun the build script after Exit.
ECHO     If the problem continues
ECHO     Contact: ki7mt@yahoo.com
PAUSE
CD /D %SRCD%\wsjtx
svn cleanup
CLS
ECHO -------------------------------
ECHO       Cleanup Complete
ECHO -------------------------------
ECHO.
ECHO         Now exiting
sleep 2
GOTO EOF

:EOF
ENDLOCAL
EXIT /B 0