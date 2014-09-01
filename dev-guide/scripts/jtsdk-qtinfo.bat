@ECHO OFF
SETLOCAL
REM -- JTSDK-QT ENV Info
REM -- Part of the JTSDK Project
SET MINGW=%BASED%\qt5\Tools\mingw32\bin\
CLS
ECHO      _ _____ ____  ____  _  __      ___ _____ 
ECHO     ^| ^|_   _/ ___^|^|  _ \^| ^|/ /     / _ \_   _^|
ECHO  _  ^| ^| ^| ^| \___ \^| ^| ^| ^| ' /_____^| ^| ^| ^|^| ^|  
ECHO ^| ^|_^| ^| ^| ^|  ___) ^| ^|_^| ^| . \_____^| ^|_^| ^|^| ^|  
ECHO  \___/  ^|_^| ^|____/^|____/^|_^|\_\     \__\_\^|_^|  
ECHO.
ECHO.                               
ECHO BUILD APPLICATIONS: ^( WSJTX WSPRX MAP65 ^)
ECHO ---------------------------------------------------------
ECHO  Build Release .... Type: build wsjtx -r
ECHO  Build Debug ...... Type: build wsjtx
ECHO  ENV Info ......... Tupe: env-info
ECHO.
ECHO COMPILER ENV (mingw32)
ECHO ---------------------------------------------------------
g++.exe --version |grep Built |awk "{print $7}" >g.v & set /p CVER=<g.v & rm g.v
ECHO  C^+^+ ....... %CVER%
gfortran.exe --version |grep MinGW |awk "{print $8}" >g.v & set /p GFOR=<g.v & rm g.v
ECHO  GFortran .. %GFOR%
mingw32-make --version |grep Make |awk "{print $3}" >g.v & set /p GNMK=<g.v & rm g.v
ECHO  GNU Make .. %GNMK%
ECHO.
ECHO QT5 BASE ENV
ECHO ---------------------------------------------------------
qmake --version |awk "FNR==1 {print $3}" >q.m & set /p QMV=<q.m & rm q.m
ECHO  QMake ..... %QMV%
qmake --version |awk "FNR==2 {print $4}" >q.m & set /p QTV=<q.m & rm q.m
ECHO  QT5 ....... %QTV%
cmake --version |awk "{print $3}" >c.m & set /p CMV=<c.m & rm c.m
ECHO  Cmake...... %CMV%
ECHO.
ENDLOCAL
EXIT /B 0