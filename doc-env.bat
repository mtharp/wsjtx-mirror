::----------------------------------------------------------------------------::
:: Name .........: doc-env.bat
:: Project ......: Part of the JTSDK v1.0.0 Project
:: Description ..: WSJT Documentation Environment Script
:: Project URL ..: http://sourceforge.net/projects/wsjt/
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014-2015 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: Comment ......: This script is used with JTSDK v1 for Windows and provides
::                 the JTSDK-DOC environment.
::
:: doc-env.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: doc-env.bat is distributed in the hope that it will be useful, but WITHOUT
:: ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
:: FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
:: details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::----------------------------------------------------------------------------::

@ECHO OFF

SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 0E
TITLE JTSDK-DOC Development Environment

SET TARGET=%~dp0
IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
SET BASED=%TARGET%
SET ASCID=%BASED%\asciidoc
SET SVND=%CD%\subversion\bin
SET INNOD=%BASED%\inno5
SET SET TOOLS=%BASED%\tools;%BASED%\tools\bin;%BASED%\tools\include;%BASED%\tools\lib
SET PATH=%BASED%;%ASCID%;%SVND%;%INNOD%;%TOOLS%;%WINDIR%\System32
CD /D %BASED%

REM -- DOSKEY BUILD COMMAND FROM ENV
DOSKEY wsjt=%BASED%\build.bat wsjt
DOSKEY wsjtx=%BASED%\build.bat wsjtx
DOSKEY wspr=%BASED%\build.bat wspr
DOSKEY wfmt=%BASED%\build.bat wfmt
DOSKEY wsprx=%BASED%\build.bat wsprx
DOSKEY map65=%BASED%\build.bat map65
DOSKEY devg=%BASED%\build.bat devg
DOSKEY qref=%BASED%\build.bat qref
DOSKEY doc-help=%BASED%\build.bat help

REM -- DOSKEYS TO OPEN DOCS FORM COMMAND LINE
DOSKEY wsjt=start explorer wsjt\wsjt-main.html
DOSKEY wsjtx=start explorer wsjtx\wsjtx-main.html
DOSKEY wspr=start explorer wspr\wspr-main.html
DOSKEY wfmt=start explorer wfmt\wfmt-main.html
DOSKEY wsprx=start explorer wsprx\wsprx-main.html
DOSKEY map65=start explorer map65\map65-main.html
DOSKEY devg=start explorer dev-guide\dev-guide-main.html
DOSKEY qref=start explorer quick-ref\quick-ref-main.html

REM -- UPDATE FROM PREVIOUS INSTALL
DOSKEY update=CAll dev-guide\scripts\install-scripts.bat

call %BASED%\build.bat help
%WINDIR%\System32\cmd.exe /A /Q /K
