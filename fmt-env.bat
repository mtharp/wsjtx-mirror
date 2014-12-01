::-----------------------------------------------------------------------------::
:: Name .........: fmt-env.bat
:: Project ......: Part of the WSPR Project
:: Description ..: Maintenance script for updated & upgrades or general use
:: Project URL ..: http://sourceforge.net/projects/jtsdk
:: Usage ........: Run this file directly, or from the Windows Start Menu
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2001-2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: fmt-env.bat is free software: you can redistribute it and/or modify it under
:: the terms of the GNU General Public License as published by the Free Software
:: Foundation either version 3 of the License, or (at your option) any later
:: version. 
::
:: fmt-ent.bat is distributed in the hope that it will be useful, but
:: WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
:: or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
:: more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

REM -- This file sets the paths for ( fmtest, gocal.bat, wspr0 and wsprcode ).
REM    It does *not* permanently alter System or User %PATH%. Paths are re-set
REM    by closing the CMD window.

@ECHO OFF
SETLOCAL
COLOR 0B
TITLE FMTEST - WSPR Code Environment

REM -- SETUP PATHS
PATH=.;.\bin
CLS
ECHO --------------------------------------------------------------
ECHO  Welcome to WSJT's FMTEST / WSPR0 Tool Suite
ECHO --------------------------------------------------------------
ECHO.
ECHO  Applications ....: fmtest fmtave fmeasure fcal wspr0 wsprcode
ECHO  For Help, type ..: ^( app-name ^) then ENTER
ECHO.
IF NOT EXIST "%~dp0\WSPR.INI" (
ECHO.
ECHO  WSPR.INI Required
ECHO  -----------------
ECHO  Before running ^( fmtest or gocal.bat ^), you must first
ECHO  run WSPR to generate an WSPR.INI file.
ECHO.
ECHO  Make sure to save your latest changes by going to: 
ECHO  File, Save user parameters
ECHO.
)

:: OPEN CMD WINDOW
%COMSPEC% /A /Q /K