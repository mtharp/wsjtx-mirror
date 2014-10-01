@ECHO OFF
REM -- JTSDK-QT Windows CMake Build Script - ( WSJT-X Release Candidates Only )
REM -- Part of the JTSDK Project
CLS
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 0B

REM -- TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI GOTO DCLICKERROR

REM -- SET PATH VARS
SET LANG=en_US
SET BASED=C:\JTSDK-QT
SET SVND=%BASED%\subversion\bin
SET CMAKD=%BASED%\cmake\bin
SET HAMLIBD=%BASED%\hamlib3\mingw32\bin
SET HAMLIBLIBD=%BASED%\hamlib3\mingw32\lib
SET FFTWD=%BASED%\fftw3f
SET NSISD=%BASED%\NSIS
SET INNOD=%BASED%\inno5
SET GCCD=%BASED%\qt5\Tools\mingw48_32\bin
SET QT5D=%BASED%\qt5\5.2.1\mingw48_32\bin
SET QTP=%BASED%\qt5\5.2.1\mingw48_32\plugins\platforms
SET QTA=%BASED%\qt5\5.2.1\mingw48_32\plugins\accessible
SET SRCD=%BASED%\src
SET TOOLS=%BASED%\tools
SET SCRIPTS=%TOOLS%\scripts
SET LIBRARY_PATH=""
SET PATH=%BASED%;%SVND%;%CMAKED%;%HAMLIBD%;%HAMLIBLIBD%;%FFTWD%;%GCCD%;%NSISD%;%INNOD%;%QT5D%;%QTP%;%SRCD%;%TOOLS%;%SCRIPTS%;%WINDIR%;%WINDIR%\System32;%LIBRARY_PATH%

REM ------------------------------------------------------------------
REM -- START MAIN SCRIPT
REM ------------------------------------------------------------------

REM - USER INPUT FIELD 1 == %1
REM - Release Builds Only (config, build and package)
IF /I [%1]==[rconfig] (SET OPTION=Release
SET BTREE=true
) ELSE IF /I [%1]==[rinstall] (SET OPTION=Release
SET BINSTALL=true
) ELSE IF /I [%1]==[package] (SET OPTION=Release
SET BPKG=true
) ELSE ( GOTO BADTYPE )

REM - VARIABLES USED IN PROCESS
SET APP_NAME=wsjtx-1.4
SET TCHAIN=%BASED%\jtsdk-toolchain.cmake
SET BUILDD=%BASED%\%APP_NAME%\build
SET INSTALLD=%BASED%\%APP_NAME%\install
SET PACKAGED=%BASED%\%APP_NAME%\package
SET JJ=%NUMBER_OF_PROCESSORS%

REM ------------------------------------------------------------------
REM -- START MAIN BUILD
REM ------------------------------------------------------------------
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

REM ------------------------------------------------------------------
REM -- SVN UPDATE
REM ------------------------------------------------------------------
IF NOT EXIST %SRCD%\%APP_NAME%\.svn\NUL (
GOTO COMSG
) ELSE (
GOTO SVNASK
)

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

:SVNUP
ECHO.
ECHO UPDATING %SRCD%\%APP_NAME%
ECHO.
CD /D %SRCD%\%APP_NAME%
start /wait svn update
CD /D %BASED%
ECHO.

:BUILD
REM ------------------------------------------------------------------
REM -- BUILD TREE CONFIGURATION
REM ------------------------------------------------------------------
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

REM ------------------------------------------------------------------
REM -- BUILD INSTALL TARGET
REM ------------------------------------------------------------------
) ELSE IF [%BINSTALL%]==[true] (
CLS
CD %BUILDD%\%OPTION%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Building RC For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
REM -- Ensure Build Tree is configured
ECHO .. Configuring Release Candidate Build Tree
ECHO.
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=%OPTION% ^
-DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
ECHO.
ECHO .. Starting Release Candidate Install
ECHO.
REM -- Build Install Target
cmake --build . --target install -- -j%JJ%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
GOTO FINISH

REM ------------------------------------------------------------------
REM -- BUILD NSIS INSTALLER
REM ------------------------------------------------------------------
) ELSE IF [%BPKG%]==[true] (
CLS
CD %BUILDD%\%OPTION%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Building RC Installer For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
REM - Ensure Build Tree is Configured
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=%OPTION% ^
-DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
GOTO NSIS_PKG

REM - NSIS Build Win32 Installer
:NSIS_PKG
cmake --build . --target package -- -j%JJ%
IF ERRORLEVEL 1 ( GOTO NSIS_BUILD_ERROR )
REM - GET PACKAGE NAME
ls -al %BUILDD%\%OPTION%\*-win32.exe |awk "{print $8}" >p.k & SET /P WSJTXPKG=<p.k & rm p.k
CD %BUILDD%\%OPTION%
MOVE /Y %WSJTXPKG% %PACKAGED% > nul
CD %BASED%
GOTO FINISH_PKG

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

:FINISH
ECHO.
ECHO BUILD SUMMARY
ECHO   Build Tree Location .. %BUILDD%\%OPTION%
ECHO   Install Location ..... %INSTALLD%\%OPTION%\bin\wsjtx.exe
ECHO.
PAUSE
GOTO ASK_FINISH_RUN

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
:RUN_INSTALL
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
ECHO .. Starting: ^( %APP_NAME% ^) in Release Mode
CALL wsjtx.exe
)
GOTO EOF

REM ------------------------------------------------------------------
REM MESSAGE SECTION
REM ------------------------------------------------------------------

REM -- DOUBLE-CLICK ERROR MESSAGE
:DCLICKERROR
CLS
@ECHO OFF
ECHO -------------------------------
ECHO       Execution Error
ECHO -------------------------------
ECHO.
ECHO Please Run from JTSDK Enviroment
ECHO.
ECHO  Use: %~dp0\jtsdk-wsjtxrc.bat
ECHO.
PAUSE
GOTO EOF

REM -- SVN Checkout Message 
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

REM -- Unsupported Build Type
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

REM -- General Error Message for CMake
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

REM -- NSIS Installer Build Error Message
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

:EOF
CD %BASED%
EXIT /B 0