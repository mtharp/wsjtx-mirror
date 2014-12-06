@ECHO OFF
REM -- JTSDK Windows WSJT Build Script
REM -- Part of the JTSDK Project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 0A

:: TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DCLICK

:: PATH VARS
SET LANG=en_US
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET SRCD=%BASED%\src
SET TOOLS=%BASED%\tools
SET MINGW=%BASED%\mingw32\bin
SET INNOD=%BASED%\inno5
SET SVND=%BASED%\subversion\bin
SET SCRIPTS=%BASED%\tools\scripts
SET LIBRARY_PATH=""
SET PYTHONPATH=%BASED%\Python33;%BASED%\Python33\Scripts;%BASED%\Python33\DLLs;%BASED%\Python33\Tools\Scripts
SET PATH=%BASED%;%MINGW%;%PYTHONPATH%;%SRCD%;%SVND%;%TOOLS%;%INNOD%;%SCRIPTS%;%WINDIR%;%WINDIR%\System32

:: VARS USED IN PROCESS
SET JJ=%NUMBER_OF_PROCESSORS%
SET python=%BASED%\Python33\python.exe
SET CP=%TOOLS%\cp.exe
SET MV=%TOOLS%\mv.exe
IF NOT EXIST %BASED%\src\NUL mkdir %BASED%\src
GOTO SELECT

:: SET WSJT or WSPR
:SELECT
IF /I [%1]==[wsjt] (
SET APP_NAME=wsjt
SET APP_SRC=%SRCD%\trunk
SET INSTALLDIR=%BASED%\wsjt\install
SET PACKAGEDIR=%BASED%\wsjt\package
GOTO WSJT_OPT2
) ELSE IF /I [%1]==[wspr] (
SET APP_NAME=wspr
SET APP_SRC=%SRCD%\wspr
SET INSTALLDIR=%BASED%\wspr\install
SET PACKAGEDIR=%BASED%\wspr\package
GOTO WSPR_OPT2
) ELSE IF /I [%1]==[help] (
GOTO BUILD_HELP
) ELSE ( GOTO UNSUPPORTED_APP )

:: WSJT USER INPUT FIELD $2 == %2 ^( %TARGET% ^)
:WSJT_OPT2
IF /I [%2]==[] (
SET TARGET=install
GOTO START
) ELSE IF /I [%2]==[install] (
SET TARGET=install
GOTO START
) ELSE IF /I [%2]==[package] (
SET TARGET=package
GOTO START
) ELSE IF /I [%2]==[libjt.a] (
SET TARGET=libjt.a
GOTO START
) ELSE IF /I [%2]==[jt65code.exe] (
SET TARGET=jt65code.exe
GOTO START
) ELSE IF /I [%2]==[jt4code.exe] (
SET TARGET=jt4code.exe
GOTO START
) ELSE IF /I [%2]==[WsjtMod/Audio.pyd] (
SET TARGET=WsjtMod/Audio.pyd
GOTO START
) ELSE ( GOTO UNSUPPORTED_TARGET )

:: WSPR USER INPUT FIELD $2 == %2 ^( %TARGET% ^)
:WSPR_OPT2
IF /I [%2]==[] (
SET TARGET=install
GOTO START
) ELSE IF /I [%2]==[install] (
SET TARGET=install
GOTO START
) ELSE IF /I [%2]==[package] (
SET TARGET=package
GOTO START
) ELSE IF /I [%2]==[wspr0.exe] (
SET TARGET=wspr0.exe
GOTO START
) ELSE IF /I [%2]==[WSPRcode.exe] (
SET TARGET=WSPRcode.exe
GOTO START
) ELSE IF /I [%2]==[libwspr.a] (
SET TARGET=libwspr.a
GOTO START
) ELSE IF /I [%2]==[fmtest] (
SET TARGET=fmtest.exe
GOTO START
) ELSE IF /I [%2]==[fmtave] (
SET TARGET=fmtave.exe
GOTO START
)  ELSE IF /I [%2]==[fcal] (
SET TARGET=fcal.exe
GOTO START
) ELSE IF /I [%2]==[fmeasure] (
SET TARGET=fmeasure.exe
GOTO START
) ELSE IF /I [%2]==[sound] (
SET TARGET=sound.o
GOTO START
) ELSE IF /I [%2]==[gmtime2] (
SET TARGET=sound.o
GOTO START
) ELSE IF /I [%2]==[w.pyd] (
SET TARGET=WsprMod/w.pyd
GOTO START
) ELSE ( GOTO UNSUPPORTED_TARGET )

:START
:: START MAIN BUILD
CD %BASED%
CLS
ECHO -----------------------------------------------------------------
ECHO  Starting Build for ^( %APP_NAME% %TARGET% ^)
ECHO -----------------------------------------------------------------
ECHO.

:: IF SRCD EXISTS, CHECK FOR PREVIOUS CO
IF NOT EXIST %APP_SRC%\.svn\NUL (
mkdir %BASED%\src
GOTO COMSG
) ELSE (GOTO ASK_SVN)

:: START WSPR BUILD
:ASK_SVN
ECHO Update from SVN Before Building? ^( y/n ^)
SET ANSWER=
ECHO.
SET /P ANSWER=Type Response: %=%
If /I "%ANSWER%"=="N" GOTO START_BUILD
If /I "%ANSWER%"=="Y" (
GOTO SVN_UPDATE
) ELSE (
ECHO.
ECHO Please Answer With: ^( Y or N ^)
GOTO ASK_SVN
)

:: UPDATE WSJT FROM SVN
:SVN_UPDATE
ECHO.
ECHO UPDATING ^( %APP_SRC% ^ )
cd %APP_SRC%
start /wait svn update
GOTO START_BUILD

:: START MAIN BUILD PROCESS
:START_BUILD
ECHO.
IF NOT EXIST %BASED%\%APP_NAME%\NUL ( mkdir %BASED%\%APP_NAME% )
CD /D %APP_SRC%
ECHO ..Performing make clean first
mingw32-make -f Makefile.jtsdk clean >nul 2>&1
ECHO ..Running mingw32-make To Build ^( %TARGET% ^) Target
ECHO.
mingw32-make -f Makefile.jtsdk
ECHO.
IF ERRORLEVEL 1 ( GOTO BUILD_ERROR )
ECHO -----------------------------------------------------------------
ECHO   MAKEFILE EXIT STATUS: ^( %ERRORLEVEL% ^) is OK
ECHO -----------------------------------------------------------------
ECHO.
IF /I [%TARGET%]==[install] (
GOTO REV_NUM
) ELSE IF /I [%TARGET%]==[package] ( 
GOTO MAKE_PACKAGE
) ELSE ( GOTO SINGLE_FINISHED )

:: BEGIN MAIN BUILD
:MAKE_PACKAGE
CD /D %APP_SRC%
ECHO.
ECHO ..Running InnoSetup for: ^( %APP_NAME% ^)
mingw32-make -s -f Makefile.jtsdk package
IF ERRORLEVEL 1 ( GOTO BUILD_ERROR )
GOTO REV_NUM

:: GET SVN r NUMBER, STILL in %APP_SRC%
:REV_NUM
ECHO ..Getting SVN Revision Information
svn info %APP_SRC% |grep Revision |awk "{print $2}" >r.txt
SET /P SVN_VER=<r.txt & rm r.txt
:: CREATE THE SVN VERSION COPY FOR HISTORICAL REFERENCE
IF /I [%TARGET%]==[package] ( GOTO PKG_FINISH )
ECHO ..Copying files to install directory
IF EXIST %BASED%\%APP_NAME%\%APP_NAME%-r%SVN_VER% ( 
rm -r %BASED%\%APP_NAME%\%APP_NAME%-r%VER% )
XCOPY %INSTALLDIR% %BASED%\%APP_NAME%\%APP_NAME%-r%SVN_VER% /I /E /Y /q >/nul
IF ERRORLEVEL 0 ( GOTO MAKEBAT ) ELSE ( GOTO COPY_ERROR )

:: GENERATE RUNTIME BATCH FILE
:MAKEBAT
CD /D %BASED%\%APP_NAME%\%APP_NAME%-r%SVN_VER%
ECHO ..Generating Batch File
IF EXIST %APP_NAME%.bat (DEL /Q %APP_NAME%.bat)
>%APP_NAME%.bat (
ECHO @ECHO OFF
ECHO REM -- WSJT-WSPR batch File
ECHO REM -- Part of the JTSDK Project
ECHO COLOR 0A
ECHO bin\%APP_NAME%.exe
ECHO EXIT /B 0
)
ECHO.
GOTO FINISHED

REM -- SINGLE TARGET BUILD MESSAGE
:SINGLE_FINISHED
ECHO.
ECHO .. Finished building ^( %APP_NAME% %TARGET% ^)
ECHO.
GOTO EOF

REM -- FINISHED INSTALL OR PACKAGE TARGET BUILDS
:PKG_FINISH
ECHO ..Copying files to install direcotry
IF EXIST %BASED%\%APP_NAME%\%APP_NAME%-r%SVN_VER% ( 
rm -r %BASED%\%APP_NAME%\%APP_NAME%-r%SVN_VER% )
XCOPY %INSTALLDIR% %BASED%\%APP_NAME%\%APP_NAME%-r%SVN_VER% /I /E /Y /q >nul
IF ERRORLEVEL 1 ( GOTO BUILD_ERROR )
ECHO ..Finisned InnoSetup
ECHO ..Exit Status: ^( %ERRORLEVEL% ^) is OK
GOTO FINISHED

:: FINISHED INSTALL OR PACKAGE TARGET BUILDS
:FINISHED
CD /D %BASED%
ECHO.
ECHO -----------------------------------------------------------------
ECHO   ^( %APP_NAME%-r%VER% ^) BUILD COMPLETE
ECHO -----------------------------------------------------------------
ECHO.
ECHO  Source Dir ....: %APP_SRC%
ECHO  Install Dir ...: %INSTALLDIR%
ECHO  Revision Dir ..: %BASED%\%APP_NAME%\%APP_NAME%-r%SVN_VER%
:: IF INSTALL, PRINT BATCH FILE PAT
IF /I [%TARGET%]==[install] ( 
ECHO  Batch File ....: %BASED%\%APP_NAME%\%APP_NAME%-r%SVN_VER%\%APP_NAME%.bat
)
:: IF PACKAGE, PRINT PACKAGE LOCATION
IF /I [%TARGET%]==[package] (
ECHO  Package Dir ...: %PACKAGEDIR%
)
GOTO ASKRUN

:: ASK TO RUN THE LAST BUILD
:ASKRUN
ECHO.
ECHO  Would You Like To Run %APP_NAME% Now? ^( y/n ^)
ECHO.
SET ANSWER=
SET /P ANSWER=Type Response: %=%
ECHO.
If /I "%ANSWER%"=="Y" GOTO RUN_APP
If /I "%ANSWER%"=="N" (
GOTO EOF
) ELSE (
ECHO.
ECHO  Please Answer With: ^( y or n ^) & ECHO. & GOTO ASKRUN
)
GOTO EOF

:RUN_APP
ECHO.
ECHO Starting: ^( %APP_NAME% ^)
CD %BASED%\%APP_NAME%\%APP_NAME%-r%VER%
START %APP_NAME%.bat & GOTO EOF

REM ----------------------------------------------------------------------------
REM  MESSAGE SECTION
REM ----------------------------------------------------------------------------

:: TOOL CHAIN ERROR MESSAGE
:UNSUPPORTED
COLOR 1E
CLS
ECHO.
ECHO ----------------------------------------
ECHO        UNSUPPORTED APPLICATION
ECHO ----------------------------------------
ECHO       ^( %1 ^) Is Unsupported
ECHO.
ECHO            WSJT and WSPR
ECHO.
ECHO      Are the Only Python Builds
ECHO.
ECHO        Please Check Your Entry
ECHO.
PAUSE
GOTO EOF

:: HELP MENU FOR BUILD OPTIONS
:BUILD_HELP
CLS
ECHO.                               
ECHO -----------------------------------------------------------------
ECHO BUILD TARGET HELP: ^( WSJT and WSPR ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO USAGE:  build ^(app_name^) ^(target^)
ECHO.
ECHO  App Names ...... WSJT WSPR
ECHO.
ECHO  WSJT Targets ... libjt.a jt65code.exe jt4code.exe
ECHO                   WsjtMod/Audio.pyd install package
ECHO.
ECHO  WSPR Targets ... wspr0.exe WSPRcode.exe libwspr.a fmtest
ECHO                   fmtave fcal fmeasure sound gmtime2
ECHO                   WsprMod/w.pyd install package
ECHO.
ECHO DEFINITIONS:
ECHO -----------------------------------------------------------------
ECHO  install ........ Build Full Test Version
ECHO  package ........ Build Inno5 Win32 Installer package
ECHO.
ECHO EXAMPLE ^( WSJT ^):
ECHO -----------------------------------------------------------------
ECHO Build Install Target:
ECHO  Script Usage .. build wsjt install
ECHO  Command Line .. make -f Makefile.jtsdk install
ECHO.
ECHO Build Installer Package:
ECHO  Script Usage .. build wsjt package
ECHO  Command Line .. make -f Makefile.jtsdk package
ECHO.
ECHO Build Multiple Targets ^( Command Line Only ^)
ECHO  CLI ........... make -f Makefile.jtsdk libjt.a jt65code.exe
ECHO.
GOTO EOF
) ELSE IF /I [%2]==[sound] (
SET TARGET=sound.o
GOTO START
) ELSE IF /I [%2]==[gmtime2] (
SET TARGET=sound.o
GOTO START
) ELSE IF /I [%2]==[w.pyd] (
SET TARGET=WsprMod/w.pyd

REM - USER INPUT UNSUPPORTED APPLICATION
:UNSUPPORTED_APP
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO  ^( %1 ^) Is An Unsupported Application Name
ECHO -----------------------------------------------------------------
GOTO UMSG

REM - USER INPUT INCORRECT BUILD TARGET
:UNSUPPORTED_TARGET
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO  ^( %2 ^) IS AN INVALID TARGET FOR ^( %1% ^)
ECHO -----------------------------------------------------------------
GOTO UMSG

:UMSG
ECHO. 
ECHO  After the pause, the build help menu
ECHO  will be displayed. Please use the syntax
ECHO  as outlined on on help and choose the correct
ECHO  application to build.
ECHO.
PAUSE
GOTO BUILD_HELP

REM -- WARN ON DOUBLE CLICK
:DCLICK
@ECHO OFF
REM -- Double Click Error Message
REM -- Part of the JTSDK Project
CLS
COLOR 1E
ECHO -------------------------------
ECHO     DOUBLE CLICK WARNING
ECHO -------------------------------
ECHO.
ECHO  Please Use JTSDK-PY Enviroment
ECHO.
ECHO    %BASED%\jtsdk-pyenv.bat
ECHO.
PAUSE
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
ECHO  Type: checkout %APP_NAME%
ECHO  After Checkout, Type: build %APP_NAME%
IF /I [%APP_NAME%]==[wsjt] (
ECHO.
ECHO FOR DEV CHECKOUT:
ECHO  ^cd src
ECHO  svn co https://%USERNAME%@svn.code.sf.net/p/wsjt/wsjt/trunk
ECHO  ^cd ..
ECHO  build %APP_NAME%
ECHO.
ECHO DEV NOTE: Change ^( %USERNAME% ^) to your Sourforge User Name
GOTO EOF
)
IF /I [%APP_NAME%]==[wspr] (
ECHO.
ECHO FOR DEV CHECKOUT:
ECHO  ^cd src
ECHO  svn co https://%USERNAME%@svn.code.sf.net/p/wsjt/wsjt/branches/wspr
ECHO  ^cd ..
ECHO  build %APP_NAME%
ECHO.
ECHO DEV NOTE: Change ^( %USERNAME% ^) to your Sourforge User Name.
GOTO EOF
)

REM -- Compiler build warning message
:BUILD_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO  Compiler Build Warning
ECHO -----------------------------------------------------------------
ECHO. 
ECHO  mingw32-make exited with a non-(0) build status. Check and or 
ECHO  correct the error, perform a clean, then re-make the target.
ECHO.
ENDLOCAL
EXIT /B %ERRORLEVEL%

REM -- Final folder creation error message
:COPY_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO  Error Creating ^( %APP_NAME%-r%VER% ^)
ECHO -----------------------------------------------------------------
ECHO. 
ECHO  An error occured when trying to copy the build to it's final
ECHO  location: C:\JTSDK-PY\%APP_NAME%\%APP_NAME%-r%VER%
ECHO.
ECHO  If the probblems continues, please contact the wsjt-dev group.
ECHO.
COLOR 0A
ENDLOCAL
EXIT /B %ERRORLEVEL%

REM ----------------------------------------------------------------------------
REM  END OF JTSDK-PYTHON.BAT
REM ----------------------------------------------------------------------------

:EOF
COLOR 0A
ENDLOCAL

EXIT /B 0
