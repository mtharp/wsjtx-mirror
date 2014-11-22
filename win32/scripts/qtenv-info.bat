::-----------------------------------------------------------------------------::
:: Name .........: qtenv-info.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Batch file to check version informaiton
:: Project URL ..: http://sourceforge.net/projects/wsjt/ 
:: Usage ........: This file is run from within qtenv.bat
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: qtenv-info.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: qtenv-info.bat is distributed in the hope that it will be useful, but WITHOUT
:: ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
:: FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
:: details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

:: ENVIRONMENT
@ECHO OFF
SET LANG=en_US


:: START GATHERING VERSION INFO
CLS
ECHO      _ _____ ____  ____  _  __      ___ _____ 
ECHO     ^| ^|_   _/ ___^|^|  _ \^| ^|/ /     / _ \_   _^|
ECHO  _  ^| ^| ^| ^| \___ \^| ^| ^| ^| ' /_____^| ^| ^| ^|^| ^|  
ECHO ^| ^|_^| ^| ^| ^|  ___) ^| ^|_^| ^| . \_____^| ^|_^| ^|^| ^|  
ECHO  \___/  ^|_^| ^|____/^|____/^|_^|\_\     \__\_\^|_^| v2.0.0
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
g++.exe --version |grep Built |gawk "{print $7}" >g.v & set /p CVER=<g.v & rm g.v
gfortran.exe --version |grep Fortran |gawk "{print $8}" >g.v & set /p GFOR=<g.v & rm g.v
mingw32-make --version |grep Make |gawk "{print $3}" >g.v & set /p GNMK=<g.v & rm g.v
ECHO  C^+^+ ....... %CVER%
ECHO  GFortran .. %GFOR%
ECHO  GNU Make .. %GNMK%
ECHO.
ECHO CRITICAL APP INFO
ECHO ---------------------------------------------------------
cmake --version |gawk "{print $3}" >c.m & set /p CMV=<c.m & rm c.m
cpack --version |gawk "{print $3}" >c.p & set /p CPV=<c.p & rm c.p
qmake --version |gawk "FNR==2 {print $4}" >q.m & set /p QTV=<q.m & rm q.m
qmake --version |gawk "FNR==1 {print $3}" >q.m & set /p QMV=<q.m & rm q.m
makensis.exe /VERSION  >n.m & set /p NSM=<n.m & rm n.m
pkg-config --version >p.c & set /p PKG=<p.c & rm p.c
ECHO  Cmake ...... %CMV%
ECHO  Cpack ...... %CPV%
ECHO  QT5 ........ %QTV%
ECHO  QMake ...... %QMV%
ECHO  NSIS ....... %NSM%
ECHO  InnoSetup .. 5.5.5a
ECHO  Pkg-Cfg .... %PKG%
ECHO.
GOTO EOF


:: END QTENV-INFO.BAT
:EOF
EXIT /B 0
