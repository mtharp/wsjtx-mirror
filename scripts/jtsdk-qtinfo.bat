@ECHO OFF
SETLOCAL
REM -- JTSDK-QT ENV Info
REM -- Part of the JTSDK Project
SET LANG=en_US
SET MINGW=%BASED%\qt5\Tools\mingw32\bin\
CLS
ECHO      _ _____ ____  ____  _  __      ___ _____ 
ECHO     ^| ^|_   _/ ___^|^|  _ \^| ^|/ /     / _ \_   _^|
ECHO  _  ^| ^| ^| ^| \___ \^| ^| ^| ^| ' /_____^| ^| ^| ^|^| ^|  
ECHO ^| ^|_^| ^| ^| ^|  ___) ^| ^|_^| ^| . \_____^| ^|_^| ^|^| ^|  
ECHO  \___/  ^|_^| ^|____/^|____/^|_^|\_\     \__\_\^|_^| v1.0
ECHO.
ECHO.
ECHO BUILD APPLICATIONS: ^( WSJT-X WSPR-X MAP65 ^)
ECHO ---------------------------------------------------------
ECHO.
ECHO USAGE:  build ^(app_name^) ^(type^)
ECHO.
ECHO  App Names ...... wsjtx wsprx map65
ECHO  Release Types .. rconfig rinstall package
ECHO  Debug Types .... dconfig dinstall
ECHO  Build Help ..... build-help
ECHO.
ECHO COMPILER INFO (mingw48_32)
ECHO ---------------------------------------------------------
g++.exe --version |grep Built |awk "{print $7}" >g.v & set /p CVER=<g.v & rm g.v
gfortran.exe --version |grep MinGW |awk "{print $8}" >g.v & set /p GFOR=<g.v & rm g.v
mingw32-make --version |grep Make |awk "{print $3}" >g.v & set /p GNMK=<g.v & rm g.v
ECHO  C^+^+ ....... %CVER%
ECHO  GFortran .. %GFOR%
ECHO  GNU Make .. %GNMK%
ECHO.
ECHO CRITICAL APP INFO
ECHO ---------------------------------------------------------
cmake --version |awk "{print $3}" >c.m & set /p CMV=<c.m & rm c.m
cpack --version |awk "{print $3}" >c.p & set /p CPV=<c.p & rm c.p
qmake --version |awk "FNR==2 {print $4}" >q.m & set /p QTV=<q.m & rm q.m
qmake --version |awk "FNR==1 {print $3}" >q.m & set /p QMV=<q.m & rm q.m
makensis.exe /VERSION  >n.m & set /p NSM=<n.m & rm n.m
pkg-config --version >p.c & set /p PKG=<p.c & rm p.c
ECHO  Cmake ...... %CMV%
ECHO  Cpack ...... %CPV%
ECHO  QT5 ........ %QTV%
ECHO  QMake ...... %QMV%
ECHO  NSIS ....... %NSM%
ECHO  InnoSetup .. 5.5.4a
ECHO  Pkg-Cfg .... %PKG%
ECHO.

ENDLOCAL
EXIT /B 0