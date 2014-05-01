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
SET TOOLS=%BASED%\tools;%BASED%\tools\bin;%BASED%\tools\include;%BASED%\tools\lib
SET PATH=%BASED%;%SVND%;%TOOLS%;%WINDIR%;%WINDIR%\System32
CD /D %BASED%
GOTO UPDATE

:UPDATE
IF /I [%1]==[update] (
GOTO CHKSVN
) ELSE (GOTO CONTINUE)

:CHKSVN
IF EXIST %BASED%\doc\dev-guide\scripts\install-scripts.bat (
CALL %BASED%\doc\dev-guide\scripts\install-scripts.bat
GOTO CONTNUE
) ELSE (GOTO CONTINUE)

:CONTINUE
IF EXIST %BASED%\doc (
call %BASED%\doc\doc-env.bat
) ELSE (
CLS
ECHO -----------------------------------
ECHO      Doc Directory Not Found
ECHO -----------------------------------
ECHO.
ECHO   In order to use JTSDK-DOC , you
ECHO must first perform a checkout from
ECHO SourceForge, then relaunch jtsdk-docenv.bat:
ECHO.
ECHO ANONYMOUS CHECKOUT
ECHO   svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/doc
ECHO.
ECHO FOR DEV CHECKOUT
ECHO   svn co https://%USERNAME%@svn.code.sf.net/p/wsjt/wsjt/branches/doc
ECHO.
ECHO DEV NOTE: Replace ^( %USERNAME% ^) with your SorceForge User Name.
ECHO.
pause
ECHO.
%WINDIR%\System32\cmd.exe /A /Q /K
)
