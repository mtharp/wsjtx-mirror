::----------------------------------------------------------------------------::
:: Name .........: build.bat
:: Project ......: Part of the JTSDK v1.0.0 Project
:: Description ..: WSJT Documentation Main Build Script for Windows
:: Project URL ..: http://sourceforge.net/projects/wsjt/
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014-2015 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: Comment ......: This script is used with JTSDK v1 for Windows via the
::                 JTSDK-DOC environment. It will not function properly
::                 with JTSDK v2.
::
:: build.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: build.bat is distributed in the hope that it will be useful, but WITHOUT
:: ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
:: FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
:: details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::----------------------------------------------------------------------------::

@ECHO OFF

REM -- Start WSJT Documentation Build
TITLE JTSDK-DOC Development Environment
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
SET SCRIPTVER=0.9.1

REM -- SET BASE PATH to "." & TRIM TRAILING "\" IF PRESENT
REM SET TARGET=%~dp0
REM IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
REM SET BASED=%TARGET%
REM SET PATH=%BASED%;%ICOND%
SET ICOND=%BASED%\icons

REM -- PROCESS VARS
SET ADOC=%BASED%\asciidoc\asciidoc.exe
SET INNOD=%BASED%\inno5
SET TOC=%ADOC% -b xhtml11 -a toc2 -a iconsdir=../icons -a max-width=1024px
SET BUILD_LIST=(dev-guide map65 quick-ref simjt wsjt wsjtx wspr wfmt wsprx)

REM -- USER INPUT CONDITIONALS
IF /I [%1]==[help] (
CLS &ECHO.
GOTO DOCHELP
) ELSE IF /I [%1]==[all] (
CLS &ECHO.
GOTO BUILD_ALL
) ELSE IF /I [%1]==[devg] (
CLS &ECHO.
SET DOC_NAME=dev-guide
GOTO GENERAL
) ELSE IF /I [%1]==[wsprx] (
CLS &ECHO.
SET DOC_NAME=wsprx
GOTO GENERAL
) ELSE IF /I [%1]==[map65] (
CLS &ECHO.
SET DOC_NAME=map65
GOTO GENERAL
) ELSE IF /I [%1]==[qref] (
CLS &ECHO.
SET DOC_NAME=quick-ref
GOTO GENERAL
) ELSE IF /I [%1]==[simjt] (
CLS &ECHO.
SET DOC_NAME=simjt
GOTO GENERAL
) ELSE IF /I [%1]==[wsjt] (
CLS &ECHO.
SET DOC_NAME=wsjt
GOTO GENERAL
) ELSE IF /I [%1]==[wsjtx] (
CLS &ECHO.
SET DOC_NAME=wsjtx
GOTO GENERAL
) ELSE IF /I [%1]==[wspr] (
CLS &ECHO.
SET DOC_NAME=wspr
GOTO GENERAL
) ELSE IF /I [%1]==[wfmt] (
CLS &ECHO.
SET DOC_NAME=wfmt
GOTO GENERAL
) ELSE IF /I [%1]==[wsprx] (
CLS &ECHO.
SET DOC_NAME=wsprx
GOTO GENERAL 
) ELSE (GOTO DOCHELP)

REM -- BUILD USER SELECT DOCUMENT $1 == %1
:GENERAL
CD %BASED%\%DOC_NAME%
ECHO Building ^( %DOC_NAME% ^)
%TOC% -o %DOC_NAME%-main.html source\%DOC_NAME%-main.adoc
ECHO.
ECHO  Finished building ^( %DOC_NAME% ^)
ECHO  Location: %BASED%\%DOC_NAME%\%DOC_NAME%-main.html
ECHO.
IF /I [%1]==[devg] (
ECHO  To Open, Type: devg
) else (
ECHO  To Open, Type: %DOC_NAME%
)
ECHO.
PAUSE
ECHO.
GOTO EOF

REM -- BUILD ALL DOCS
:BUILD_ALL
CLS
REM -- LOOP FOR REMAINING DOCUMENTS
ECHO Building ^( ALL ^) Documentation
FOR %%A IN %BUILD_LIST% DO (
CD %BASED%\%%A
%TOC% -o %%A-main.html source\%%A-main.adoc 
ECHO .. Location: %BASED%\%%A\%%A-main.html
)
PAUSE
GOTO EOF

:DOCHELP
@ECHO OFF
CLS
ECHO.
ECHO      _ _____ ____  ____  _  __     ____   ___   ____ 
ECHO     ^| ^|_   _/ ___^|^|  _ \^| ^|/ /    ^|  _ \ / _ \ / ___^|
ECHO  _  ^| ^| ^| ^| \___ \^| ^| ^| ^| ' /_____^| ^| ^| ^| ^| ^| ^| ^|    
ECHO ^| ^|_^| ^| ^| ^|  ___) ^| ^|_^| ^| . \_____^| ^|_^| ^| ^|_^| ^| ^|___ 
ECHO  \___/  ^|_^| ^|____/^|____/^|_^|\_\    ^|____/ \___/ \____^| v1.0
ECHO.
ECHO.
ECHO BUILD WSJT DOCUMENTATION
ECHO ------------------------------------------------------
ECHO USAGE: build.bat [document name] or "all" for all docs.
ECHO. 
ECHO  build.bat wsjt
ECHO  build.bat wsjtx
ECHO  build.bat wspr
ECHO  build.bat wsprx
ECHO  build.bat wfmt
ECHO  build.bat map65
ECHO  build.bat devg
ECHO  build.bat qref
ECHO.
ECHO ------------------------------------------------------
ECHO.
ECHO To View, Type:  [document name]
ECHO For Help, Type: doc-help
ECHO.
EXIT /B 0

:EOF
call:DOCHELP
ENDLOCAL
EXIT /B 0
