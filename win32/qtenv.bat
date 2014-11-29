::-----------------------------------------------------------------------------::
:: Name .........: qtenv.bat
:: Function .....: JTSDK QT5 Environment for Win32
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Sets the Environment for building WSJT-X, WSPR-X and MAP65
:: Project URL ..: http://sourceforge.net/projects/jtsdk 
:: Usage ........: Windows Start, run C:\JTSDK\qtenv.bat
:: 
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: qtenv.bat is free software: you can redistribute it and/or modify it under the
:: terms of the GNU General Public License as published by the Free Software
:: Foundation either version 3 of the License, or (at your option) any later
:: version. 
::
:: qtenv.bat is distributed in the hope that it will be useful, but WITHOUT ANY
:: WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
:: A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

:: ENVIRONMENT
@ECHO OFF
TITLE JTSDK QT5 Development Environment
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
SET LANG=en_US
COLOR 0B

:: PATH VARIABLES
SET BASED=C:\JTSDK
SET CMK=%BASED%\cmake\bin
SET BIN=%BASED%\tools\bin
SET HL3=%BASED%\hamlib3\bin
SET FFT=%BASED%\fftw3f
SET NSI=%BASED%\nsis
SET INO=%BASED%\inno5
SET GCCD=%BASED%\qt5\Tools\mingw48_32\bin
SET QT5D=%BASED%\qt5\5.2.1\mingw48_32\bin
SET QT5A=%BASED%\qt5\5.2.1\mingw48_32\plugins\accessible
SET QT5P=%BASED%\qt5\5.2.1\mingw48_32\plugins\platforms
SET SCR=%BASED%\scripts
SET SRCD=%BASED%\src
SET SVND=%BASED%\subversion\bin
SET LIBRARY_PATH=""
SET PATH=%BASED%;%CMK%;%BIN%;%HL3%;%FFT%;%GCCD%;%QT5D%;%QT5A%;%QT5P%;%NSI%;%INO%;%SRCD%;%SCR%;%SVND%;%WINDIR%;%WINDIR%\System32
CD /D %BASED%

:: DOSKEY COMMANDS
DOSKEY checkout="%SCR%\qtenv-co.bat" $1
DOSKEY build="%SCR%\qtenv-build.bat" $1 $2
DOSKEY wsjtxrc="%SCR%\qtenv-wsjtxrc.bat" $1
DOSKEY env-info=CALL %SCR%\qtenv-info.bat
DOSKEY build-help=CALL %SCR%\qtenv-build-help.bat
DOSKEY vinfo=CALL %SCR%\qtenv-version.bat
CALL %SCR%\qtenv-info.bat
IF NOT EXIST %BASED%\src\NUL mkdir %BASED%\src
GOTO EOF

:: LAUNCH CMD WINDOW
:EOF
%WINDIR%\System32\cmd.exe /A /Q /K
