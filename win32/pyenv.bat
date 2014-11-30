::-----------------------------------------------------------------------------::
:: Name .........: pyenv.bat
:: Function .....: JTSDK Python Environment for Win32
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Sets the Environment for building WSJT and WSPR
:: Project URL ..: http://sourceforge.net/projects/jtsdk 
:: Usage ........: Windows Start, run C:\JTSDK\pyenv.bat
:: 
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: pyenv.bat is free software: you can redistribute it and/or modify it under the
:: terms of the GNU General Public License as published by the Free Software
:: Foundation either version 3 of the License, or (at your option) any later
:: version. 
::
:: pyenv.bat is distributed in the hope that it will be useful, but WITHOUT ANY
:: WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
:: A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

:: ENVIRONMENT
@ECHO OFF
TITLE JTSDK Python Development Environment
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
SET LANG=en_US
COLOR 0A

:: PATH VARIABLES
SET LIBRARY_PATH=
SET BASED=C:\JTSDK
SET TOOLS=%BASED%\tools\bin
SET MGW=%BASED%\mingw32\bin
SET INNO=%BASED%\inno5
SET SCR=%BASED%\scripts
SET PYP=%BASED%\Python33
SET PYS=%BASED%\Python33\Scripts
SET PYD=%BASED%\Python33\DLLs
SET SVND=%BASED%\subversion\bin
SET PATH=%BASED%;%MGW%;%PYP%;%PYS%;%PYD%;%TOOLS%;%INNO%;%SCR%;%SVND%;%WINDIR%\System32
CD /D %BASED%

:: GENERAL USE DOSKEY COMMANDS
DOSKEY checkout="%SCR%\pyenv-co.bat" $1
DOSKEY build="%SCR%\pyenv-build.bat" $1 $2
DOSKEY env-info=CALL %SCR%\pyenv-info.bat
DOSKEY make=C:\JTSDK\mingw32\bin\mingw32-make $*

:: SVN POWER-USER COMMANDS
DOSKEY ss="svn.exe" $* status
DOSKEY sv="svn.exe" $* status ^|grep "?"
DOSKEY sa="svn.exe" $* status ^|grep "A"
DOSKEY sm="svn.exe" $* status ^|grep "M"
DOSKEY sd="svn.exe" $* status ^|grep "D"
DOSKEY log="svn.exe" log -l $*
DOSKEY logv="svn.exe" log -v -l $*

CALL %SCR%\pyenv-info.bat
IF NOT EXIST %BASED%\src\NUL mkdir %BASED%\src
GOTO EOF

:: LAUNCH CMD WINDOW
:EOF
%COMSPEC% /A /Q /K
