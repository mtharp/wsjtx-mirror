@ECHO OFF
REM -- JTSDK-PY Python Custom Environment
REM -- Part of the JTSDK Project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 0A
TITLE JTSDK-PY Environment

REM -- SET BASE PATH to "." & TRIM TRAILING "\" IF PRESENT
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET TOOLS=%BASED%\tools
SET MINGW=%BASED%\mingw32\bin
SET SVND=%BASED%\subversion\bin
SET SCRIPTS=%BASED%\tools\scripts
SET PYTHONPATH=%BASED%\Python33;%BASED%\Python33\Scripts;%BASED%\Python33\DLLs;%BASED%\Python33\Tools\Scripts
SET PATH=%BASED%;%MINGW%;%PYTHONPATH%;%SVND%;%TOOLS%;%SCRIPTS%;%WINDIR%;%WINDIR%\System32

REM -- DOSKEY COMMANDS
DOSKEY checkout="%BASED%\jtsdk-pyco.bat" $1
DOSKEY build="%BASED%\jtsdk-python.bat" $1
DOSKEY env-info=CALL %SCRIPTS%\jtsdk-pyinfo.bat

REM -- SVN MUST BE AVAILABLE AT STARTUP
svn --version >nul 2>null || SET APP=SVN && GOTO ERROR1
DEL /Q null
GOTO PYP1

REM -- REBASE CX_FREEZE PATHS
:PYP1
IF NOT EXIST %BASED%\Python33\Scripts\pyp1.txt (
CLS
ECHO.
ECHO        Updating ^( cx_Freeze ^) Paths
ECHO.
ECHO This patch corrects cx_Freeze build paths.
ECHO It should only be performed once. If you continue
ECHO to see this message, contact the wsjt-devel group.
ECHO.
cd %BASED%\Python33\Scripts
python cxfreeze-postinstall

REM -- ADD PATCH MARKER
touch %BASED%\Python33\Scripts\pyp1.txt
ECHO Finished ...
ECHO.
pause
)
GOTO CONTINUE

REM - TOOL CHAIN ERROR MESSAGE
:ERROR1
COLOR 1C
CLS
ECHO.
ECHO ------------------------------
ECHO      CRITIAL APP ERROR
ECHO ------------------------------
ECHO ^( %APP%^) Was Not Found.
ECHO.
ECHO Please check your tool chain
ECHO PATH variables and re-start
ECHO    JTSDK-PY Env Terminal
ECHO.
PAUSE
DEL /Q null
ENDLOCAL
COLOR
EXIT /B 1

REM - GET ENV-INFO and OPEN CMD WINDOW
:CONTINUE
CALL %SCRIPTS%\jtsdk-pyinfo.bat
ECHO.
%WINDIR%\System32\cmd.exe /A /Q /K