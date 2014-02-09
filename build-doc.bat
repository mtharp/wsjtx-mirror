REM Description	: WSJT Documentation Build Script for Windows
REM Title		: build-doc.bat
REM Author      : KI7MT
REM Email       : ki7mt@yahoo.com
REM Date        : 2014
REM Usage       : ./build-doc.bat
REM Notes       : Requires: Python 2.7+
REM Copyright   : GPLv(3)

REM This program is free software: you can redistribute it and/or modify
REM under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.

REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.

REM You should have received a copy of the GNU General Public License
REM along with this program.  If not, see <http://www.gnu.org/licenses/>.

REM -- Start Main Script
SET VERS=0.0.1
VERSION
@ECHO OFF
SETLOCAL
%~dp0

REM -- Temporary screen message
CLS
MODE con:cols=90 lines=20
ECHO.
ECHO *** WSJT Documenttion Build Script for Windows ***
ECHO                Version %VERS%
ECHO.
ECHO         This script is under development
ECHO.
ECHO.
PAUSE

ENDLOCAL
EXIT /B 0
