REM - JTSDK-QT ANONYMOUS CHEKCOUT
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM -- TEST DOUBLE CLICK
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DCLICK

REM -- SET PATHS
SET LANG=en_US
SET BASED=%~dp0
IF %BASED:~-1%==\ SET BASED=%BASED:~0,-1%
SET SVND=%BASED%\subversion\bin
SET SRCD=%BASED%\src
SET SCRIPTS=%TOOLS%\scripts
SET PATH=%BASED%;%SVND%;%SCRIPTS%;%SRCD%;%WINDIR%\System32
GOTO CHKAPP

:CHKAPP
IF /I [%1]==[wsjtx] (SET APP_NAME=wsjtx &GOTO BRANCHCO
) ELSE IF /I [%1]==[wsprx] (SET APP_NAME=wsprx &GOTO BRANCHCO
) ELSE IF /I [%1]==[map65] (SET APP_NAME=map65 &GOTO BRANCHCO
) ELSE (GOTO UNSUPPORTEDCO)

:BRANCHCO
CD /D %SRCD%
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO Checking Out ^( %APP_NAME% ^) From SVN
ECHO -----------------------------------------------------------------
start /wait svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/%APP_NAME%
CD %BASED%
ECHO.
ECHO Checkout complete. The next screen shows available build options.
ECHO.
PAUSE
GOTO FINISH
)

:FINISH
CALL %SCRIPTS%\jtsdk-qtbuild-help.bat
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
ECHO   %BASED%\jtsdk-qtenv.bat
ECHO.
PAUSE
GOTO EOF

:EOF
COLOR
ENDLOCAL
EXIT /B 0