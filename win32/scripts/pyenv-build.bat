::-----------------------------------------------------------------------------::
:: Name .........: pyenv-build.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Build both WSJT and WSPR from source
:: Project URL ..: http://sourceforge.net/projects/jtsdk 
:: Usage ........: This file is run from within pyenv.bat
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: pyenv-build.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: pyenv-build.bat is distributed in the hope that it will be useful, but WITHOUT
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
COLOR 0A


:: TEST DOUBLE CLICK, if YES, GOTO ERROR MESSAGE
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DCLICK


:: PATH VARIABLES
SET LANG=en_US
SET LIBRARY_PATH=""
SET BASED=C:\JTSDK
SET SRCD=%BASED%\src
SET BIN=%BASED%\tools\bin
SET MGW=%BASED%\mingw32\bin
SET INNO=%BASED%\inno5
SET SCR=%BASED%\scripts
SET PYP=%BASED%\Python33
SET PYS=%BASED%\Python33\Scripts
SET PYD=%BASED%\Python33\DLLs
SET SVND=%BASED%\subversion\bin
SET PATH=%BASED%;%MGW%;%PYP%;%PYS%;%PYD%;%BIN%;%SRCD%;%INNO%;%SCR%;%WINDIR%\System32


:: VARS USED IN PROCESS
SET JJ=%NUMBER_OF_PROCESSORS%
SET CP=%BIN%\cp.exe
SET MV=%BIN%\mv.exe
GOTO SELECT


:: SET WSJT or WSPR
:SELECT
IF /I [%1]==[wsjt] (
SET APP_NAME=wsjt
SET APP_SRC=%SRCD%\trunk
SET INSTALLDIR=%SRCD%\trunk\install
SET PACKAGEDIR=%SRCD%\trunk\package
GOTO WSJT_OPT2
) ELSE IF /I [%1]==[wspr] (
SET APP_NAME=wspr
SET APP_SRC=%SRCD%\wspr
SET INSTALLDIR=%SRCD%\wspr\install
SET PACKAGEDIR=%SRCD%\wspr\package
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


:: ------------------------------------------------------------------------------
:: -- START MAIN SCRIPT --
:: ------------------------------------------------------------------------------

:: START MAIN BUILD
:START
CD %BASED%
CLS
ECHO -----------------------------------------------------------------
ECHO   Starting Build for ^( %APP_NAME% %TARGET% Target ^)
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
start /wait svn cleanup
start /wait svn update
GOTO START_BUILD


:: START MAIN BUILD PROCESS
:START_BUILD
ECHO.
IF NOT EXIST %BASED%\%APP_NAME% mkdir %BASED%\%APP_NAME%
CD /D %APP_SRC%
ECHO BUILDING: ^( %APP_NAME% %TARGET% ^)
IF /I [%1]==[wsjt] (
IF EXIST "libjt.a" (
ECHO.
ECHO .. Performing make distclean first
ECHO.
mingw32-make -f Makefile.jtsdk distclean
))
IF /I [%1]==[wspr] (
IF EXIST "libwspr.a" (
ECHO.
ECHO .. Performing make distclean first
ECHO.
mingw32-make -f Makefile.jtsdk distclean
))
ECHO.
ECHO -----------------------------------------------------------------
ECHO   Running mingw32-make to Build The Install Target
ECHO -----------------------------------------------------------------
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


:: BEGIN WSJT MAIN BUILD
:MAKE_PACKAGE
CD /D %APP_SRC%
ECHO.
ECHO BUILDING: ^( %APP_NAME% Win32 Installer ^)
ECHO.
ECHO .. Running mingw32-make To Build The Win32 Installer
ECHO.
mingw32-make -f Makefile.jtsdk package
ECHO.
IF ERRORLEVEL 1 ( GOTO BUILD_ERROR )
ECHO Makefile Exit Status: ^( %ERRORLEVEL% ^) is OK
ECHO.
GOTO REV_NUM


:: GET SVN r NUMBER, STILL in %APP_SRC%
:REV_NUM
ECHO   Getting SVN version number
svn -qv status %APP_NAME%.py |gawk "{print $2}" > r.txt
SET /P VER=<r.txt & rm r.txt


:: PACKAGE JUST NEEDS THE SVN NUMBER FOR FOLDER NAME
IF /I [%TARGET%]==[package] ( GOTO PKG_FINISH )
ECHO   Copying build files to final location
IF EXIST %BASED%\%APP_NAME%\%APP_NAME%-r%VER% ( 
rm -r %BASED%\%APP_NAME%\%APP_NAME%-r%VER% )
ECHO.
XCOPY %INSTALLDIR% %BASED%\%APP_NAME%\%APP_NAME%-r%VER% /I /E /Y /q
ECHO.
ECHO -----------------------------------------------------------------
ECHO   BUILD FOLDER LOCATION^(s^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO   Source .......: %INSTALLDIR%
ECHO   Destination ..: %BASED%\%APP_NAME%\%APP_NAME%-r%VER%
ECHO.
IF ERRORLEVEL 0 ( GOTO MAKEBAT ) ELSE ( GOTO COPY_ERROR )


:: GENERATE RUNTIME BATCH FILE
:MAKEBAT
SET FILENAME=%APP_NAME%.bat
ECHO.
ECHO GENERATING: ^( %APP_NAME%.bat ^)
ECHO.
CD /D %BASED%\%APP_NAME%\%APP_NAME%-r%VER%

IF EXIST %APP_NAME%.bat (DEL /Q %APP_NAME%.bat)
>%APP_NAME%.bat (
ECHO @ECHO OFF
ECHO REM -- WSJT-WSPR batch File
ECHO REM -- Part of the JTSDK Project
ECHO COLOR 0A
ECHO bin\%APP_NAME%.exe
ECHO EXIT /B 0
)
GOTO ASKRUN


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
ECHO       Are the Only Python Builds
ECHO.
ECHO        Please Check Your Entry
ECHO.
PAUSE
GOTO EOF


:: ASK USER IF THEY WANT TO RUN THE APP
:ASKRUN
ECHO Would You Like To Run %APP_NAME% Now? ^( y/n ^)
ECHO.
SET ANSWER=
SET /P ANSWER=Type Response: %=%
ECHO.
If /I "%ANSWER%"=="Y" GOTO RUN_APP
If /I "%ANSWER%"=="N" (
GOTO FINISHED
) ELSE (
ECHO.
ECHO Please Answer With: ^( y or n ^) & ECHO. & GOTO ASKRUN
)
GOTO EOF


:: RUN THE APP IFF USER ANSWERED YES ABOVE
:RUN_APP
ECHO.
ECHO Starting: ^( %APP_NAME% ^)
CD %BASED%\%APP_NAME%\%APP_NAME%-r%VER%
START %APP_NAME%.bat & GOTO FINISHED


:: SINGLE TARGET BUILD MESSAGE
:SINGLE_FINISHED
ECHO.
ECHO .. Finished building ^( %APP_NAME% %TARGET% ^)
ECHO.
GOTO EOF


:: FINISHED INSTALL OR PACKAGE TARGET BUILD
:PKG_FINISH
ECHO .. Copying build files to final location
IF EXIST %BASED%\%APP_NAME%\%APP_NAME%-r%VER% ( 
rm -r %BASED%\%APP_NAME%\%APP_NAME%-r%VER% )
ECHO.
XCOPY %INSTALLDIR% %BASED%\%APP_NAME%\%APP_NAME%-r%VER% /I /E /Y /q
XCOPY %PACKAGEDIR% %BASED%\%APP_NAME%\%APP_NAME%-r%VER% /I /E /Y /q
ECHO.
IF ERRORLEVEL 1 ( GOTO BUILD_ERROR )
ECHO .. InnoSetup Exit Status: ^( %ERRORLEVEL% ^) is OK
ECHO .. Performing Dist-Clean After Build
ECHO.
mingw32-make -f Makefile.jtsdk distclean
ECHO.
GOTO FINISHED


:: FINISHED INSTALL OR PACKAGE TARGET BUILDS
:FINISHED
ECHO.
ECHO -----------------------------------------------------------------
ECHO   APP_NAME%-r%VER% Build Complete
ECHO -----------------------------------------------------------------
ECHO.
ECHO Source Dir ... %APP_SRC%
ECHO Package Dir .. %BASED%\%APP_NAME%\%APP_NAME%-r%VER%
CD /D %BASED%
ECHO.
GOTO EOF


:: HELP MENU FOR BUILD OPTIONS
:BUILD_HELP
CLS
ECHO.                               
ECHO -----------------------------------------------------------------
ECHO   BUILD TARGET HELP: ^( WSJT and WSPR ^)
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


:: USER REQUESTED UNSUPPORTED APPLICATION
:UNSUPPORTED_APP
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO   ^( %1 ^) Is An Unsupported Application Name
ECHO -----------------------------------------------------------------
GOTO UMSG


:: USER INPUT INCORRECT BUILD TARGET
:UNSUPPORTED_TARGET
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO   ^( %2 ^) IS AN INVALID TARGET FOR ^( %1% ^)
ECHO -----------------------------------------------------------------
GOTO UMSG


:: DISPLAY UNSUPPORTED TARGET MESSAGE 
:UMSG
ECHO. 
ECHO  After the pause, the build help menu
ECHO  will be displayed. Please use the syntax
ECHO  as outlined on on help and choose the correct
ECHO  application to build.
ECHO.
PAUSE
GOTO BUILD_HELP


:: DISPLAY DOUBLE CLICK WARNING MESSAGE
:DCLICK
@ECHO OFF
CLS
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


:: DISPLAY SRC DIRECTORY WAS NOT FOUND, e.g. NO CHECKOUT FOUND
:COMSG
CLS
ECHO ----------------------------------------
ECHO  %APP_SRC% Was Not Found
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


:: DISPLAY COMPILER BUILD WARNING MESSAGE
:BUILD_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO   Compiler Build Warning
ECHO -----------------------------------------------------------------
ECHO. 
ECHO  mingw32-make exited with a non-(0) build status. Check and or 
ECHO  correct the error, perform a clean, then re-make the target.
ECHO.
ECHO  Possible Solution:
ECHO  cd %APP_SRC%
ECHO  make -f Makefile.jtsdk distclean
ECHO.
ECHO  Then rebuild your target.
ECHO.
EXIT /B %ERRORLEVEL%


:: FINAL FOLDER CREATION ERROR MESSAGE
:COPY_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO   Error Creating ^( %APP_NAME%-r%VER% ^)
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


:: END OF PYENV-BUILD.BAT
:EOF
CD /D %BASED%
ENDLOCAL

EXIT /B 0

