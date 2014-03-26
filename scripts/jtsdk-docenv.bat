@ECHO OFF
REM -- JTSDK-DOC Environment
REM -- Part of the WSJT Documentation project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 0E
TITLE JTSDK-DOC Environment

REM -- SET PATH VARS
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET SVND=%BASED%\subversion\bin
SET TOOLS=%BASED%\tools
SET PATH=%BASED%;%SVND%;%TOOLS%;%WINDIR%;%WINDIR%\System32
CD /D %BASED%

IF EXIST %BASED%\doc (
call %BASED%\doc\doc-env.bat
) ELSE (
CLS
ECHO -----------------------------------
ECHO     Doc Directory Not Found
ECHO -----------------------------------
ECHO.
ECHO In order to use the build keys, you
ECHO must firtst perform a checkout from
ECHO SourceForge, then relaunch jtsdk-docenv.bat:
ECHO.
ECHO Anonymous .. Type: svn co svn://svn.code.sf.net/p/wsjt/wsjt/branches/doc
ECHO Developer .. Type: svn co https://%USERNAME%@svn.code.sf.net/p/wsjt/wsjt/branches/doc
ECHO.
ECHO Note: For Dev's, replace %USERNAME% with your SorceForge User Name.
ECHO.
pause
ECHO.
%WINDIR%\System32\cmd.exe /A /Q /K
)
