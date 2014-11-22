::-----------------------------------------------------------------------------::
:: Name .........: qtenv-wsjtxrc.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Build Current WSJTX-RC version
:: Project URL ..: http://sourceforge.net/projects/jtsdk 
:: Usage ........: This file is run from within qtenv.bat
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: qtenv-wsjtxrc.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: qtenv-wsjtxrc.bat is distributed in the hope that it will be useful, but WITHOUT
:: ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
:: FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
:: details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

:: ENVIRONMENT
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
SET LANG=en_US


:: TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DOUBLE_CLICK_ERROR


:: PATH VARIABLES
SET LANG=en_US
SET LIBRARY_PATH=""
SET BASED=C:\JTSDK
SET CMK=%BASED%\cmake\bin
SET BIN=%BASED%\tools\bin
SET HL3=%BASED%\hamlib3\bin
SET FFT=%BASED%\fftw3f
SET NSI=%BASED%\NSIS
SET INO=%BASED%\inno5
SET QT5=%BASED%\qt5\bin
SET QTP=%BASED%\qt5\plugins\platforms;%BASED%\qt5\plugins\accessible
SET SCR=%BASED%\scripts
SET SRCD=%BASED%\src
SET SVND=%BASED%\subversion\bin
SET PATH=%BASED%;%CMK%;%BIN%;%HL3%;%FFT%;%QT5%;%QTP%;%NSI%;%INO%;%SRCD%;%SCR%;%SVND%;%WINDIR%\System32

:: USER INPUT FILED 1 = %1
IF /I [%1]==[rconfig] (SET OPTION=Release
SET BTREE=true
) ELSE IF /I [%1]==[rinstall] (SET OPTION=Release
SET BINSTALL=true
) ELSE IF /I [%1]==[package] (SET OPTION=Release
SET BPKG=true
) ELSE ( GOTO BADTYPE )


:: VARIABLES USED IN PROCESS
SET APP_NAME=wsjtx-1.4
SET TCHAIN=%SCR%\wsjtx-toolchain.cmake
SET BUILDD=%BASED%\%APP_NAME%\build
SET INSTALLD=%BASED%\%APP_NAME%\install
SET PACKAGED=%BASED%\%APP_NAME%\package
SET JJ=%NUMBER_OF_PROCESSORS%

REM ----------------------------------------------------------------------------
REM  START MAIN SCRIPT
REM ----------------------------------------------------------------------------
CLS
CD %BASED%
IF NOT EXIST %SRCD%\NUL mkdir %SRCD%
IF NOT EXIST %BUILDD%\%OPTION%\NUL mkdir %BUILDD%\%OPTION%
IF NOT EXIST %INSTALLD%\%OPTION%\NUL mkdir %INSTALLD%\%OPTION%
IF NOT EXIST %PACKAGED%\NUL mkdir %PACKAGED%
ECHO -----------------------------------------------------------------
ECHO  ^( %APP_NAME% ^) CMake Build Script
ECHO -----------------------------------------------------------------
ECHO.
IF NOT EXIST %SRCD%\%APP_NAME%\.svn\NUL (
GOTO COMSG
) ELSE (
GOTO SVNASK
)


:: ASK USER UPDATE FROM SVN
:SVNASK
ECHO Update from SVN Before Building? ^( y/n ^)
SET ANSWER=
ECHO.
SET /P ANSWER=Type Response: %=%
If /I "%ANSWER%"=="N" GOTO BUILD
If /I "%ANSWER%"=="Y" (
GOTO SVNUP
) ELSE (
CLS
ECHO.
ECHO Please Answer With: ^( Y or N ^) & ECHO. & GOTO SVNASK
)


:: UPDATE IF USER SAID YES TO UPDATE
:SVNUP
ECHO.
ECHO UPDATING %SRCD%\%APP_NAME%
ECHO.
CD /D %SRCD%\%APP_NAME%
start /wait svn update
CD /D %BASED%
ECHO.


REM ----------------------------------------------------------------------------
REM  CONFIGURE BUILD TREE ( BTREE )
REM ----------------------------------------------------------------------------
:BUILD
IF [%BTREE%]==[true] (
CLS
CD %BUILDD%\%OPTION%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Configuring RC Build Tree For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
cmake -G "MinGW Makefiles" -D CMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-D CMAKE_BUILD_TYPE=%OPTION% ^
-D CMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished RC Build Tree For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO BASE BUILD CONFIGURATION
ECHO   Package ............ %APP_NAME%
ECHO   Type ............... %OPTION%
ECHO   Build Directory .... %BUILDD%\%OPTION%
ECHO   Build Option List .. %BUILDD%\%OPTION%\CmakeCache.txt
ECHO   Target Directory ... %INSTALLD%\%OPTION%
ECHO.
ECHO TO BUILD INSTALL TARGET
ECHO   cd %BUILDD%\%OPTION%
ECHO   cmake --build . --target install --clean-first -- -j%JJ%
ECHO.
ECHO TO BUILD WINDOWS NSIS INSTALLER
ECHO   cd %BUILDD%\%OPTION%
ECHO   cmake --build . --target package -- -j%JJ%
ECHO.
GOTO EOF

REM ----------------------------------------------------------------------------
REM  BUILD INSTALL TARGET ( BINSTALL )
REM ----------------------------------------------------------------------------
) ELSE IF [%BINSTALL%]==[true] (
CLS
CD %BUILDD%\%OPTION%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Building RC For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO .. Configuring Release Candidate Build Tree
ECHO.
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=%OPTION% ^
-DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
ECHO.
ECHO .. Starting Release Candidate Install
ECHO.
cmake --build . --target install -- -j%JJ%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
GOTO FINISH

REM ----------------------------------------------------------------------------
REM  BUILD INSTALLER ( BPKG )
REM ----------------------------------------------------------------------------
) ELSE IF [%BPKG%]==[true] (
CLS
CD %BUILDD%\%OPTION%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Building RC Installer For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=%OPTION% ^
-DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
GOTO NSIS_PKG


:: NSIS PACKAGE ( WSJT-X / Win32 ONLY)
:NSIS_PKG
cmake --build . --target package -- -j%JJ%
IF ERRORLEVEL 1 ( GOTO NSIS_BUILD_ERROR )
ls -al %BUILDD%\%OPTION%\*-win32.exe |gawk "{print $8}" >p.k & SET /P WSJTXPKG=<p.k & rm p.k
CD %BUILDD%\%OPTION%
MOVE /Y %WSJTXPKG% %PACKAGED% > nul
CD %BASED%
GOTO FINISH_PKG


:: FINISHED PACKAGE MESSAGE
:FINISH_PKG
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished Installer Build For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO Installer Name ...... %WSJTXPKG%
ECHO Installer Location .. %PACKAGED%
ECHO.
ECHO To Install the package, browse to Installer Location, and
ECHO run as you normally do to install Windows applications.
ECHO.
GOTO EOF


:: DISPLAY FINISH MESSAGE
:FINISH
ECHO.
ECHO BUILD SUMMARY
ECHO   Build Tree Location .. %BUILDD%\%OPTION%
ECHO   Install Location ..... %INSTALLD%\%OPTION%\bin\wsjtx.exe
ECHO.
PAUSE
GOTO ASK_FINISH_RUN


:: ASK USER IF THEY WANT TO RUN THE APP
:ASK_FINISH_RUN
ECHO.
ECHO  Would You Like To Run %APP_NAME% Now? ^( y/n ^)
ECHO.
SET ANSWER=
SET /P ANSWER=Type Response: %=%
ECHO.
If /I "%ANSWER%"=="Y" GOTO RUN_INSTALL
If /I "%ANSWER%"=="N" (
GOTO EOF
) ELSE (
CLS
ECHO.
ECHO   Please Answer With: ^( y or n ^) & ECHO. & GOTO ASK_FINISH_RUN
)


:: RUN APP
:RUN_INSTALL
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
ECHO .. Starting: ^( %APP_NAME% ^) in Release Mode
CALL wsjtx.exe
)
GOTO EOF

REM ----------------------------------------------------------------------------
REM  POST BUILD
REM ----------------------------------------------------------------------------


:: DOUBLE-CLICK ERROR MESSAGE
:DOUBLE_CLICK_ERROR
CLS
@ECHO OFF
ECHO -------------------------------
ECHO       Execution Error
ECHO -------------------------------
ECHO.
ECHO Please Run from JTSDK Enviroment
ECHO.
ECHO          qtenv.bat
ECHO.
PAUSE
GOTO EOF


:: SVN CHECKOUT MESSAGE
:COMSG
CLS
ECHO -----------------------------------------------------------------
ECHO  %SRCD%\%APP_NAME% Was Not Found
ECHO -----------------------------------------------------------------
ECHO.
ECHO In order to build ^( %APP_NAME% ^) you
ECHO must first perform an SVN checkout from SourceForge.
ECHO.
ECHO ANONYMOUS CHECKOUT ^( %APP_NAME% ^):
ECHO  Type: .. checkout %APP_NAME%
ECHO.
ECHO DEVELOPER CHECKOUT:
ECHO  ^cd src
ECHO  svn co https://%USERNAME%@svn.code.sf.net/p/wsjt/wsjt/branches/%APP_NAME%
ECHO  ^cd ..
ECHO  NOTE: Change ^( %USERNAME% ^) to your Sourforge Username
ECHO.
ECHO ACTIONS AFTER CHECKOUT:
ECHO  Configure Build Tree: .... wsjtxrc rconfig
ECHO  Build Install Target: .... wsjtxrc rinstall
ECHO.
ECHO OPTIONAL
ECHO  Build Installer Package: .. wsjtxrc package
ECHO.
GOTO EOF


:: UNSUPPORTED BUILD TYPE
:BADTYPE
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO                UNSUPPORTED BUILD TYPE
ECHO -----------------------------------------------------------------
ECHO ^( %1% ^) Check Spelling or Syntax
ECHO.
ECHO USAGE:  wsjtxrc ^(type^)
ECHO.
ECHO  Release Types .. rconfig rinstall package
ECHO    rconfig ...... Configure Release Build Tree
ECHO    rinstall ..... Build Release Install Target
ECHO    package ...... Build Win32 Installer
ECHO.
ECHO EXAMPLES
ECHO ----------------------------------------------------------
ECHO Configure Build Tree:
ECHO   Type: wsjtxrc rconfig
ECHO.
ECHO Build Install Target:
ECHO   Type:  wsjtxrc rinstall
ECHO.
ECHO Build NSIS Installer
ECHO   Type:  wsjtxrc package
ECHO.
GOTO EOF


:: GENERAL CMAKE ERROR MESSAGE
:CMAKE_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO                    CMAKE BUILD ERROR
ECHO -----------------------------------------------------------------
ECHO.
ECHO  There was a problem building ^( App: %1%  Target: %2 ^)
ECHO.
ECHO  Check the screen for error messages, correct, then try to
ECHO  re-build ^( App: %1%  Target: %2 ^)
ECHO.
ECHO.
GOTO EOF


:: UNSUPPORTED INSTALLER TYPE
:NSIS_BUILD_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO                    INSTALLER BUILD ERROR
ECHO -----------------------------------------------------------------
ECHO.
ECHO  There was a problem building the package, or the script
ECHO  could not find:
ECHO.
ECHO  %BUILDD%\%OPTION%\%WSJTXPKG%
ECHO.
ECHO  Check the Cmake logs for any errors, or correct any build
ECHO  script issues that were obverved and try to rebuild the package.
ECHO.
ECHO.
GOTO EOF


:: END QTENV-WSJTXRC.BAT
:EOF
CD /D %BASED%
ENDLOCAL

EXIT /B 0
