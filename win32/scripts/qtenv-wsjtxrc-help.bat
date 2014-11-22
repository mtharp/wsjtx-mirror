::-----------------------------------------------------------------------------::
:: Name .........: qtenv-wsjtxrc-help.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Help file for qtenv-wsjtxrc.bat
:: Project URL ..: http://sourceforge.net/projects/jtsdk 
:: Usage ........: This file is run from within qtenv.bat
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: qtenv-wsjtxrc-help.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: qtenv-wsjtxrc-help.bat is distributed in the hope that it will be useful, but WITHOUT
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


:: DISPLAY HELP MESSAGE
CLS
ECHO.                               
ECHO -----------------------------------------------------------------
ECHO CONFIGURE ^& BUILD WSJT-X Release Candidate
ECHO -----------------------------------------------------------------
ECHO.
ECHO USAGE:  wsjtxrc ^(type^)
ECHO.
ECHO  Release Types .. rconfig rinstall package
ECHO    rconfig ...... Configure Release Build Tree
ECHO    rinstall ..... Build Release Install Target
ECHO    package ...... Build Win32 Installer
ECHO.
ECHO EXAMPLES
ECHO ----------------------------------------------------------
ECHO Configure Build Tree:
ECHO   Type: wsjtxrc rconfig
ECHO.
ECHO Build Install Target:
ECHO   Type:  wsjtxrc rinstall
ECHO.
ECHO Build NSIS Installer
ECHO   Type:  wsjtxrc package
ECHO.
GOTO EOF


:: END OF QTENV-WSJTXRC-HELP.BAT
:EOF
EXIT /B 0
