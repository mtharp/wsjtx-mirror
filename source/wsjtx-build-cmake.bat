@ECHO OFF
REM -- WSJT-X Windows Build Script Using CMake
REM -- Part of the WSJT Documentation Project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 1B
TITLE WSJT Applicaiton Build Script ( CMake )

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
SET BUILDD=%BASED%\%APP_NAME%\%APP_NAME%-build
SET INSTALLD=%BASED%\%APP_NAME%\%APP_NAME%-install
SET TCHAIN=%APP_NAME%-toolchain.cmake
SET TCLOC=%BASED%\%TCHAIN%
SET SVND=%BASED%\subversion\bin
SET CMAKED=%BASED%\cmake\bin
SET DLLD=%BASED%\qt5\5.2.1\mingw48_32\bin
SET LIBD=%BASED%\qt5\Tools\mingw48_32\bin
SET PLUG=%BASED%\qt5\5.2.1\mingw48_32\plugins\platforms
SET DEVGSRC=svn://svn.code.sf.net/p/wsjt/wsjt/branches/doc/dev-guide/source
SET WSJTXCO=svn co svn://svn.code.sf.net/p/wsjt/wsjt/branches/%APP_NAME%
SET JJ=%NUMBER_OF_PROCESSORS%
SET PATH=%BASED%;%SRCD%;%BUILDD%;%INSTALLD%;%SVND%;%CMAKED%;%DLLD%;%LIBD%;%PATH%

REM -- FILES NEEDED AFTER: mingw32-make -j%JJ% install
SET CPTXT=*.txt *.dat *.conf
SET CPLU=qwin*
SET CPQT=Qt5Core.dll Qt5Gui.dll Qt5Multimedia.dll Qt5Network.dll Qt5Widgets.dll
SET CPICU=icu*.dll
SET CPLIB=libgcc_s_dw2-1.dll libgfortran-3.dll libstdc++-6.dll libquadmath-0.dll libwinpthread-1.dll
SET RBCP=ROBOCOPY /NS /NC /NFL /NDL /NP

REM -- CHECK CRITICAL TOOLS CAN BE FOUND
cmake --version >nul 2>null || SET APP=CMake && GOTO ERROR1
svn --version >nul 2>null || SET APP=SVN && GOTO ERROR1
mingw32-make --version >nul 2>null || SET APP=Mingw32-Make && GOTO ERROR1
gfortran --version >nul 2>null || SET APP=Gfortran && GOTO ERROR1
g++ --version >nul 2>null || SET APP=G++ && GOTO ERROR1
DEL /Q null

REM -- START MAIN BUILD
CD %BASED%
CLS
ECHO -------------------------------
ECHO %APP_NAME% CMake Build Script
ECHO -------------------------------
ECHO.

REM - USER CLI BUILD OPTION
IF /I [%1]==[-d] (SET OPTION=Debug) ELSE (SET OPTION=Release)

REM - CHECK %APP_NAME%\DIR
IF NOT EXIST %SRCD%\NUL mkdir %SRCD%
IF NOT EXIST %APP_DIR%\NUL mkdir %APP_DIR%

REM -- TEST and/or CHECKOUT TOOLCHAIN FILE
IF NOT EXIST %TCHAIN% (GOTO GETTC) ELSE (GOTO ASK)

:ASK
REM -- ASK TO OVERWRITE TOOL-CHAIN-FILE IF EXISTS
ECHO.
ECHO Overwrite Tool Chain File? ( Y/N )
SET ANSWER=
SET /P ANSWER=Type responce: %=%
If /I "%ANSWER%"=="N" GOTO SKIPTC
If /I "%ANSWER%"=="Y" (
GOTO GETTC
) ELSE (
CLS
ECHO.
ECHO Please Answer With: ^( Y or N ^) & ECHO. & GOTO ASK
)

:GETTC
REM -- USE FORCE TO ENSURE OVERWRITE IF :ASK == YES
ECHO Downloading: %TCHAIN%
svn export --force %DEVGSRC%/%TCHAIN% %BASED%/

:SKIPTC
ECHO.
CD %SRCD%
ECHO Checking out: %APP_NAME%

REM -- CHECKOUT BRANCH
%WSJTXCO%
IF NOT EXIST %BUILDD%\%OPTION%\NUL mkdir %BUILDD%\%OPTION%
CD %BUILDD%\%OPTION%
ECHO Starting Build For: ^( %APP_NAME% ^)
ECHO.
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCLOC% ^
-DCMAKE_BUILD_TYPE=%OPTION% -DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%

REM -- MAKE INSTALL: MAKE_INSTALL_PREFIX\install\{Release, Debug}\bin
mingw32-make -j%JJ% install

REM -- POST BUILD COPY
CD %BASED%
%RBCP% %SRCD%\wsjtx %INSTALLD%\%OPTION%\bin %CPTXT% /XF CMake* *.cmake
%RBCP% %DLLD% %INSTALLD%\%OPTION%\bin %CPICU% %CPQT%
%RBCP% %PLUG% %INSTALLD%\%OPTION%\bin\platforms %CPLU%
%RBCP% %LIBD% %INSTALLD%\%OPTION%\bin %CPLIB%
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

:EOF
ENDLOCAL
EXIT /B 0