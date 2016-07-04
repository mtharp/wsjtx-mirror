::-----------------------------------------------------------------------------::
:: Name .........: gocal.bat
:: Project ......: Part of the PyFMT Project
:: Description ..: Runs a series of frequencies for rig calibration
:: Project URL ..: http://sourceforge.net/projects/jtsdk
:: Usage ........: Run this file directly, or from the Windows Start Menu
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2001-2016 Joe Taylor, K1JT
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
IF NOT EXIST "%~dp0\fmt.ini" ( GOTO NEED_INI )
PATH=.;.\bin

REM -- Only edit items "between" < BEGIN .. and .. END >
REM    More Info: http://physics.princeton.edu/pulsar/K1JT/FMT_User.pdf

:: < BEGIN - Edit Station Information >
fmtest   950 1 1500 100 30  KCAP
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
ECHO  Missing [ fmt.ini ] File
ECHO ------------------------------------
ECHO  You must first run [ fmtmain.exe to
ECHO  generate the an fmt.ini file before
ECHO  running gocal.bat
ECHO.
ECHO  Make sure to use the Save Button
ECHO  before exiting the Station Parameters WWidget
ECHO.
ENDLOCAL
EXIT /B 1