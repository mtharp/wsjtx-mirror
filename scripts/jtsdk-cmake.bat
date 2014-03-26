@ECHO OFF
REM -- JTSDK-QT Windows CMake Build Script
REM -- Part of the JTSDK Project
CLS
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 1B

REM -- TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI GOTO DCLICKERROR

REM -- SET PATH VARS
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET SVND=%BASED%\subversion\bin
SET CMAKD=%BASED%\cmake\bin
SET GCCD=%BASED%\mingw48_32\bin
SET QT5D=%BASED%\qt5\5.2.1\mingw48_32\bin
SET SRCD=%BASED%\src
SET TOOLS=%BASED%\tools
SET SCRIPTS=%TOOLS%\scripts
SET PATH=%BASED%;%SVND%;%CMAKED%;%GCCD%;%QT5D%;%SRCD%;%TOOLS%;%SCRIPTS%;%WINDIR%;%WINDIR%\System32

REM - MISC VARS
SET JJ=%NUMBER_OF_PROCESSORS%
SET TCHAIN=%BASED%\jtsdk-toolchain.cmake
SET APP_DIR=%BASED%\%APP_NAME%
SET BUILDD=%BASED%\%APP_NAME%\build
SET INSTALLD=%BASED%\%APP_NAME%\install
SET SUPPORT=%BASED%\appsupport

REM -- START MAIN SCRIPT
REM -- USER INPUT FILED 1 = %1
SET SUPPORTED=(map65 wsjtx wsprx)
IF /I [%1]==[wsjtx] (SET APP_NAME=wsjtx
) ELSE IF /I [%1]==[wsprx] (SET APP_NAME=wsprx
) ELSE IF /I [%1]==[map65] (SET APP_NAME=map65
) ELSE (GOTO UNSUPPORTED)

REM - USER INPUT FIELD 2 == %2
IF /I [%2]==[-d] (SET OPTION=Debug) ELSE (SET OPTION=Release)

REM -- START MAIN BUILD
CD %BASED%
mkdir %SRCD%
CLS
ECHO -------------------------------
ECHO %APP_NAME% CMake Build Script
ECHO -------------------------------
ECHO.

REM -- CHECK IN %APP_NAME\.svn IS PRESENT
IF NOT EXIST %SRCD%\%APP_NAME%\.svn\NUL (
GOTO COMSG
) ELSE (
GOTO SVNASK
)

REM -- ASK TO UPDATE FROM SVN
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
ECHO Please Answer With: ^( Y or N ^) & ECHO. & GOTO ASK
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
mkdir %BUILDD%\%OPTION%
CD %BUILDD%\%OPTION%
ECHO.
ECHO Starting Build For: ^( %APP_NAME% ^)
ECHO.
COLOr 1B
cmake -G "MinGW Makefiles" ^
-DCMAKE_COLOR_MAKEFILE=OFF ^
-DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=%OPTION% ^
-DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME% 
COLOR 1B

REM -- target \JTSDK\%APP_NAME%\install\{Release, Debug}\bin
mingw32-make -j%JJ% install
COLOR 1B
GOTO CPFILES

REM -- POST BUILD COPY - BASED APP TYPE
:CPFILES
SET CPTXT=*.txt *.dat *.conf *.ini
SET RBCP=ROBOCOPY /NS /NC /NFL /NDL /NP /NJS /NJH
%RBCP% %SRCD%\%APP_NAME% %INSTALLD%\%OPTION%\bin %CPTXT% /XF CMake*
cp -r %SUPPORT%\%APP_NAME%\* %INSTALLD%\%OPTION%\bin
cp -r %SUPPORT%\runtime\* %INSTALLD%\%OPTION%\bin

REM -- MAKE NEEDED DIRECTORY
IF NOT EXIST %INSTALLD%\%OPTION%\bin\save\Samples (
mkdir %INSTALLD%\%OPTION%\bin\save\Samples)
GOTO FINISHED

REM - TOOL CHAIN ERROR MESSAGE
:UNSUPPORTED
CLS
ECHO.
ECHO ------------------------------
ECHO    UNSUPPORTED APPLICATION
ECHO ------------------------------
ECHO Currently, ^( %1 ^) CMake build 
ECHO        is not Supported
ECHO.
ECHO.
PAUSE
CLS
GOTO QTINFO
EXIT /B 0

REM - DOUBLE-CLICK ERROR MESSAGE
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

REM - COMPILER ERRORS
:BUILDRROR
CLS
@ECHO OFF
ECHO -------------------------------
ECHO          BUILD ERROR
ECHO -------------------------------
ECHO.
ECHO    CMake Existed with Errors
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
CD /D %SRCD%\%APP_NAME%
svn cleanup
CLS
ECHO -------------------------------
ECHO       Cleanup Complete
ECHO -------------------------------
ECHO.
ECHO         Now exiting
sleep 2
GOTO EOF

:FINISHED
ECHO.
ECHO -------------------------------
ECHO   %APP_NAME% Build Complete
ECHO -------------------------------
ECHO.
ECHO File Locaiton: %INSTALLD%\%OPTION%\bin\%APP_NAME%.exe
ECHO.
GOTO ASKRUN

:ASKRUN
ECHO Would You Like To Run %APP_NAME% Now? ^( y/n ^)
ECHO.
SET ANSWER=
SET /P ANSWER=Type Response: %=%
ECHO.
If /I "%ANSWER%"=="Y" GOTO RUNAPP
If /I "%ANSWER%"=="N" (
GOTO EOF
) ELSE (
CLS
ECHO.
ECHO Please Answer With: ^( y or n ^) & ECHO. & GOTO ASKRUN
)
GOTO EOF

:RUNAPP
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
ECHO Starting: %APP_NAME%
START %APP_NAME%.exe
GOTO EOF

:COMSG
CLS
ECHO ----------------------------------------
ECHO %SRCD%\%APP_NAME% Was Not Found
ECHO ----------------------------------------
ECHO.
ECHO In order to build ^( %APP_NAME% ^) you
ECHO must first perform a checkout from 
ECHO SourceForge, then type: build %APP_NAME%
ECHO.
ECHO ANONYMOUS CHECKOUT ^( %APP_NAME% ^):
ECHO  ^cd src
ECHO  svn co svn://svn.code.sf.net/p/wsjt/wsjt/branches/%APP_NAME%
ECHO  ^cd ..
ECHO  build %APP_NAME%
ECHO.
ECHO DEV CHECKOUT:
ECHO  ^cd src
ECHO  svn co https://%USERNAME%@svn.code.sf.net/p/wsjt/wsjt/branches/%APP_NAME%
ECHO  ^cd ..
ECHO  build %APP_NAME%
ECHO.
ECHO DEV NOTE: Change ^( %USERNAME% ^) to your Sourforge User Name
GOTO EOF

:EOF
CD /D %BASED%
ENDLOCAL
EXIT /B 0