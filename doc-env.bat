@ECHO OFF
REM -- JTSDK-DOC Environment
REM -- Part of the WSJT Documentation project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 0E
TITLE WSJT Documentation Environment

SET TARGET=%~dp0
IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
SET BASED=%TARGET%
SET ASCID=%BASED%\asciidoc
SET SVND=..\subversion\bin
SET TOOLS=..\tools
SET PATH=%BASED%;%SVND%;%TOOLS%;%WINDIR%\System32
CD /D %BASED%

REM -- DOSKEY BUILD COMMAND FROM ENV
DOSKEY wsjt=%BASED%\build.bat wsjt
DOSKEY wsjtx=%BASED%\build.bat wsjtx
DOSKEY wspr=%BASED%\build.bat wspr
DOSKEY wsprx=%BASED%\build.bat wsprx
DOSKEY map65=%BASED%\build.bat map65
DOSKEY devg=%BASED%\build.bat devg
DOSKEY qref=%BASED%\build.bat qref
DOSKEY doc-help=%BASED%\build.bat help

REM -- DOSKEYS TO OPEN DOCS FORM COMMAND LINE
DOSKEY wsjt=start explorer wsjt\wsjt-main.html
DOSKEY wsjtx=start explorer wsjtx\wsjt-main-toc2.html
DOSKEY wspr=start explorer wspr\wspr-main.html
DOSKEY wsprx=start explorer wsprx\wsprx-main.html
DOSKEY map65=start explorer map65\map65-main.html
DOSKEY devg=start explorer dev-guide\dev-guide-main.html
DOSKEY qref=start explorer quick-ref\quick-ref-main.html

REM -- UPDATE FROM PREVIOUS INSTALL
DOSKEY update=CAll dev-guide\scripts\install-scripts.bat

call %BASED%\build.bat help
%WINDIR%\System32\cmd.exe /A /Q /K
