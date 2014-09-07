@ECHO OFF
REM -- JTSDK-QT Windows CMake Build Script
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
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET SVND=%BASED%\subversion\bin
SET CMAKD=%BASED%\cmake\bin
SET HAMLIBD=%BASED%\hamlib3\mingw32\bin
SET FFTWD=%BASED%\fftw3f
SET NSISD=%BASED%\NSIS
SET GCCD=%BASED%\qt5\Tools\mingw48_32\bin
SET QT5D=%BASED%\qt5\5.2.1\mingw48_32\bin
SET SRCD=%BASED%\src
SET TOOLS=%BASED%\tools
SET SCRIPTS=%TOOLS%\scripts
SET PATH=%BASED%;%SVND%;%CMAKED%;%HAMLIBD%;%FFTWD%;%GCCD%;%NSISD%;%QT5D%;%SRCD%;%TOOLS%;%SCRIPTS%;%WINDIR%;%WINDIR%\System32

REM ------------------------------------------------------------------
REM -- START MAIN SCRIPT
REM ------------------------------------------------------------------

REM -- USER INPUT FILED 1 = %1
REM -- Set App_Name and ToolChain File based on user input
SET APP_NAME=
IF /I [%1]==[wsjtx] (SET APP_NAME=wsjtx
SET TCHAIN=%BASED%\jtsdk-toolchain.cmake
) ELSE IF /I [%1]==[wsprx] (SET APP_NAME=wsprx
SET TCHAIN=%BASED%\jtsdk-toolchain1.cmake
) ELSE IF /I [%1]==[map65] (SET APP_NAME=map65
SET TCHAIN=%BASED%\jtsdk-toolchain1.cmake
) ELSE ( GOTO BADNAME )

REM - USER INPUT FIELD 2 == %2
REM -- Set Release, Debug and target based on user input
IF /I [%2]==[rconfig] (SET OPTION=Release
SET BTREE=true
) ELSE IF /I [%2]==[rinstall] (SET OPTION=Release
SET BINSTALL=true
) ELSE IF /I [%2]==[package] (SET OPTION=Release
SET BPKG=true
) ELSE IF /I [%2]==[dconfig] (SET OPTION=Debug
SET BTREE=true
) ELSE IF /I [%2]==[dinstall] (SET OPTION=Debug
SET BINSTALL=true
) ELSE ( GOTO BADTYPE )

REM - MISC VARS
SET JJ=%NUMBER_OF_PROCESSORS%
SET APP_DIR=%BASED%\%APP_NAME%
SET BUILDD=%BASED%\%APP_NAME%\build
SET INSTALLD=%BASED%\%APP_NAME%\install
SET PACKAGED=%BASED%\%APP_NAME%\package
SET SUPPORT=%BASED%\appsupport
SET WSJTXPKG=wsjtx-1.4.0-win32.exe

REM ------------------------------------------------------------------
REM -- START MAIN BUILD
REM ------------------------------------------------------------------
CD %BASED%
IF NOT EXIST %SRCD%\NUL mkdir %SRCD%
IF NOT EXIST %BUILDD%\%OPTION%\NUL mkdir %BUILDD%\%OPTION%
IF NOT EXIST %INSTALLD%\%OPTION%\NUL mkdir %INSTALLD%\%OPTION%
IF NOT EXIST %PACKAGED%\NUL mkdir %PACKAGED%
CLS
ECHO -------------------------------
ECHO %APP_NAME% CMake Build Script
ECHO -------------------------------
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
ECHO Configuring %OPTION% Build Tree For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=%OPTION% ^
-DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished %OPTION% Build Tree Configuration for: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO BASE BUILD CONFIGURATION
ECHO   Package ............ %APP_NAME%
ECHO   Type ............... %OPTION%
ECHO   Build Directory .... %BUILDD%\%OPTION%
ECHO   Build Option List .. %BUILDD%\%OPTION%\CmakeCache.txt
ECHO   Target Directory ... %INSTALLD%\%OPTION%
ECHO.
ECHO LIST ALL BUILD CONFIG OPTIONS
ECHO   cat %BUILDD%\%OPTION%\CmakeCache.txt ^| less
ECHO   :: Arrow Up / Down to dcroll through the list
ECHO   :: Type ^(H^) for help with search commands
ECHO   :: Type ^(Ctrl+C then Q^) to exit
ECHO.
ECHO TO BUILD INSTALL TARGET
ECHO   cd %BUILDD%\%OPTION%
ECHO   cmake --build . --target install
ECHO.
ECHO TO BUILD WINDOWS NSIS INSTALLER
ECHO   cd %BUILDD%\%OPTION%
ECHO   cmake --build . --target package
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
ECHO Building %OPTION% Install Target For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
REM -- Ensure Build Tree is configured
ECHO .. Configuring %OPTION% Build Tree
ECHO.
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=%OPTION% ^
-DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
ECHO.
ECHO .. Stating Install Target build for ^( %APP_NAME% ^)
ECHO.
REM -- Build Install Target
cmake --build . --target install
GOTO POSTBUILD1

REM ------------------------------------------------------------------
REM -- BUILD NSIS INSTALLER
REM ------------------------------------------------------------------
) ELSE IF [%BPKG%]==[true] (
IF /I [%APP_NAME%]==[wsprx] (GOTO PKGMSG )
IF /I [%APP_NAME%]==[map65] (GOTO PKGMSG )
CLS
CD %BUILDD%\%OPTION%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Building Installer Package For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
REM - Ensure Build Tree is Configured
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=%OPTION% ^
-DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%

REM - Build the Installer
:BUILDPKG
cmake --build . --target package
IF NOT EXIST %BUILDD%\%OPTION%\%WSJTXPKG% ( GOTO PKGERROR )
mv -u %BUILDD%\%OPTION%\%WSJTXPKG% %PACKAGED%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished Installer Build For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO Installer Name ...... %WSJTXPKG%
ECHO Installer Location .. %PACKAGED%\%WSJTXPKG%
ECHO.
ECHO To Install the package, browse to Installer Location, and
ECHO run as you normally do to install Windows applications.
ECHO.
PAUSE
GOTO EOF
) ELSE ( GOTO UNSUPPORTED )

REM ------------------------------------------------------------------
REM -- POST BUILD RUN APPLICATIONS
REM ------------------------------------------------------------------
:POSTBUILD1
IF /I [%1]==[wsjtx] ( GOTO POSTBUILD2 ) ELSE ( GOTO CPFILES )

:POSTBUILD2
IF /I [%OPTION%]==[Debug] ( GOTO MAKEBAT ) ELSE ( GOTO FINISH )

:CPFILES
SET CPTXT=*.txt *.dat *.conf *.ini
SET RBCP=ROBOCOPY /NS /NC /NFL /NDL /NP /NJS /NJH
%RBCP% %SRCD%\%APP_NAME% %INSTALLD%\%OPTION%\bin %CPTXT% /XF CMake*
cp -r %SUPPORT%\%APP_NAME%\* %INSTALLD%\%OPTION%\bin
cp -r %SUPPORT%\runtime\* %INSTALLD%\%OPTION%\bin
IF NOT EXIST %INSTALLD%\%OPTION%\bin\save\Samples (
mkdir %INSTALLD%\%OPTION%\bin\save\Samples)
GOTO MAKEBAT

:MAKEBAT
SET FILENAME=%APP_NAME%.bat
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished %OPTION% Install Target For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
IF EXIST %APP_NAME%.bat (DEL /Q %APP_NAME%.bat)

REM - RESET HAMLIB DIR for MAP65 & WSPRX
IF NOT [%APP_NAME%]==[wsjtx] (SET HAMLIBD=%BASED%\hamlib\bin)

>%APP_NAME%.bat (
ECHO @ECHO OFF
ECHO REM -- Debug Batch File
ECHO REM -- Part of the JTSDK Project
ECHO SETLOCAL ENABLEEXTENSIONS
ECHO SETLOCAL ENABLEDELAYEDEXPANSION
ECHO SET PATH=%BASED%;%HAMLIBD%;%FFTWD%;%GCCD%;%QT5D%
ECHO START %APP_NAME%.exe
ECHO ENDLOCAL
ECHO EXIT /B 0
)

IF /I [%OPTION%]==[Debug] ( GOTO DEBUG_FINISH
) ELSE ( GOTO FINISH )

:DEBUG_FINISH
ECHO BUILD SUMMARY
ECHO   Build Tree Location .. %BUILDD%\%OPTION%
ECHO   Install Location ..... %INSTALLD%\%OPTION%\bin\%APP_NAME%.bat
ECHO.
ECHO NOTE: When Running ^( %APP_NAME% ^) Debug versions, please use
ECHO       the provided  ^( %APP_NAME%.bat ^) file as this sets up
ECHO       environment variables and support file paths.
ECHO.
PAUSE
GOTO ASK_DEBUG_RUN

:ASK_DEBUG_RUN
ECHO.
ECHO  Would You Like To Run %APP_NAME% Now? ^( y/n ^)
ECHO.
SET ANSWER=
SET /P ANSWER=Type Response: %=%
ECHO.
If /I "%ANSWER%"=="Y" ( GOTO RUN_DEBUG )
If /I "%ANSWER%"=="N" ( GOTO EOF
) ELSE (
CLS
ECHO.
ECHO   Please Answer With: ^( y or n ^) & ECHO. & GOTO ASK_DEBUG_RUN
)

:RUN_DEBUG
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
ECHO .. Starting: ^( %APP_NAME% ^) in Debug Mode
START %APP_NAME%.bat
GOTO EOF

:FINISH
ECHO BUILD SUMMARY
ECHO   Build Tree Location .. %BUILDD%\%OPTION%
ECHO   Install Location ..... %INSTALLD%\%OPTION%\bin\%APP_NAME%.exe
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
ECHO .. Starting: ^( %APP_NAME% ^) in Debug Mode
START %APP_NAME%.exe
EXIT /B 0
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
ECHO  Use: %~dp0\jtsdk-qtenv.bat
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
ECHO must first perform an SVN checkout from 
ECHO SourceForge.
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
ECHO  Configure Build Tree: .... build %APP_NAME% rconfig
ECHO  Build Install Target: .... build %APP_NAME% rinstall
ECHO.
ECHO OPTIONAL
ECHO  Build Installer Package: .. build %APP_NAME% package
ECHO.
GOTO EOF

REM -- Unsupported Application Name
:BADNAME
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO                UNSUPPORTED APPLICATION
ECHO -----------------------------------------------------------------
ECHO ^( %1% ^) Check Spelling or Syntax
ECHO.
ECHO USAGE:  build ^(app_name^) ^(type^)
ECHO.
ECHO  Applications ... wsjtx wsprx, map65
ECHO  Release Types .. rconfig rinstall package
ECHO  Debug Types .... dconfig dinstall
ECHO    rconfig ...... Configure Release Build Tree
ECHO    rinstall ..... Build Release Install Target
ECHO    dconfig ...... Configure Debug Build Tree
ECHO    dinstall ..... Build Debug Install Target
ECHO    package ...... Build NSIS Installer ^( WSJT-X Only ^)
ECHO.
ECHO EXAMPLES
ECHO ----------------------------------------------------------
ECHO Configure Build Tree:
ECHO   Type:  build wsjtx rconfig
ECHO.
ECHO Build Install Target:
ECHO   Type:  build wsjtx rinstall
ECHO.
ECHO Build NSIS Installer
ECHO   Type:  build wsjtx package
ECHO.
PAUSE
GOTO EOF

REM -- Unsupported Build Type
:BADTYPE
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO                UNSUPPORTED BUILD TYPE
ECHO -----------------------------------------------------------------
ECHO ^( %2% ^) Check Spelling or Syntax
ECHO.
ECHO USAGE:  build ^(app_name^) ^(type^)
ECHO.
ECHO  Applications ... wsjtx wsprx, map65
ECHO  Release Types .. rconfig rinstall package
ECHO  Debug Types .... dconfig dinstall
ECHO    rconfig ...... Configure Release Build Tree
ECHO    rinstall ..... Build Release Install Target
ECHO    dconfig ...... Configure Debug Build Tree
ECHO    dinstall ..... Build Debug Install Target
ECHO    package ...... Build NSIS Installer ^( WSJT-X Only ^)
ECHO.
ECHO EXAMPLES
ECHO ----------------------------------------------------------
ECHO Configure Build Tree:
ECHO   Type:  build wsjtx rconfig
ECHO.
ECHO Build Install Target:
ECHO   Type:  build wsjtx rinstall
ECHO.
ECHO Build NSIS Installer
ECHO   Type:  build wsjtx package
ECHO.
PAUSE
GOTO EOF

REM -- Unsupported Installer Build
:PKGMSG
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO             UNSUPPORTED INSTALLER BUILD
ECHO -----------------------------------------------------------------
ECHO.
ECHO  ^( %APP_NAME% ^) - Does not have a Package Target. Only
ECHO  WSJT-X is supported at the this time. Furute updates will
ECHO  include an installer build, either InnoSetup or NSIS, but
ECHO  a date has yet to be determined.
ECHO.
ECHO  You can still build and run ^( %APP_NAME% ^) by issuing the
ECHO  folling command:
ECHO.
ECHO  build %APP_NAME% rinstall
ECHO.
ECHO  Then, browse too, and run:
ECHO  %INSTALLD%\%OPTION%\%APP_NAME%.exe
ECHO.
ECHO.
PAUSE
GOTO EOF

REM -- Installer Build Error Message
:PKGERROR
CLS
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
PAUSE
GOTO EOF

:EOF
CD /D %BASED%
EXIT /B 0