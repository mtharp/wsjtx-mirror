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
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET SVND=%BASED%\subversion\bin
SET CMAKD=%BASED%\cmake\bin
SET HAMLIBD=%BASED%\hamlib3\mingw32\bin
SET FFTWD=%BASED%\fftw3f
SET GCCD=%BASED%\qt5\Tools\mingw48_32\bin
SET QT5D=%BASED%\qt5\5.2.1\mingw48_32\bin
SET SRCD=%BASED%\src
SET TOOLS=%BASED%\tools
SET SCRIPTS=%TOOLS%\scripts
SET PATH=%BASED%;%SVND%;%CMAKED%;%HAMLIBD%;%FFTWD%;%GCCD%;%QT5D%;%SRCD%;%TOOLS%;%SCRIPTS%;%WINDIR%;%WINDIR%\System32

REM -- START MAIN SCRIPT
REM -- USER INPUT FILED 1 = %1
SET SUPPORTED=(map65 wsjtx wsprx)
IF /I [%1]==[wsjtx] (SET APP_NAME=wsjtx
SET TCHAIN=%BASED%\jtsdk-toolchain.cmake
) ELSE IF /I [%1]==[wsprx] (SET APP_NAME=wsprx
SET TCHAIN=%BASED%\jtsdk-toolchain1.cmake
) ELSE IF /I [%1]==[map65] (SET APP_NAME=map65
SET TCHAIN=%BASED%\jtsdk-toolchain1.cmake
) ELSE (GOTO UNSUPPORTED)

REM - USER INPUT FIELD 2 == %2
SET OPTION=
IF /I [%2]==[-r] (SET OPTION=Release) ELSE (SET OPTION=Debug)

REM - MISC VARS
SET JJ=%NUMBER_OF_PROCESSORS%
SET APP_DIR=%BASED%\%APP_NAME%
SET BUILDD=%BASED%\%APP_NAME%\build
SET INSTALLD=%BASED%\%APP_NAME%\install
SET SUPPORT=%BASED%\appsupport

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
IF NOT EXIST %BUILDD%\%OPTION%\NUL mkdir %BUILDD%\%OPTION%
IF NOT EXIST %INSTALLD%\%OPTION%\NUL mkdir %INSTALLD%\%OPTION%
CD %BUILDD%\%OPTION%
ECHO.
ECHO Starting Build For: ^( %APP_NAME% ^)
ECHO.
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DWSJT_STANDARD_FILE_LOCATIONS=OFF ^
-DCMAKE_COLOR_MAKEFILE=OFF ^
-DCMAKE_BUILD_TYPE=%OPTION% ^
-DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME% 

REM -- target \JTSDK\%APP_NAME%\install\{Release, Debug}\bin
mingw32-make -j%JJ% install
GOTO CHKCOPY

REM -- FILE COPY NO LOGER REQUIRED FOR WSJT-X
:CHKCOPY
IF /I [%1]==[wsjtx] (GOTO GENBAT) ELSE (GOTO CPFILES)

:CPFILES
SET CPTXT=*.txt *.dat *.conf *.ini
SET RBCP=ROBOCOPY /NS /NC /NFL /NDL /NP /NJS /NJH
%RBCP% %SRCD%\%APP_NAME% %INSTALLD%\%OPTION%\bin %CPTXT% /XF CMake*
cp -r %SUPPORT%\%APP_NAME%\* %INSTALLD%\%OPTION%\bin
cp -r %SUPPORT%\runtime\* %INSTALLD%\%OPTION%\bin

REM -- MAKE DIRECTORY IF NEEDED
IF NOT EXIST %INSTALLD%\%OPTION%\bin\save\Samples (
mkdir %INSTALLD%\%OPTION%\bin\save\Samples)
GOTO GENBAT

REM -- GENERATE BATCH FILE FOR DEBUG MODE
:GENBAT
IF /I [%OPTION%]==[Debug] (GOTO MAKEBAT) ELSE (GOTO FINISHED)

:MAKEBAT
SET FILENAME=%APP_NAME%.bat
ECHO.
ECHO GENERATING: ^( %APP_NAME%.bat ^)
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
IF EXIST %APP_NAME%.bat (DEL /Q %APP_NAME%.bat)
>%APP_NAME%.bat (
ECHO @ECHO OFF
ECHO REM -- Debug Batch File
ECHO REM -- Part of the JTSDK Project
ECHO SETLOCAL ENABLEEXTENSIONS
ECHO SETLOCAL ENABLEDELAYEDEXPANSION
ECHO ECHO.
ECHO SET PATH=%BASED%;%HAMLIBD%;%FFTWD%;%GCCD%;%QT5D%
ECHO ECHO.
ECHO START %APP_NAME%.exe
ECHO ECHO.
ECHO ENDLOCAL
ECHO EXIT /B 0
)
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
ECHO %APP_SRC% Was Not Found
ECHO ----------------------------------------
ECHO.
ECHO In order to build ^( %APP_NAME% ^) you
ECHO must first perform a checkout from 
ECHO SourceForge, then type: build %APP_NAME%
ECHO.
ECHO ANONYMOUS CHECKOUT ^( %APP_NAME% ^):
ECHO. 
ECHO  Type: .....  checkout %APP_NAME%
ECHO  Then Type:.. build %APP_NAME%
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
EXIT /B 0