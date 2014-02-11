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
SET APPS_ARRAY=(map65 quick-ref simjt wsjt wsjtx wspr wsprx )

REM -- Start building documents
REM --        manifest checking
REM --        command-line input options
call:head_wording
call:function_TOC2
call:tail_wording

REM ----------------------
REM -- Function Section --
REM ----------------------

REM -- Initial message wording
:head_wording
CLS
ECHO WSJT Documentation Build
ECHO.
GOTO :eof

REM -- End wording message
:tail_wording
ECHO.
ECHO Finished Building Documentation.
ECHO.
PAUSE
GOTO :eof

REM -- Main build loop
:function_TOC2
FOR %%a IN %APPS_ARRAY% DO (
CD %BASEDIR%\%%a
%TOC2% -o %%a-main-toc2.html source\%%a-main.adoc 
ECHO .. %%a-main-toc2.html
ECHO.
)
GOTO :eof

REM -----------------
REM -- End of File --
REM -----------------

:eof
ENDLOCAL
EXIT /B 0
