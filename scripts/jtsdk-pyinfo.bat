@ECHO OFF
SETLOCAL
REM -- JTSDK-PY ENV Info
REM -- Part of the JTSDK Project
SET LANG=en_US
SET MINGW=%BASED%\mingw32\bin\
SET PY=%BASED%\python33\
CLS
ECHO      _ _____ ____  ____  _  __     ______   __
ECHO     ^| ^|_   _/ ___^|^|  _ \^| ^|/ /    ^|  _ \ \ / /
ECHO  _  ^| ^| ^| ^| \___ \^| ^| ^| ^| ' /_____^| ^|_) \ V / 
ECHO ^| ^|_^| ^| ^| ^|  ___) ^| ^|_^| ^| . \_____^|  __/ ^| ^|  
ECHO  \___/  ^|_^| ^|____/^|____/^|_^|\_\    ^|_^|    ^|_^| v1.0                                        
ECHO.                               
ECHO.
ECHO BUILD APPLICATIONS: ^( WSJT WSPR ^)
ECHO ---------------------------------------------------------
ECHO  Build Install .. Type: build wsjt or build wspr
ECHO  Build Help ..... Type: build help
ECHO.
ECHO COMPILER ENV (mingw32)
ECHO ---------------------------------------------------------

gcc.exe --version |grep GCC |awk "{print $3}" >g.v & set /p CVER=<g.v & rm g.v
gfortran.exe --version |grep Fortran |awk "{print $4}" >g.v & set /p GFOR=<g.v & rm g.v
mingw32-make --version |grep Make |awk "{print $3}" >g.v & set /p GNMK=<g.v & rm g.v
ECHO  GCC ........ %CVER%
ECHO  GFortran ... %GFOR%
ECHO  GNU Make ... %GNMK%
ECHO.
ECHO InnopSetp Information
ECHO ---------------------------------------------------------
ECHO  Inno ....... 5.5.4a
ECHO  GUI ........ compil32.exe
ECHO  CLI ........ issc.exe
ECHO.
ECHO PYTHON BASE ENV
ECHO ---------------------------------------------------------
%PY%python.exe -V
pip list > pkg.tmp
grep "^cx-" pkg.tmp |awk "{print $2}" > ver.v & set /p CXV=<ver.v & rm ver.v
grep "^numpy" pkg.tmp |awk "{print $2}" > ver.v & set /p NMY=<ver.v & rm ver.v
grep "^Pill" pkg.tmp |awk "{print $2}" > ver.v & set /p PIL=<ver.v & rm ver.v
grep "^pywin" pkg.tmp |awk "{print $2}" > ver.v & set /p PYW=<ver.v & rm ver.v
grep "^Pmw" pkg.tmp |awk "{print $2}" > ver.v & set /p PMW=<ver.v & rm ver.v
ECHO  cxfreeze ... %CXV:~1,-1%
ECHO  numpy ...... %NMY:~1,-1%
ECHO  pillow ..... %PIL:~1,-1%
ECHO  pywin32 .... %PYW:~1,-1%
ECHO  pmw ........ %PMW:~1,-1%
rm pkg.tmp
ECHO.

ENDLOCAL
EXIT /B 0