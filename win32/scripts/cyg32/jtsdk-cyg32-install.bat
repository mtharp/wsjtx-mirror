::-----------------------------------------------------------------------------::
:: Name .........: jtsdk-cyg32-install.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Unattended Installation ofC:\JTSDK\cyg32
:: Project URL ..: http://sourceforge.net/projects/wsjt/ 
:: Usage ........: This file is called from postinstall-update.bat
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: jtsdk-cyg32-install is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: jtsdk-cyg32-install is distributed in the hope that it will be useful, but
:: WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
:: or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
:: more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

@ECHO OFF
COLOR 0E
TITLE JTSDK-DOC Installation
SET LANG=en_US

:: SET VARIABLES
SET BASED=C:\JTSDK
SET CYINSTALLER=cyg32-setup-x86.exe
SET CYARCH=x86
SET CYINSTALLD=%BASED%\cyg32
SET CYPKGD=%BASED%\scripts\cyg32\downloads
SET CYSITE=http://cygwin.mirrors.pair.com/
SET CYOPT=-B -q -D -L -X -g -N -d -o
SET CYPKGS=mintty,python,subversion,ncurses,source-highlight,python-pygments,most
SET PATH=%BASED%;%WINDIR%\System32

:: START INSTALL
IF NOT EXIST %BASED%\scripts\cyg32\NUL (
SET ERRORLEVEL=Script Directory Not Found
ECHO   ..Could not find script directory.
ECHO   ..Cyg32 ^*WILL NOT^* be installed
GOTO ERROR1
)

CD /D %BASED%\scripts\cyg32
CLS
ECHO ------------------------------------------------------
ECHO  Building JTSDK-DOC ^( Cygwin x86 ^)
ECHO ------------------------------------------------------

:: INSTALL DIRECTORY CHECK
IF NOT EXIST %CYINSTALLD%\NUL (
ECHO   ..Added Directory: %CYINSTALLD% 
MKDIR %CYINSTALLD% 2> NUL
)

:: PACKAGE DIRECTORY CHECK
IF NOT EXIST %CYPKGD%\NUL (
ECHO   ..Added Directory: %CYPKGD% 
MKDIR %CYPKGD% 2> NUL
)

:: RUN THE CYGWIN INSTALLER
ECHO   ..Sending Preset Parameters to Installer
%CYINSTALLER% %CYOPT% -a %CYARCH% -s %CYSITE% -l "%CYPKGD%" -R "%CYINSTALLD%" -P %CYPKGS% >nul
IF ERRORLEVEL 1 GOTO INSTALLERROR
GOTO CHECK

:: QUICK CHECK ( Needs Improvement )
:CHECK
IF EXIST %CYINSTALLD%\Cygwin.bat (
GOTO EOF
) ELSE (
SET ERRORLEVEL=Cygwin Installation Failed
GOTO INSTALLERROR
)

:INSTALLERROR
ECHO.
ECHO --------------------------------------
ECHO    *** Cygwin Install Failure ***   
ECHO --------------------------------------
ECHO.
ECHO  If you aborted the install script
ECHO  you will need to re-run the setup.
ECHO.
ECHO  If the problem presists, contact the
ECHO  Dev-Team for further assistance
ECHO.
ECHO  Error Status: %ERRORLEVEL%
ECHO.
EXIT /B 1

:ERROR1
CD /D %BASED%
ECHO ..Exiting with error: %ERRORLEVEL%
EXIT /B 1
CLS

:EOF
ECHO ..Finished JTSDK-DOC Installation ^( Cygwin x86 ^)
ECHO.
CD /D %BASED%
EXIT /B 0
CLS