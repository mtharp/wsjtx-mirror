::-----------------------------------------------------------------------------::
:: Name .........: maint.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Maintenance script for updated & upgrades or general use
:: Project URL ..: http://sourceforge.net/projects/jtsdk
:: Usage ........: Run this file directly, or from the Windows Start Menu
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: maint.bat is free software: you can redistribute it and/or
:: modify it under the terms of the GNU General Public License as published by
:: the Free Software Foundation either version 3 of the License, or (at your
:: option) any later version. 
::
:: maint.bat is distributed in the hope that it will be useful, but
:: WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
:: or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
:: more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

@ECHO OFF
COLOR 0E
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
TITLE JTSDK General Maintenance And Upgrade
ECHO.
SET VER=2.0.0
SET LANG=en_US
SET BASED=C:\JTSDK
SET SVND=%BASED%\subversion\bin
SET TOOLS=%BASED%\tools\bin
SET URL1="http://svn.code.sf.net/p/jtsdk/jtsdk/trunk/installers/win32/postinstall.bat"
SET PATH=%BASED%;%SVND%;%TOOLS%;%WINDIR%\System32

:: Power-User Commands, add as many as you like
DOSKEY clear=cls
DOSKEY ls=dir
DOSKEY ss="svn.exe" $* status
DOSKEY sv="svn.exe" $* status ^|grep "?"
DOSKEY sa="svn.exe" $* status ^|grep "A"
DOSKEY sm="svn.exe" $* status ^|grep "M"
DOSKEY sd="svn.exe" $* status ^|grep "D"
DOSKEY log="svn.exe" log -l $*
DOSKEY logv="svn.exe" log -v -l $*

:: UPDATE & UPGRADE COMMANDS
DOSKEY update="%SVND%\svn.exe" $* export --force %URL1%
DOSKEY upgrade="postinstall.bat" $* upgrade

:: Start Main Script
CD /D %BASED%
CLS
ECHO -------------------------------------------------
ECHO  General Maintenance & Upgrades
ECHO -------------------------------------------------
ECHO.
ECHO  ^* Provides Access To: Subversion an Gnu Tools
ECHO  ^* Upgrades JTSDK Main Scripts and Packages when needed
ECHO.
ECHO  TO UPDATE and UPGRADE
ECHO   Type, .......: update
ECHO   Then Type, ..: upgrade
ECHO.
ECHO  GENERAL: MAINTENANCE
ECHO   With this env, you have access to all the Gnu
ECHO   Tools plus subversion. It can be used to perform
ECHO   most any task needed by the SDK. There are no
ECHO   Tool-Chains or Frameworks in the ^*PATH^*
ECHO.

%COMSPEC% /A /Q /K