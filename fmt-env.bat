@ECHO OFF
REM -- Fmtest and WSPR0 Environment
REM    This file is used with the WSPR InnoSetup Win32 Installer
REM    It sets paths to the required DLL's based on the
REM    application install directory. It Does *not* permanently 
REM    alter System or User %PATH%. Paths are re-set by closing
REM    the CMD window.
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
COLOR 0B
TITLE FMTEST Environment

REM -- SETUP PATHS
SET PATH=%PATH%;%~dp0\bin
CLS
ECHO -----------------------------------------------------------------
ECHO  Welcome to WSJT's FMTEST / WSPR0 Tool Suite
ECHO -----------------------------------------------------------------
ECHO.
ECHO  Available Apps: fmtest fmtave fmeasure fcal wspr0
ECHO.
ECHO  For Help, type: ^( app-name ^) then ENTER
ECHO.
IF NOT EXIST "%~dp0\WSPR.INI" (
ECHO.
ECHO  CAUTION: Before running Fmtest or Gocal.bat, you must first
ECHO  run WSPR to generate an WSPR.INI file.
ECHO.
)

:: OPEN CMD WINDOW
%WINDIR%\System32\cmd.exe /A /Q /K