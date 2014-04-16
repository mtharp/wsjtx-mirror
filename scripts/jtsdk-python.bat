@ECHO OFF
REM -- JTSDK Windows WSJT Build Script
REM -- Part of the JTSDK Project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 0A
REM -- TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DCLICK

REM -- PATH VARS
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET SRCD=%BASED%\src
SET TOOLS=%BASED%\tools
SET MINGW=%BASED%\mingw32\bin
SET SVND=%BASED%\subversion\bin
SET SCRIPTS=%BASED%\tools\scripts
SET PYTHONPATH=%BASED%\Python33;%BASED%\Python33\Scripts;%BASED%\Python33\DLLs;%BASED%\Python33\Tools\Scripts
SET PATH=%BASED%;%MINGW%;%PYTHONPATH%;%SRCD%;%SVND%;%TOOLS%;%SCRIPTS%;%WINDIR%;%WINDIR%\System32

REM -- VARS USED IN PROCESS
SET JJ=%NUMBER_OF_PROCESSORS%
SET python=%BASED%\Python33\python.exe
IF NOT EXIST %BASED%\src\NUL mkdir %BASED%\src
GOTO SELECT

REM -- FROM jtsdk-pyenv.bat FIELD $1 = %1
:SELECT
IF /I [%1]==[wsjt] (
SET APP_NAME=wsjt
SET APP_SRC=%SRCD%\trunk
GOTO START
) ELSE IF /I [%1]==[wspr] (
SET APP_NAME=wspr
SET APP_SRC=%SRCD%\wspr
GOTO START
) ELSE (GOTO UNSUPPORTED)
GOTO START

:START
REM -- START MAIN BUILD
CD %BASED%
ECHO -------------------------------
ECHO ^( %APP_NAME% ^) Build Script
ECHO -------------------------------
ECHO.

REM -- IF SRCD EXISTS, CHECK FOR PREVIOUS CO
IF NOT EXIST %APP_SRC%\.svn\NUL (
mkdir %BASED%\src
GOTO COMSG
) ELSE (GOTO ASKSVN)

REM -- START WSPR BUILD
:ASKSVN
ECHO.
ECHO Update from SVN Before Building? ^( y/n ^)
SET ANSWER=
ECHO.
SET /P ANSWER=Type Response: %=%
If /I "%ANSWER%"=="N" GOTO STARTBUILD
If /I "%ANSWER%"=="Y" (
GOTO SVNUPDATE
) ELSE (
ECHO.
ECHO Please Answer With: ^( Y or N ^)
ECHO.
GOTO ASKSVN
)

REM -- UPDATE WSJT FROM SVN
:SVNUPDATE
ECHO.
ECHO UPDATING ^( %APP_SRC% ^ )
ECHO.
cd %APP_SRC%
ECHO.
start /wait svn cleanup
start /wait svn update
ECHO.
GOTO STARTBUILD

REM -- START WSJT MAIN BUILD
:STARTBUILD
ECHO.
ECHO STARTING BUILD FOR: ^( %APP_NAME% ^)
ECHO.
IF NOT EXIST %BASED%\%APP_NAME% mkdir %BASED%\%APP_NAME%
IF /I [%APP_NAME%]==[wsjt] (GOTO MAKEWSJT)
IF /I [%APP_NAME%]==[wspr] (GOTO MAKEWSPR)

REM -- BEGIN WSJT MAIN BUILD
:MAKEWSJT
REM -- g1.bat
REM -- CD into %APP_SRC% then start build
:JTG1
CD /D %APP_SRC%
ECHO.
ECHO BUILDING: ^( libjt.a, jt65code.exe, jt4code.exe ^)
ECHO.
mingw32-make -f Makefile.jtsdk
ECHO.
GOTO JTG2

REM - g2.bat
REM -- STILL in %APP_SRC%
:JTG2
ECHO.
ECHO RUNNING: ^( F2PY ^)
ECHO.
python %BASED%\Python33\Scripts\f2py.py -c -I. --fcompiler=gnu95 --compiler=mingw32 --f77exec=gfortran --f90exec=gfortran --opt="-cpp -fbounds-check -O2" libjt.a libportaudio.a libfftw3f_win.a libsamplerate.a libpthreadGC2.a -lwinmm -m Audio ftn_init.f90 ftn_quit.f90 audio_init.f90 spec.f90  getfile.f90 azdist0.f90 astro0.f90 chkt0.f90
mv Audio.pyd WsjtMod/Audio.pyd
ECHO.
GOTO JTG3

REM -- g3.bat
REM -- STILL in %APP_SRC%
:JTG3
ECHO.
ECHO RUNNING: ^( CX_FREEZE ^)
SET INSTALLDIR=install
rm -rf %INSTALLDIR%
mkdir %INSTALLDIR%
mkdir %INSTALLDIR%\bin
python %BASED%\Python33\Scripts\cxfreeze --silent --icon=wsjt.ico --include-path=. --include-modules=Pmw wsjt.py --target-dir=%INSTALLDIR%\bin
ECHO.
GOTO JTG4

REM - g4.bat
REM -- STILL in %APP_SRC%
:JTG4
ECHO.
ECHO COPYIING ^( %APP_NAME% ^) FILES
ECHO.
REM -- CLEAN TZ & DEMO FILES, COPY REMAINING FILES
set INSTALLDIR=install
rm -rf %INSTALLDIR%/bin/tcl/tzdata
rm -rf %INSTALLDIR%/bin/tk/demos
cp -r RxWav %INSTALLDIR%
cp CALL3.TXT kvasd.dat kvasd.exe wsjt.ico wsjt.bat %INSTALLDIR% 
GOTO REV_NUM
REM -- FINISHED WSJT BUILD ---------------------------------

REM -- START WSPR BUILD ------------------------------------
:MAKEWSPR
REM -- g1.bat
REM -- CD into %APP_SRC% then start build
:PRG1
cd %APP_SRC%
ECHO.
ECHO BUILDING: ^( libwsper.a ^)
ECHO.
mingw32-make -f Makefile.jtsdk libwspr.a
GOTO PRG2

REM -- g2.bat
REM -- STILL in %APP_SRC%
:PRG2
ECHO.
 ECHO RUNNING: ^( F2PY ^)
ECHO.
python %BASED%\Python33\Scripts\f2py.py -c -I. --fcompiler=gnu95 --compiler=mingw32 --f77exec=gfortran --f90exec=gfortran --opt="-cpp -fbounds-check -O2" libwspr.a libportaudio.a libfftw3f_win.a libsamplerate.a libpthreadGC2.a -lwinmm -m w wspr1.f90 getfile.f90 paterminate.f90 ftn_quit.f90 audiodev.f90
mv w.pyd WsprMod/w.pyd
ECHO.
GOTO PRG3

REM -- g3.bat
REM -- STILL in %APP_SRC%
:PRG3
ECHO.
ECHO BUILDING: ^( fmt.exe fmtave.exe fcal.exe fmeasure.exe wspr0.exe  ^)
ECHO.
mingw32-make -f Makefile.jtsdk fmt.exe
mingw32-make -f Makefile.jtsdk fmtave.exe
mingw32-make -f Makefile.jtsdk fcal.exe
mingw32-make -f Makefile.jtsdk fmeasure.exe
mingw32-make -f Makefile.jtsdk wspr0.exe
GOTO PRG4

REM -- g4.bat
REM -- STILL in %APP_SRC%
:PRG4
ECHO.
ECHO RUNNING: ^( CX_FREEZE ^)
SET INSTALLDIR=install
rm -rf %INSTALLDIR%
mkdir %INSTALLDIR%
mkdir %INSTALLDIR%\bin
python %BASED%\Python33\Scripts\cxfreeze --silent --icon=wsjt.ico --include-path=. --include-modules=Pmw wspr.py --target-dir=%INSTALLDIR%\bin
ECHO.
GOTO PRG5

REM -- g5.bat
REM -- STILL in %APP_SRC%
:PRG5
ECHO COPYING ^( %APP_NAME% ^) FILES
ECHO.
set INSTALLDIR=install
rm -r %INSTALLDIR%/bin/tcl/tzdata
rm -r %INSTALLDIR%/bin/tk/demos
cp -r save %INSTALLDIR%
cp wsjt.ico wsprrc.win hamlib_rig_numbers rigctl.exe wspr.bat %INSTALLDIR% 
cp fcal.exe fmeasure.exe fmt.exe fmtave.exe wspr0.exe %INSTALLDIR%
cp libhamlib-2.dll hamlib*.dll libusb0.dll %INSTALLDIR% 
cp wsjt.ico wspr.bat %INSTALLDIR%
GOTO REV_NUM
REM -- FINISHED WSPR BUILD ---------------------------------

REM -- GET SVN r NUMBER && COPY PKG TO %APP_NAME%
REM -- STILL in %APP_SRC%
:REV_NUM
grep "$Revision:" %APP_NAME%.py |awk "{print $12}" > r.txt
SET /P VER=<r.txt & rm r.txt
IF EXIST %BASED%\%APP_NAME%\%APP_NAME%-r%VER% rm -r %BASED%\%APP_NAME%\%APP_NAME%-r%VER%
cp -r %INSTALLDIR% %BASED%\%APP_NAME%\%APP_NAME%-r%VER%
GOTO MAKEBAT

REM -- GENERATE RUNTIME BATCH FILE
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

REM - TOOL CHAIN ERROR MESSAGE
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

:ASKRUN
ECHO Would You Like To Run %APP_NAME% Now? ^( y/n ^)
ECHO.
SET ANSWER=
SET /P ANSWER=Type Response: %=%
ECHO.
If /I "%ANSWER%"=="Y" GOTO RUNAPP
If /I "%ANSWER%"=="N" (
GOTO FINISHED
) ELSE (
ECHO.
ECHO Please Answer With: ^( y or n ^) & ECHO. & GOTO ASKRUN
)
GOTO EOF

:RUNAPP
ECHO.
ECHO Starting: ^( %APP_NAME% ^)
CD %BASED%\%APP_NAME%\%APP_NAME%-r%VER%
START %APP_NAME%.bat & GOTO FINISHED

:FINISHED
REM -- STILL in %APP_SRC%
ECHO.
ECHO -----------------------------------
ECHO  %APP_NAME%-r%VER% Build Complete
ECHO -----------------------------------
ECHO.
ECHO COPIED ... %APP_NAME%-r%VER%
ECHO FROM ..... %APP_SRC%\%INSTALLDIR%
ECHO TO ....... %BASED%\%APP_NAME%\%APP_NAME%-r%VER%
REM -- GO BACK TO \JTSDK\
CD /D %BASED%
ECHO.
GOTO EOF

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

:EOF
COLOR 0A
ENDLOCAL
EXIT /B 0