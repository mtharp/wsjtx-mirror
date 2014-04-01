@ECHO OFF
REM **************************************************************************
REM * Master copies of these scripts are kept here.  This script distributes *
REM * them to where they are actually used.                                  *
REM **************************************************************************

REM -- TO-DO
::     * Add checkout script to each SDK on next release
::     * Add JSDK-* Core Application Update Method
COLOR 0F
CLS
ECHO ^******************************
ECHO      MASTER SCRIPT UPDATE
ECHO ^******************************
ECHO.
SETLOCAL
SET BASED=c:\
SET SCRIPTS=c:\JTSDK-DOC\doc\dev-guide\scripts\
REM -- JTSDK-QT SCRIPTS
IF EXIST %BASED%JTSDK-QT (
ECHO Updating JTSDK-QT Scripts
copy /Y %SCRIPTS%jtsdk-cmake.bat %BASED%JTSDK-QT
copy /Y %SCRIPTS%jtsdk-qtenv.bat %BASED%JTSDK-QT
copy /Y %SCRIPTS%jtsdk-toolchain.cmake %BASED%JTSDK-QT
copy /Y %SCRIPTS%jtsdk-toolchain1.cmake %BASED%JTSDK-QT
copy /Y %SCRIPTS%jtsdk-cmakeco.bat %BASED%JTSDK-QT
ECHO.
)

REM -- JTSDK-PY SCRIPTS
IF EXIST %BASED%JTSDK-PY (
ECHO Updating JTSDK-PY Scripts
copy /Y %SCRIPTS%jtsdk-pyenv.bat %BASED%JTSDK-PY
copy /Y %SCRIPTS%jtsdk-python.bat %BASED%JTSDK-PY
copy /Y %SCRIPTS%jtsdk-pyco.bat %BASED%JTSDK-PY
ECHO.
)

REM -- JYSDK-DOC SCRIPTS
IF EXIST %BASED%JTSDK-DOC (
ECHO Updating JTSDK-DOC Scripts
copy /Y %SCRIPTS%jtsdk-docenv.bat %BASED%JTSDK-DOC
ECHO.
)
GOTO EOF

:EOF
COLOR
pause
ENDLOCAL
EXIT /B 0
