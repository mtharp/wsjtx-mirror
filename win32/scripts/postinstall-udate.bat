::-----------------------------------------------------------------------------::
:: Name .........: postinstall-update
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Post install update for various JTSDK elements
:: Project URL ..: http://sourceforge.net/projects/wsjt/ 
:: Usage ........: This file is run from JTSDK installer script
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: postinstall-update is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: postinstall-update is distributed in the hope that it will be useful, but
:: WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
:: or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
:: more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

@ECHO OFF
COLOR 0E
VERSION=2.0.0

SETLOCAL
SET BASED=C:\JTSDK
SET TOOLS=%BASED%\tools\bin
SET SCR=%BASED%\scripts
SET PATH=%BASED%;%TOOLS%;%SCR%;%WINDIR%\System32
CD /D %BASED%

:: Setup Tools and Unix like alias commands, %WINDIR%\System32 in %PATH%
SET CP="%TOOLS%\cp.exe" $*
DOSKEY mkdir="%TOOLS%\mkdir.exe" $*
DOSKEY clear=cls
DOSKEY ls=dir

clear
ECHO ^********************************************
ECHO            UPDATTING JTSDK %VERSION%
ECHO ^********************************************
ECHO.
IF NOT EXIST %BASED%JTSDK\cyg32 (
ECHO ..Did Not Find ^( C:\JTSDK\cyg32 ^), skipping update
GOTO UPDATE_MSYS
)

REM -- Update JTSDK\cyg32 elements
ECHO .. Updating CYG32
%CP% -uR %SCR%\etc\skel\jtsdk.bash_profile %BASED%\cyg32\etc\skel\.bash_profile >nul
%CP% -uR %SCR%\etc\skel\jtsdk.bashrc %BASED%\cyg32\etc\skel\.bashrc >nul
%CP% -uR %SCR%\etc\skel\jtsdk.inputrc %BASED%\cyg32\etc\skel\.inputrc >nul
%CP% -uR %SCR%\etc\skel\jtsdk.minttyrc %BASED%\cyg32\etc\skel\.minttyrc >nul
%CP% -uR %SCR%\etc\skel\jtsdk.profile %BASED%\cyg32\etc\skel\.profile >nul

REM -- Update JTSDK\msys elements
IF NOT EXIST %BASED%JTSDK\msys (
ECHO ..Did Not Find ^( C:\JTSDK\msys ^), skipping update
GOTO FINISHED
)
ECHO .. Updating MSYS

GOTO FINISHED


:FINISHED
ECHO FInished All Updates
GOTO EOF

:EOF
ENDLOCAL
EXIT /B 0
