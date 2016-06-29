::-----------------------------------------------------------------------------::
:: Name .........: gocal.bat
:: Project ......: Part of the WSPR Project
:: Description ..: Maintenance script for updated & upgrades or general use
:: Project URL ..: http://sourceforge.net/projects/jtsdk
:: Usage ........: Run this file directly, or from the Windows Start Menu
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2001-2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: gocal.bat is free software: you can redistribute it and/or modify it under
:: the terms of the GNU General Public License as published by the Free Software
:: Foundation either version 3 of the License, or (at your option) any later
:: version. 
::
:: gocal.bat is distributed in the hope that it will be useful, but WITHOUT ANY
:: WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
:: A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

@ECHO OFF
SETLOCAL
PATH=.;.\bin
IF NOT EXIST "%~dp0\WSPR.INI" ( GOTO NEED_INI )

REM -- Only edit items "between" < BEGIN .. and .. END >
REM    More Info: http://physics.princeton.edu/pulsar/K1JT/FMT_User.pdf

:: < BEGIN - Edit Station Information >
fmtest   660 1 1500 100 30  WFAN
fmtest   880 1 1500 100 30  WCBS
fmtest  1210 1 1500 100 30  WPHT
fmtest  2500 1 1500 100 30  WWV
fmtest  3330 1 1500 100 30  CHU
fmtest  5000 1 1500 100 30  WWV
fmtest  7850 1 1500 100 30  CHU
fmtest 10000 1 1500 100 30  WWV
fmtest 14670 1 1500 100 30  CHU
fmtest 15000 1 1500 100 30  WWV
fmtest 20000 1 1500 100 30  WWV
:: < END - Edit Station Information >
GOTO EOF

:EOF
ENDLOCAL
EXIT /B 0

:NEED_INI
CLS
ECHO ------------------------------------
ECHO        Missing WSPR.INI File
ECHO ------------------------------------
ECHO  You must first run WSPR to generate
ECHO  the an WSPR.INI file before running
ECHO  gocal.bat
ECHO.
ECHO  Make sure to save your latest
ECHO  changes by going to: 
ECHO  File, Save user parameters
ECHO.
ENDLOCAL
EXIT /B 1