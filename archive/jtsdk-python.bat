@ECHO OFF
REM -- JTSDK Windows WSJT Build Script
REM -- Part of the JTSDK Project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 1B
REM -- TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DCLICK

REM -- PATH VARS
SET BASED=%~dp0
SET SRCD=%BASED%\src
SET TOOLS=%BASED%\tools
SET MINGW=%BASED%\mingw32\bin
SET SVND=%BASED%\subversion\bin
SET SCRIPTS=%BASED%\tools\scripts
SET PYTHONPATH=%BASED%\Python33;%BASED%\Python33\Scripts;%BASED%\Python33\Tools\Scripts
SET PATH=%BASED%;%MINGW%;%PYTHONPATH%;%SRCD%;%SVND%;%TOOLS%;%SCRIPTS%;%INSTALLDIR%;%WINDIR%;%WINDIR%\System32

REM -- VARS USED IN PROCESS
SET JJ=%NUMBER_OF_PROCESSORS%
SET WSJTURL=svn co svn://svn.code.sf.net/p/wsjt/wsjt/trunk
SET WSPRURL=svn co svn://svn.code.sf.net/p/wsjt/wsjt/branches/wspr
SET JJ=%NUMBER_OF_PROCESSORS%
GOTO MKSRCD

REM - ENSURE ALL DIRS ARE PRESENT
:MKSRCD
IF NOT EXIST %BASED%\src\NUL mkdir %BASED%\src

REM -- FROM jtsdk-py-env.bat FIELD $1 = %1
:SELECT
IF /I [%1]==[wsjt] (
SET APP_NAME=wsjt
SET APP_SRC=%SRCD%\trunk
SET CHECKOUT=%WSJTURL%
GOTO START
) ELSE IF /I [%1]==[wspr] (
SET APP_NAME=wspr
SET APP_SRC=%SRCD%\wspr
SET CHECKOUT=%WSPRURL%
GOTO START
) ELSE (GOTO UNSUPPORTED)
GOTO START

:START
REM -- START MAIN BUILD
CD %BASED%
REM jht CLS
ECHO -------------------------------
ECHO ^( %APP_NAME% ^) Build Script
ECHO -------------------------------
ECHO.
REM -- IF SRCD EXISTS, CHECK FOR PREVIOUS CO
IF NOT EXIST %APP_SRC%\NUL (
CD %SRCD%
ECHO CHECKING OUT: ^( %APP_NAME% ^)
ECHO.
%CHECKOUT%
ECHO.
GOTO STARTBUILD
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
REM jht CLS
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
svn up
ECHO.
GOTO STARTBUILD

REM -- START WSJT MAIN BUILD
:STARTBUILD
ECHO.
ECHO Starting Build For: ^( %APP_NAME% ^)
ECHO.
IF /I [%APP_NAME%]==[wsjt] (GOTO MAKEWSJT)
IF /I [%APP_NAME%]==[wspr] (GOTO MAKEWSPR)

REM -- BEGIN WSJT MAIN BUILD
:MAKEWSJT
REM -- g0.bat
IF NOT EXIST %BASED%\%APP_NAME%\NUL mkdir %BASED%\%APP_NAME%
CD /D %APP_SRC%
ECHO.
ECHO MAKE CLEAN
ECHO.
mingw32-make -j%JJ% -f Makefile.MinGW.jtsdk clean
GOTO G1

REM -- g1.bat
REM -- STILL in %APP_SRC%
:G1
ECHO.
ECHO BUILDING:: libjt.a, jt65code.exe, jt4code.exe
ECHO.
mingw32-make -j%JJ% -f Makefile.MinGW.jtsdk libjt.a
mingw32-make -j%JJ% -f Makefile.MinGW.jtsdk jt65code.exe
mingw32-make -j%JJ% -f Makefile.MinGW.jtsdk jt4code.exe
ECHO.
ECHO Finished Building libjt.a, jt65code.exe, jt4code.exe
ECHO.
GOTO G2

REM - g2.bat
REM -- STILL in %APP_SRC%
:G2
ECHO.
ECHO G2 RUNNING:: F2PY
ECHO.
python %BASED%\Python33\Scripts\f2py.py -c -I. --fcompiler=gnu95 --compiler=mingw32 --f77exec=gfortran --f90exec=gfortran --opt="-cpp -fbounds-check -O2" libjt.a libportaudio.a libfftw3f_win.a libsamplerate.a libpthreadGC2.a -lwinmm -m Audio ftn_init.f90 ftn_quit.f90 audio_init.f90 spec.f90  getfile.f90 azdist0.f90 astro0.f90 chkt0.f90
mv Audio.pyd WsjtMod/Audio.pyd
ECHO.
GOTO G3

REM -- g3.bat
REM -- STILL in %APP_SRC%
:G3
ECHO.
ECHO RUNNING:: CX_FREEZE
SET INSTALLDIR=install
rm -rf %INSTALLDIR%
mkdir %INSTALLDIR%
mkdir %INSTALLDIR%\bin
python %BASED%\Python33\Scripts\cxfreeze.py --silent --icon=wsjt.ico --include-path=. --include-modules=Pmw wsjt.py --target-dir=%INSTALLDIR%\bin
ECHO.
GOTO G4

REM - g4.bat
REM -- STILL in %APP_SRC%
:G4
ECHO.
ECHO Copying ^( %APP_NAME% ^) Files
ECHO.
REM -- CLEAN TZ & DEMO FILES, COPY REMAINING FILES
set INSTALLDIR=install
rm -rf %INSTALLDIR%/bin/tcl/tzdata
rm -rf %INSTALLDIR%/bin/tk/demos
cp -r RxWav %INSTALLDIR%
cp CALL3.TXT kvasd.dat kvasd.exe wsjt.ico wsjt.bat %INSTALLDIR% 
ECHO.
GOTO REV_NUM
REM -- FINISHED MAIN WSJT BUILD ---------------------------------

REM -- GET SVN r NUMBER && COPY PKG TO %APP_NAME%
:REV_NUM
grep "$Rev:" wsjt.py |head -n1 |awk "{print $5}" > rev_num.txt
SET /P VERN=<rev_num.txt
rm rev_num.txt
IF EXIST %BASED%\%APP_NAME%\WSJT-r%VERN% rm -r %BASED%\%APP_NAME%\WSJT-r%VERN%
cp -r %INSTALLDIR% %BASED%\%APP_NAME%\WSJT-r%VERN%
GOTO FINISHED

:FINISHED
REM -- STILL in %APP_SRC%
REM jht CLS
ECHO.
ECHO -----------------------------------
ECHO  %APP_NAME%-r%VERN% Build Complete
ECHO -----------------------------------
ECHO.
ECHO COPIED ... WSJT-r%VERN%
ECHO FROM ..... %APP_SRC%\%INSTALLDIR%
ECHO TO ....... %BASED%\%APP_NAME%\WSJT-r%VERN%
REM -- GO BACK TO \JTSDK\
CD /D %BASED%
ECHO.
GOTO EOF

REM -- BEGIN WSPR MAIN BUILD
:MAKEWSPR
REM -- g0.bat
IF NOT EXIST %BASED%\%APP_NAME%\NUL mkdir %BASED%\%APP_NAME%
CD /D %APP_SRC%
ECHO.
ECHO MAKE CLEAN
ECHO.
mingw32-make -j%JJ% -f Makefile.MinGW.gfortran clean
GOTO G1WSPR

REM -- g1.bat
REM -- STILL in %APP_SRC%
:G1WSPR
ECHO.
ECHO BUILDING:: libwspr.a
ECHO.
mingw32-make -j%JJ% -f Makefile.MinGW.gfortran libwspr.a
ECHO.
ECHO Finished Building libwspr.a
ECHO.
GOTO G2WSPR

REM - g2.bat
REM -- STILL in %APP_SRC%
:G2WSPR
ECHO.
ECHO G2 RUNNING:: F2PY
ECHO.
python %BASED%\Python33\Scripts\f2py.py -c -I. --fcompiler=gnu95 --compiler=mingw32 --f77exec=gfortran --f90exec=gfortran --opt="-cpp -fbounds-check -O2" libwspr.a libportaudio.a libfftw3f_win.a libsamplerate.a libpthreadGC2.a -lwinmm -m w wspr1.f90 getfile.f90 paterminate.f90 ftn_quit.f90 audiodev.f90
mv w.pyd WsprMod/w.pyd
ECHO.
GOTO G3WSPR

REM -- g3.bat
REM -- STILL in %APP_SRC%
:G3WSPR
ECHO.
ECHO RUNNING:: CX_FREEZE
SET INSTALLDIR=install
rm -rf %INSTALLDIR%
mkdir %INSTALLDIR%
mkdir %INSTALLDIR%\bin

python %BASED%\Python33\Scripts\cxfreeze.py --silent --icon=wsjt.ico --include-path=. --include-modules=Pmw wspr.py --target-dir=%INSTALLDIR%\bin

ECHO.
GOTO G4WSPR

REM - g4.bat
REM -- STILL in %APP_SRC%
:G4WSPR
ECHO.
ECHO Copying ^( %APP_NAME% ^) Files
ECHO.
REM -- CLEAN TZ & DEMO FILES, COPY REMAINING FILES
set INSTALLDIR=install
rm -rf %INSTALLDIR%/bin/tcl/tzdata
rm -rf %INSTALLDIR%/bin/tk/demos
cp -r save %INSTALLDIR%
cp wsjt.ico wsprrc.win hamlib_rig_numbers rigctl.exe wspr.bat %INSTALLDIR% 
cp libhamlib-2.dll hamlib*.dll libusb0.dll %INSTALLDIR% 
ECHO.
GOTO REV_NUM_WSPR
REM -- FINISHED MAIN WSPR BUILD ---------------------------------

REM -- GET SVN r NUMBER && COPY PKG TO %APP_NAME%
:REV_NUM_WSPR
grep "$Rev:" wspr.py |head -n1 |awk "{print $5}" > rev_num.txt
SET /P VERN=<rev_num.txt
rm rev_num.txt
IF EXIST %BASED%\%APP_NAME%\WSPR-r%VERN% rm -r %BASED%\%APP_NAME%\WSPR-r%VERN%
cp -r %INSTALLDIR% %BASED%\%APP_NAME%\WSPR-r%VERN%
GOTO FINISHED_WSPR

:FINISHED_WSPR
REM -- STILL in %APP_SRC%
REM jht CLS
ECHO.
ECHO -----------------------------------
ECHO  %APP_NAME%-r%VERN% Build Complete
ECHO -----------------------------------
ECHO.
ECHO COPIED ... WSPR-r%VERN%
ECHO FROM ..... %APP_SRC%\%INSTALLDIR%
ECHO TO ....... %BASED%\%APP_NAME%\WSPR-r%VERN%
REM -- GO BACK TO \JTSDK\
CD /D %BASED%
ECHO.
GOTO EOF

REM - TOOL CHAIN ERROR MESSAGE
:UNSUPPORTED
COLOR 1E
REM jht CLS
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

:SVNERROR1
REM jht CLS
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
IF /I [%APP_NAME%]==[wsjt] (
CD /D %SRCD%\trunk
svn cleanup
)
IF /I [%APP_NAME%]==[wspr] (
CD /D %SRCD%\wspr
svn cleanup
)
REM jht CLS
ECHO -------------------------------
ECHO       Cleanup Complete
ECHO -------------------------------
ECHO.
ECHO         Now exiting
sleep 2
GOTO EOF

REM -- WARN ON DOUBLE CLICK
:DCLICK
CALL %BASED%\tools\scripts\dclick-error.bat
GOTO EOF

:EOF
COLOR 1B
ENDLOCAL
EXIT /B 0