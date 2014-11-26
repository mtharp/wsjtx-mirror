::-----------------------------------------------------------------------------::
:: Name .........: postinstall-update.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Post install update for various JTSDK elements
:: Project URL ..: http://sourceforge.net/projects/wsjt/ 
:: Usage ........: This file is run from JTSDK installer script
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: postinstall-update.bat is free software: you can redistribute it and/or
:: modify it under the terms of the GNU General Public License as published by
:: the Free Software Foundation either version 3 of the License, or (at your
:: option) any later version. 
::
:: postinstall-update.bat is distributed in the hope that it will be useful, but
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
SET VERSION=2.0.0
SET BASED=C:\JTSDK
SET SCR=%BASED%\scripts
SET SVND=%BASED%\subversion\bin
SET PATH=%BASED%;%SVND%;%SCR%;%WINDIR%\System32

:: Make sure we can find C:\JTSDK
IF NOT EXIST %BASED%\NUL (
ECHO ^*** JTSDK_ERROR1 ^***
GOTO JTSDK_ERROR1
)

CD /D %BASED%
CLS
ECHO ----------------------------------
ECHO  JTSDK POST INSTALL UPDTAE
ECHO ----------------------------------
ECHO.

REM ----------------------------------------------------------------------------
REM  CHECKOUT or UPDATE FROM SVN
REM ----------------------------------------------------------------------------
IF NOT EXIST %BASED%\.svn\NUL (
ECHO ..Performaing Initial Checkout from WSJT
start /wait svn co https://svn.code.sf.net/p/wsjt/wsjt/branches/jtsdk/win32 .
IF ERRORLEVEL 1 (
ECHO ^*** SVN_ERROR1 ^***
GOTO SVN_ERROR1
)

REM ----------------------------------------------------------------------------
REM  SVN UPDATE ASK
REM ----------------------------------------------------------------------------
:ASK_SVN
ECHO Update JTSDK from SVN? ^( y/n ^)
SET ANSWER=
ECHO.
SET /P ANSWER=Type Response: %=%
If /I "%ANSWER%"=="N" GOTO START_UPDATE
If /I "%ANSWER%"=="Y" (
GOTO SVN_UPDATE
) ELSE (
ECHO.
ECHO Please Answer With: ^( Y or N ^)
GOTO ASK_SVN
)

:SVN_UPDATE
ECHO.
ECHO UPDATING ^( JTSDK-%VERSION% ^ )
CD /D %BASED%
start /wait svn cleanup
start /wait svn update
IF ERRORLEVEL 1 GOTO SVN_ERROR1
GOTO UPDATE_CMAKE

:: START PACKAGE UPDATE CHECKS
:START_UPDATE

REM ----------------------------------------------------------------------------
REM  CMAKE UPDTAE
REM ----------------------------------------------------------------------------
:UPDATE_CMAKE
ECHO ^** CMAKE ^**
ECHO   ..No updates needed
ECHO.
GOTO UPDATE_CYG32

REM ----------------------------------------------------------------------------
REM  INSTALL or UPDATE CYGWIN
REM ----------------------------------------------------------------------------
:UPDATE_CYG32
CD /D %SCR%\cyg32
ECHO ^** CYG32 ^**
ECHO   ..Running Cygwin Setup To Check Installation

:: Look for the JTSDK installer script
IF NOT EXIST %SCR%\cyg32\jtsdk-cyg32-install.bat\NUL (
SET ERRORLEVEL=Could Not Find JTSDK CYG32 Installer Script
GOTO CYG32_ERROR1
)
ECHO ..Found Installer Script: jtsdk-cyg32-install.bat

:: Look for Cygwin Installer .EXE
IF NOT EXIST %SCR%\cyg32\cygwin-setup.x86.exe\NUL (
SET ERRORLEVEL=Could Not Find Cygwin Installer
GOTO CYG32_ERROR1
)
ECHO ..Found Cygwin Setup Executable: cygwin-setup-x86.exe

:: Look for Cygwin Installer .EXE
IF EXIST %BASED%\cyg32\Cygwin.bat\NUL (
ECHO ..Found previous CYG32 installation, running update
CD /D %SCR%\cyg32
CALL jtsdk-cyg32-install.bat >nul
GOTO UPDATE_CYG32_RC
)

:: Perform Full Install as Cygwin.bat was not found
ECHO ..Installaing ^( cyg32 ^)
CD /D %SCR%\cyg32
ECHO ..Performing New CYG32 installation
CALL jtsdk-cyg32-install.bat >nul
GOTO UPDATE_CYG_RC

:UPDATE_CYG_RC
REM -- Ensure we re-generate User File ( passwd ) and User Group ( group )
REM    By removing them after install, it forces a re-generation and thus,
REM    installing rc files located in /etc/skel which are configured
REM    for JTSDK use. They could be added to /etc/defaults which is a
REM    TO-DO item for JTSDK v2.1.0
ECHO ..Resetting Group and User Files
IF EXIST %BASED%\cyg32\etc\group\NUL ( DEL /F /Q %BASED%\cyg32\etc\group >nul )
IF EXIST %BASED%\cyg32\etc\passwd\NUL ( DEL /F /Q %BASED%\cyg32\etc\passwd >nul )

ECHO   ..Updating ETC and RC Files
:: SKEL DIRECTORY CHECK
IF NOT EXIST %BASED%\cyg32\etc\skel\NUL (
ECHO ..Added Directory: %BASED%\cyg32\etc\skel
MKDIR %BASED%\cyg32\etc\skel 2> NUL
)
ECHO ..Updating ETC and RC Files

:: Main /etc files
COPY /Y %SCR%\cyg32\etc\jtsdk.fstab %BASED%\cyg32\etc\fstab >nul
COPY /Y %SCR%\cyg32\etc\jtsdk.profile %BASED%\cyg32\etc\profile >nul

:: /etc/skel files
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.bashrc %BASED%\cyg32\etc\skel\.bashrc >nul
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.bash_aliases %BASED%\cyg32\etc\skel\.bash_aliases >nul
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.bash_profile %BASED%\cyg32\etc\skel\.bash_profile >nul
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.inputrc %BASED%\cyg32\etc\skel\.inputrc >nul
COPY /Y %SCR%\cyg32\etc\skel\jtsdk.minttyrc %BASED%\cyg32\etc\skel\.minttyrc >nul
ECHO.
GOTO UPDATE_FFTW3F

REM ----------------------------------------------------------------------------
REM  FFTW UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_FFTW3F
ECHO ^** FFTW ^**
ECHO   ..No updates needed
ECHO.
GOTO UPDATE_HAMLIB2

REM ----------------------------------------------------------------------------
REM  HAMLIB-2 UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_HAMLIB2
ECHO ^** HAMLIB2 ^**
ECHO   ..No updates needed
ECHO.
GOTO UPDATE_HAMLIB3

REM ----------------------------------------------------------------------------
REM  HAMLIB-3 UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_HAMLIB3
ECHO ^** HAMLIB3 ^**
ECHO   ..No updates needed
ECHO.
GOTO UPDATE_INNO5

REM ----------------------------------------------------------------------------
REM  INNO5 UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_INNO5
ECHO ^** INNO5 ^**
ECHO   ..No updates needed
ECHO.
GOTO UPDATE_MINGW32

REM ----------------------------------------------------------------------------
REM  MINGW32 UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_MINGW32
ECHO ^** MINGW32 ^**
ECHO   ..No updates needed
ECHO.
GOTO UPDATE_MSYS

REM ----------------------------------------------------------------------------
REM  MSYS UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_MSYS
ECHO ^** MSYS ^**
ECHO   ..Updating ETC and RC Files

:: SKEL DIRECTORY CHECK
IF NOT EXIST %BASED%\cyg32\etc\skel\NUL (
ECHO ..Added Directory: %BASED%\cyg32\etc\skel
MKDIR %BASED%\cyg32\etc\skel 2> NUL
)
ECHO ..Updating ETC and RC Files

:: Update /etc files
COPY /Y %SCR%\msys\etc\jtsdk.fstab %BASED%\msys\etc\skel\fstab >nul
COPY /Y %SCR%\msys\etc\jtsdk.profile %BASED%\msys\etc\skel\profile >nul

:: Update /etc/skel files
COPY /Y %SCR%\msys\etc\skel\jtsdk.bashrc %BASED%\msys\etc\skel\.bashrc >nul
COPY /Y %SCR%\msys\etc\skel\jtsdk.bash_aliases %BASED%\msys\etc\skel\.bash_aliases >nul
COPY /Y %SCR%\msys\etc\skel\jtsdk.bash_profile %BASED%\msys\etc\skel\.bash_profile >nul
COPY /Y %SCR%\msys\etc\skel\jtsdk.inputrc %BASED%\msys\etc\skel\.inputrc >nul
COPY /Y %SCR%\msys\etc\skel\jtsdk.minttyrc %BASED%\msys\etc\skel\.minttyrc >nul
GOTO UPDATE_NSIS

REM ----------------------------------------------------------------------------
REM  NSIS UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_NSIS
ECHO ^** NSIS ^**
ECHO   ..No updates needed
ECHO.
GOTO UPDATE_PYTHON33

REM ----------------------------------------------------------------------------
REM  PYTHON33 UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_PYTHON33
ECHO ^** PYTHON33 ^**
ECHO   ..No updates needed
ECHO.
GOTO UPDATE_QT5

REM ----------------------------------------------------------------------------
REM  QT5 UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_QT5
ECHO ^** QT5 ^**
ECHO   ..No updates needed
ECHO.
GOTO UPDATE_SVN

REM ----------------------------------------------------------------------------
REM  PYTHON33 UPDATE
REM ----------------------------------------------------------------------------
:UPDATE_SVN
ECHO ^** SUBVERSION ^**
ECHO   ..No updates needed
ECHO.
GOTO EOF

:FINISHED
ECHO.
ECHO Finished JTSDK-%VERSION% Post Install Updates
ECHO.
pause
GOTO EOF

:EOF
ENDLOCAL
EXIT /B 0

REM ----------------------------------------------------------------------------
REM  ERROR MESSAGES
REM ----------------------------------------------------------------------------

:: JTSDK MAIN DIRECTORY NOT FOUND
:JTSDK_ERROR1
ECHO.
ECHO ----------------------------------
ECHO    JTSDK DIRECTORY NOT FOUND
ECHO ----------------------------------
ECHO.
ECHO  Post Install was unable to find:
ECHO  %BASED%
ECHO.
PAUSE
ENDLOCAL
EXIT /B 1

:: SVN CO or UPDATE ERROR
:SVN_ERROR1
ECHO
ECHO ----------------------------------
ECHO        SUBVERSION ERROR
ECHO ----------------------------------
ECHO.
ECHO  Check The Scrren Errors and 
ECHO  Re-Run postinstall-update
ECHO  Manually.
ECHO.
ECHO  Before Re-Running:
ECHO   [1] Check Internet Connectivity
ECHO   [2] Run: svn cleanup
ECHO       from ^( C:\JTSDK ^) directory
ECHO.
PAUSE
ENDLOCAL
EXIT /B 1

:: COULD NOT FUIND JTSDK or CYG32 Installer
:CYG32_ERROR1
ECHO.
ECHO ----------------------------------
ECHO  CYG32 INSTALL SCRIPTS NOT FOUND
ECHO ----------------------------------
ECHO.
ECHO Post install as unable to find
ECHO the requored crpts to install or
ECHO update CYG32.
ECHO.
ECHO Possible Solutions:
ECHO  [1] Ensure you have a proper
ECHO      checkout from SVN
ECHO  [2] Check JTSDK installation for
ECHO      install errors
ECHO.
PAUSE
ENDLOCAL
EXIT /B 1