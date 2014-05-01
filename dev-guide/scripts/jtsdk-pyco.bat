REM - JTSDK-QT ANONYMOUS CHEKCOUT
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM -- TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DCLICK

REM -- SET PATHS
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET SVND=%BASED%\subversion\bin
SET SRCD=%BASED%\src
SET PATH=%BASED%;%SVND%;%SRCD%;%WINDIR%\System32
GOTO CHKAPP

:CHKAPP
IF /I [%1]==[wsjt] (SET APP_NAME=wsjt &GOTO TRUNKCO
) ELSE IF /I [%1]==[wspr] (SET APP_NAME=wspr &GOTO BRANCHCO
) ELSE (GOTO UNSUPPORTEDCO)

:BRANCHCO
CD /D %SRCD%
ECHO CHECKING OUT ^( %APP_NAME% ^)
start /wait svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/%APP_NAME%
CD %BASED%
GOTO FINISHED
)

:TRUNKCO
CD /D %SRCD%
ECHO CHECKING OUT ^( %APP_NAME% ^)
start /wait svn co https://svn.code.sf.net/p/wsjt/wsjt/trunk
CD %BASED%
GOTO FINISHED
)

:FINISHED
ECHO.
ECHO To Build ^( %APP_NAME% ^)
ECHO Type: build %APP_NAME%
ECHO.
GOTO EOF

REM - UNSUPPORTED APPLICATION CHECKOUT
:UNSUPPORTEDCO
COLOR 1E
CLS
ECHO.
ECHO ----------------------------------------
ECHO         UNSUPPORTED CHECKOUT
ECHO ----------------------------------------
ECHO.
ECHO       ^( %1 ^) Is Unsupported
ECHO.
ECHO       Only WSJTX, WSPRX and MAP65
ECHO.
ECHO            Are Supported 
ECHO.
ECHO        Please Check Your Entry
ECHO.
PAUSE
GOTO EOF

REM -- WARN ON DOUBLE CLICK
:DCLICK
@ECHO OFF
CLS
COLOR 1E
ECHO -------------------------------
ECHO     DOUBLE CLICK WARNING
ECHO -------------------------------
ECHO.
ECHO  Please Use JTSDK Enviroment
ECHO.
ECHO   %BASED%\jtsdk-pyenv.bat
ECHO.
PAUSE
GOTO EOF

:EOF
COLOR
ENDLOCAL
EXIT /B 0