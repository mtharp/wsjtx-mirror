@ECHO OFF
REM -- JTSDK-DOC Environment
REM -- Part of the WSJT Documentation project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR F0
TITLE WSJT Documentation Environment

SET TARGET=%~dp0
IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
SET BASED=%TARGET%
SET ASCID=%BASED%\asciidoc
SET PATH=%BASED%;%PATH%
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

call %BASED%\build.bat help

%WINDIR%\System32\cmd.exe /A /Q /K
