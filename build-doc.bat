@ECHO OFF
SET VERS=0.0.1-Alpha
REM Description	: WSJT Documentation Build Script for Windows
REM Title		: build-doc.bat
REM Author      : KI7MT
REM Email       : ki7mt@yahoo.com
REM Date        : 2014
REM Usage       : ./build-doc.bat
REM Notes       : Requires: Python 2.6.5 thru 2.7.x
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

REM -- Check if Python is available
python -V >nul 2>nul
IF %ERRORLEVEL% neq 9009 goto continue
CLS
ECHO *** Python Was Not Found ***
ECHO.
ECHO Please ensure Python is installed and in your System Path
ECHO.
ECHO Then run build-doc.bat again
ECHO.
PAUSE
exit /B 1

:continue
REM -- Start WSJT Documentation Build
TITLE WSJT Documentation Build v%VERS%
SETLOCAL
MODE con:cols=60 lines=20
cd /d %~dp0

REM -- Set-up folder variables
SET BASEDIR=%CD%
SET ADOC=%BASEDIR%\asciidoc\asciidoc.py
SET ICOND=%BASEDIR%\icons
SET DEVG=%BASEDIR%\dev-guide
SET QUICKR=%BASEDIR%\quick-ref
SET MAP65=%BASEDIR%\map65
SET SIMJT=%BASEDIR%\simjt
SET WSJT=%BASEDIR%\wsjt
SET WSJTX=%BASEDIR%\wsjtx
SET WSPR=%BASEDIR%\wspr
SET WSPRX=%BASEDIR%\wsprx
SET NTOC=%ADOC% -b xhtml11 -a iconsdir=%ICOND% -a max-width=1024px
SET TOC1=%ADOC% -b xhtml11 -a toc -a iconsdir=%ICOND% -a max-width=1024px
SET TOC2=%ADOC% -b xhtml11 -a toc2 -a iconsdir=%ICOND% -a max-width=1024px

REM -- Start building documents
REM -- TO-DO: loop through doc builds
REM --        manifest checking
REM --        input options
REM --        menu select v.s direct build
CLS
ECHO Building WSJT Documentation
ECHO.
CD %MAP65%
%TOC2% -o map65-main.html %MAP65%\source\map65-main.adoc
ECHO ..Finished map65-main-toc2.html

CD %SIMJT%
%TOC2% -o simjt-main-toc2.html %SIMJT%\source\simjt-main.adoc
ECHO ..Finished simjt-main-toc2.html

CD %WSJT%
%TOC2% -o wsjtx-main-toc2.html %WSJT%\source\wsjt-main.adoc
ECHO ..Finished wsjt-main-toc2.html

CD %WSJTX%
%TOC2% -o  wsjtx-main-toc2.html %WSJTX%\source\wsjtx-main.adoc
ECHO ..Finished wsjtx-main-toc2.html

CD %WSPR%
%TOC2% -o  wspr-main-toc2.html %WSPR%\source\wspr-main.adoc
ECHO ..Finished wspr-main-toc2.html

CD %WSPRX%
%TOC2% -o  wsprx-main-toc2.html %WSPRX%\source\wsprx-main.adoc
ECHO ..Finished wsprx-main-toc2.html

CD %QUICKR%
%TOC2% -o quick-reference.html %QUICKR%\source\quick-ref-main.adoc
ECHO ..Finished quick-reference.html
ECHO.
ECHO Completed Building WSJT Documentation
ECHO.
PAUSE

ENDLOCAL
EXIT /B 0
