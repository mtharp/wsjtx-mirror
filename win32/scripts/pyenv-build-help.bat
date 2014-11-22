::-----------------------------------------------------------------------------::
:: Name .........: pyenv-build-help.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Help file for pyenv-build.bat
:: Project URL ..: http://sourceforge.net/projects/jtsdk 
:: Usage ........: This file is run from within pyenv.bat
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: pyenv-build-help.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: pyenv-build-help.bat is distributed in the hope that it will be useful, but WITHOUT
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
COLOR 0A


:: DISPLAY HELP MESSAGE
CLS
ECHO.                               
ECHO -----------------------------------------------------------------
ECHO CONFIGURE ^& BUILD APPS: ^( WSJTX WSPRX MAP65 ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO USAGE:  build ^(app_name^) ^(type^)
ECHO.
ECHO  App Names ...... wsjtx wsprx map65
ECHO  Release Types .. rconfig rinstall package
ECHO  Debug Types .... dconfig dinstall
ECHO.
ECHO DEFINITIONS:
ECHO -----------------------------------------------------------------
ECHO  rconfig ........ Configure Release Build Tree
ECHO  rinstall ....... Build Release Install Target
ECHO  dconfig ........ Configure Debug Build Tree
ECHO  dinstall ....... Build Debug Install Target
ECHO  package ........ Build Win32 Installer
ECHO.
ECHO NOTE: MAP65 ^& WSPR-X Package Builds are ^( Experimental ^)
ECHO.
ECHO EXAMPLE ^( WSJT-X Release ^):
ECHO -----------------------------------------------------------------
ECHO Configure Build Tree:
ECHO  Type:  build wsjtx rconfig
ECHO.
ECHO Build Install Target:
ECHO  Type:  build wsjtx rinstall
ECHO.
ECHO Build Win32 Installer
ECHO  Type:  build wsjtx package
ECHO.
ECHO NOTE: Building the ^( package ^) target will automatically
ECHO       build everthing needed to produce the Win32 Installer.
ECHO       Likewise, building ^( rinstall or dinstall ^) will build
ECHO       everything needed to produce a fully functional app to
ECHO       run from a local directory.
ECHO.
GOTO EOF


:: END OF PYENV-BUILD-HELP.BAT
:EOF
EXIT /B 0
