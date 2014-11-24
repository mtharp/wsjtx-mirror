::-----------------------------------------------------------------------------::
:: Name .........: postinstall-update
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Post install update for various JTSDK elements
:: Project URL ..: http://sourceforge.net/projects/wsjt/ 
:: Usage ........: This file is run from JTSDK installer script
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: postinstall-update is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: postinstall-update is distributed in the hope that it will be useful, but
:: WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
:: or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
:: more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

@ECHO OFF
COLOR 0E
SETLOCAL
SET VERSION=2.0
SET BASED=C:\JTSDK
SET TOOLS=%BASED%\tools\bin
SET SCR=%BASED%\scripts
SET PATH=%BASED%;%TOOLS%;%SCR%;%WINDIR%\System32
CD /D %BASED%

ECHO ^*****************************
ECHO    UPDATTING JTSDK %VERSION%
ECHO ^*****************************
ECHO.

REM -- PERFORM CO or UPDATE FROM WSJT SVN --------------------------------------
IF NOT EXIST %BASED%\.svn\NUL (
ECHO ..Performaing Initial Checkout from WSJT
start /wait svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/jtsdk/win32 .
IF ERRORLEVEL 1 GOTO SVN_ERROR
)

:: ASK TO UPDATE
:ASK_SVN
ECHO Update JTSDK from SVN? ^( y/n ^)
SET ANSWER=
ECHO.
SET /P ANSWER=Type Response: %=%
If /I "%ANSWER%"=="N" GOTO UPDATE_CMAKE
If /I "%ANSWER%"=="Y" (
GOTO SVN_UPDATE
) ELSE (
ECHO.
ECHO Please Answer With: ^( Y or N ^)
GOTO ASK_SVN
)

:: UPDATE JTSDK FROM SVN
:SVN_UPDATE
ECHO.
ECHO UPDATING ^( JTSDK-%VERSION% ^ )
CD /D %BASED%
start /wait svn cleanup 
start /wait svn update
IF ERRORLEVEL 1 GOTO SVN_ERROR
GOTO UPDATE_CMAKE

REM -- UPDATE CMAKE ------------------------------------------------------------
:UPDATE_CMAKE
IF NOT EXIST %BASED%\cmake\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\cmake ^), skipping update
GOTO UPDATE_CYG32
)
ECHO ..CMAKE - no updates needed
GOTO UPDATE_CYG32

REM -- UPDATE CYG32 ------------------------------------------------------------
:UPDATE_CYG32
IF NOT EXIST %BASED%\cyg32\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\cyg32 ^), skipping update
GOTO UPDATE_FFTW3F
)
ECHO .. Updating JTSDK-CYG32 RC Files
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.bash_profile %BASED%\cyg32\etc\skel\.bash_profile >nul
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.bashrc %BASED%\cyg32\etc\skel\.bashrc >nul
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.inputrc %BASED%\cyg32\etc\skel\.inputrc >nul
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.minttyrc %BASED%\cyg32\etc\skel\.minttyrc >nul
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.profile %BASED%\cyg32\etc\skel\.profile >nul
GOTO UPDATE_FFTW3F

REM -- UPDATE FFTW3F -----------------------------------------------------------
:UPDATE_FFTW3F
IF NOT EXIST %BASED%\fftw3f\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\fftw3f ^), skipping update
GOTO UPDATE_MSYS
)
ECHO ..FFWT3F - no updates needed
GOTO UPDATE_HAMLIB2

REM -- UPDATE HAMLIB2 ----------------------------------------------------------
:UPDATE_HAMLIB2
IF NOT EXIST %BASED%\hamlib\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\hamlib ^), skipping update
GOTO UPDATE_HAMLIB3
)
ECHO ..HAMLIB2 - no updates needed
GOTO UPDATE_HAMLIB3

REM -- UPDATE HAMLIB3-----------------------------------------------------------
:UPDATE_HAMLIB3
IF NOT EXIST %BASED%\hamlib3\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\hamlib3 ^), skipping update
GOTO UPDATE_INNO5
)
ECHO ..HAMLIB3 - no updates needed
GOTO UPDATE_INNO5

REM -- UPDATE INNO5 ------------------------------------------------------------
:UPDATE_INNO5
IF NOT EXIST %BASED%\inno5\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\inno5 ^), skipping update
GOTO UPDATE_MINGW32
)
ECHO ..INNO5 - no updates needed
GOTO UPDATE_MINGW32

REM -- UPDATE MINGW32 ----------------------------------------------------------
:UPDATE_MINGW32
IF NOT EXIST %BASED%\mingw32\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\mingw32 ^), skipping update
GOTO UPDATE_MSYS
)
ECHO ..MINGW32 - no updates needed
GOTO UPDATE_MSYS

REM -- UPDATE MSYS -------------------------------------------------------------
:UPDATE_MSYS
REM -- Update JTSDK\msys elements
IF NOT EXIST %BASED%\msys\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\msys ^), skipping update
GOTO UPDATE_NSIS
)
ECHO .. Updating JTSDK-MSYS RC Files
COPY /Y %SCR%\msys\etc\skel\jtsdk.bash_profile %BASED%\msys\etc\skel\.bash_profile >nul
COPY /Y %SCR%\msys\etc\skel\jtsdk.bashrc %BASED%\msys\etc\skel\.bashrc >nul
COPY /Y %SCR%\msys\etc\skel\jtsdk.inputrc %BASED%\msys\etc\skel\.inputrc >nul
COPY /Y %SCR%\msys\etc\skel\jtsdk.minttyrc %BASED%\msys\etc\skel\.minttyrc >nul
GOTO UPDATE_NSIS

REM -- UPDATE NSIS -------------------------------------------------------------
:UPDATE_NSIS
IF NOT EXIST %BASED%\nsis\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\nsis ^), skipping update
GOTO UPDATE_PYTHON33
)
ECHO ..NSIS - no updates needed
GOTO UPDATE_PYTHON33

REM -- UPDATE PYTHON33 ---------------------------------------------------------
:UPDATE_PYTHON33
IF NOT EXIST %BASED%\Python33\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\Python33 ^), skipping update
GOTO UPDATE_QT5
)
ECHO ..PYTHON33 - no updates needed
GOTO UPDATE_QT5

REM -- UPDATE QT5 --------------------------------------------------------------
:UPDATE_QT5
IF NOT EXIST %BASED%\qt5\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\qt5 ^), skipping update
GOTO UPDATE_SVN
)
ECHO ..QT5 - no updates needed
GOTO UPDATE_SVN

REM -- UPDATE SUBVERSION -------------------------------------------------------
:UPDATE_SVN
IF NOT EXIST %BASED%\subversion\NUL (
ECHO ..Did Not Find ^( C:\JTSDK\subversion ^), skipping update
GOTO EOF
)
ECHO ..SUBVERSION - no updates needed
GOTO EOF

:FINISHED
ECHO.
ECHO Finished JTSDK-%VERSION% Post Install Updates
ECHO.
pause
GOTO EOF

:: SVN CO or UPDATE ERROR
:SVN_ERROR
ECHO
ECHO ----------------------------------
ECHO       SUBVERSION ERROR
ECHO ----------------------------------
ECHO.
ECHO  An SVN ERROR Occured.
ECHO.
ECHO  Check The Scrren Errors and 
ECHO  Re-Run postinstall-update
ECHO  Manually.
ECHO.
ECHO  Before Re-Running, try using:
ECHO.
ECHO  svn clean
ECHO.
ECHO  From  ^( C:\JTSDK ^) directory
ECHO.
PAUSE
GOTO EOF

:EOF
ENDLOCAL
EXIT /B 0