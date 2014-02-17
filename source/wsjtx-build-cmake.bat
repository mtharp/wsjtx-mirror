@ECHO OFF
REM -- WSJT-X Windows Build Script Using CMake
REM -- Part of the WSJT Documentation Project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 1B
TITLE WSJT-X CMake Build Script

REM -- TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI GOTO DCLICKERROR1

REM -- START MAIN SCRIPT
:START
SET TARGET=%~dp0
IF %TARGET:~-1%==\ (SET BASED=%TARGET:~0,-1%) ELSE (SET BASED=%TARGET%) 
SET SRCD=%BASED%\src
SET BUILDD=%BASED%\wsjtx-build
SET DLLD=%BASED%\Qt5\5.2.1\mingw48_32\bin
SET LIBD=%BASED%\Qt5\Tools\mingw48_32\bin
SET INSTALLD=%BASED%\wsjtx-install
SET TCHAIN=%BASED%\wsjtx-toolchain.cmake
SET CHECKOUT=svn co svn://svn.berlios.de/wsjt/branches/wsjtx
SET CPTXT=*.txt *.dat *.conf
SET CPQT=Qt5Core.dll Qt5Gui.dll Qt5Multimedia.dll Qt5Network.dll Qt5Widgets.dll
SET CPICU=icu*.dll
SET CPLIB=libgcc_s_dw2-1.dll libgfortran-3.dll libstdc++-6.dll libquadmath-0.dll libwinpthread-1.dll
SET RBCPY=ROBOCOPY /NS /NC /NFL /NDL /NP

IF /I [%1]==[-d] (SET OPTION=Debug) ELSE (SET OPTION=Release)
:SVNCHECKOUT
CD %SRCD%
%CHECKOUT%
CD %BUILDD%\%OPTION%
GOTO CMAKE

REM -- CMAKE
REM -- Note: CMake does not like "\" backslash in paths, use "/" forward slash
REM --       for path variables
:CMAKE
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/wsjtx
GOTO MAKEINSTALL

REM -- MAKE INSTALL :: Builds to install\{Release, Debug}\bin
:MAKEINSTALL
mingw32-make install
GOTO POSTCOPY

REM -- POST BUILD COPY
:POSTCOPY
CD %BASED%
%RBCPY% %SRCD%\wsjtx %INSTALLD%\%OPTION%\bin %CPTXT% /XF CMake* *.cmake
%RBCPY% %DLLD% %INSTALLD%\%OPTION%\bin %CPICU% %CPQT%
%RBCPY% %LIBD% %INSTALLD%\%OPTION%\bin %CPLIB%
GOTO EOF

REM - DOUBLE-CLICK ERROR MESSAGE
:DCLICKERROR1
CLS
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