::-----------------------------------------------------------------------------::
:: Name .........: qtenv-co.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Batch file to check out WSJT-X/RC, WSPR-X and MAP65
:: Project URL ..: http://sourceforge.net/projects/wsjt/ 
:: Usage ........: This file is run from within pyenv.bat
:: 
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: qtenv-co.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: qtenv-co.bat is distributed in the hope that it will be useful, but WITHOUT
:: ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
:: FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
:: details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

:: ENVIRONMENT
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
SET LANG=en_US
COLOR 0B


:: TEST DOUBLE CLICK, if YES, GOTO ERROR MESSAGE
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DOUBLE_CLICK_ERROR


:: PATH VARIABLES
SET BASED=C:\JTSDK
SET BIN=%BASED%\tools\bin
SET SRCD=%BASED%\src
SET SCR=%BASED%\scripts
SET SVND=%BASED%\subversion\bin
SET PATH=%BASED%;%BIN%;%SRCD%;%SCR%;%SVND%;%WINDIR%\System32
GOTO CHK_APP

:: CHECK IF APPLICATION NAME IF SUPPORTED
:CHK_APP
IF /I [%1]==[wsjtx-1.4] (SET APP_NAME=wsjtx-1.4 &GOTO WSJTX_RC
) ELSE IF /I [%1]==[wsjtx] ( SET APP_NAME=wsjtx & GOTO OTHER_CO
) ELSE IF /I [%1]==[wsprx] ( SET APP_NAME=wsprx & GOTO OTHER_CO
) ELSE IF /I [%1]==[map65] ( SET APP_NAME=map65 & GOTO OTHER_CO
) ELSE ( GOTO UNSUPPORTED_CO )

:: PERFORM WSPR CHECKOUT
:WSJTX_RC
CD /D %SRCD%
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO Checking Out ^( %APP_NAME% ^) From SVN
ECHO -----------------------------------------------------------------
start /wait svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/wsjtx-1.4
CD %BASED%
GOTO NEXT
)

:: PERFORM WSPR CHECKOUT
:OTHER_CO
CD /D %SRCD%
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO Checking Out ^( %APP_NAME% ^) From SVN
ECHO -----------------------------------------------------------------
start /wait svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/%APP_NAME%
CD %BASED%
GOTO NEXT
)

:: CHECKOUT FINISHED MESSAGE
:: TO-DO - Add %ERRORLEVEL% check in case SVN CO fails
:NEXT
CD %BASED%
ECHO.
ECHO Checkout complete. 
ECHO.
PAUSE
GOTO FINISHED

:: FINISHED CHECKOUT MESSAGE
:FINISHED
ECHO.
call %SCR%\qtenv-build-help.bat
ECHO.
GOTO EOF

:: UNSUPPORTED APPLICATION CHECKOUT
:UNSUPPORTED_CO
CLS
ECHO.
ECHO ----------------------------------------
ECHO          UNSUPPORTED CHECKOUT
ECHO ----------------------------------------
ECHO.
ECHO       ^( %1 ^) Is Unsupported
ECHO.
ECHO Only WSJT-X, WSJTX-1.4, WSPR-X and MAP65
ECHO.
ECHO             Are Supported 
ECHO.
ECHO         Please Check Your Entry
ECHO.
PAUSE
GOTO EOF

:: WARN ON DOUBLE CLICK
:DOUBLE_CLICK_ERROR
CLS
ECHO -------------------------------
ECHO     DOUBLE CLICK WARNING
ECHO -------------------------------
ECHO.
ECHO  Please Use JTSDK Enviroment
ECHO.
ECHO         qtenv.bat
ECHO.
PAUSE
GOTO EOF

:: END OF PYENV-CO.BAT
:EOF
CD /D %BASED%
ENDLOCAL

EXIT /B 0
