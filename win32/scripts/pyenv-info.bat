::-----------------------------------------------------------------------------::
:: Name .........: pyenv-info.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Batch file to check version informaiton
:: Project URL ..: http://sourceforge.net/projects/wsjt/
:: Usage ........: This file is run from within pyenv.bat
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: pyenv-info.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: pyenv-info.bat is distributed in the hope that it will be useful, but WITHOUT
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

:: SET PATH TO F2PY
SET F2PY=C:\JTSDK\Python33\Scripts\f2py.py

:: START GATHERING VERSION INFO
CLS
ECHO      _ _____ ____  ____  _  __     ______   __
ECHO     ^| ^|_   _/ ___^|^|  _ \^| ^|/ /    ^|  _ \ \ / /
ECHO  _  ^| ^| ^| ^| \___ \^| ^| ^| ^| ' /_____^| ^|_) \ V / 
ECHO ^| ^|_^| ^| ^| ^|  ___) ^| ^|_^| ^| . \_____^|  __/ ^| ^|  
ECHO  \___/  ^|_^| ^|____/^|____/^|_^|\_\    ^|_^|    ^|_^| v2.0.0                                     
ECHO.                               
ECHO.
ECHO BUILD APPLICATIONS: ^( WSJT WSPR ^)
ECHO ---------------------------------------------------------
ECHO  Build Install .. Type: build wsjt or build wspr
ECHO  Build Help ..... Type: build help
ECHO.
ECHO COMPILER ENV (mingw32)
ECHO ---------------------------------------------------------

:: GET and DISPLAY CRITICAL TOOL INFORMATION
:: IF ANY OF THESE FAIL, THERE ARE PATH ISSUES THAT MUST BE CORRECTED.
gcc --version |grep GCC |gawk "{print $3}" >g.v & set /p CVER=<g.v & rm g.v
gfortran --version |grep Fortran |gawk "{print $4}" >g.v & set /p GFOR=<g.v & rm g.v
mingw32-make --version |grep Make |gawk "{print $3}" >g.v & set /p GNMK=<g.v & rm g.v
cat "%INNO%\version.txt" |gawk "{print $0}" >i.v & set /p INNOV=<i.v & rm i.v

ECHO  GCC ........ %CVER%
ECHO  GFortran ... %GFOR%
ECHO  GNU Make ... %GNMK%
ECHO.
ECHO InnopSetp Information
ECHO ---------------------------------------------------------
ECHO  Inno ....... %INNOV%
ECHO  GUI ........ compil32.exe
ECHO  CLI ........ ISSC.exe
ECHO.
ECHO PYTHON BASE ENV
ECHO ---------------------------------------------------------

python --version >> py.ver 2>&1 
grep "^Python" py.ver |gawk "{print $2}" > py.v & set /p PYV=<py.v & rm py.ver & rm py.v
pip list > pkg.tmp
grep "^cx-" pkg.tmp |gawk "{print $2}" > ver.v & set /p CXV=<ver.v & rm ver.v
grep "^numpy" pkg.tmp |gawk "{print $2}" > ver.v & set /p NMY=<ver.v & rm ver.v
grep "^Pill" pkg.tmp |gawk "{print $2}" > ver.v & set /p PIL=<ver.v & rm ver.v
grep "^pywin" pkg.tmp |gawk "{print $2}" > ver.v & set /p PYW=<ver.v & rm ver.v
python %F2PY% -v |gawk "{print $0}" >f2.v & set /p F2PYV=<f2.v & rm f2.v

ECHO Python ...... %PYV%
ECHO  cxfreeze ... %CXV:~1,-1%
ECHO  numpy ...... %NMY:~1,-1%
ECHO  f2py ....... %F2PYV%.0.0
ECHO  pillow ..... %PIL:~1,-1%
ECHO  pywin32 .... %PYW:~1,-1%
rm pkg.tmp
ECHO.
GOTO EOF

:: END PYENV-INFO.BAT
:EOF
EXIT /B 0

