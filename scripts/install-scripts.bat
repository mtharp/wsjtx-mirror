@ECHO OFF
REM **************************************************************************
REM * Master copies of these scripts are kept here.  This script distributes *
REM * them to where they are actually used.                                  *
REM **************************************************************************

REM -- TO-DO
::     * Add checkout script to each SDK on next release
::     * Add JTSDK-* Core Application Update Method
COLOR 0E
CLS
ECHO ^******************************
ECHO      MASTER SCRIPT UPDATE
ECHO ^******************************
ECHO.
SETLOCAL
SET BASED=c:\
SET SCRIPTS=c:\JTSDK-DOC\doc\dev-guide\scripts\

REM -- Skip JTSDK-QT update if not located in C:\JTSDK-QT
ECHO UPDATE JTSDK-QT
IF NOT EXIST %BASED%JTSDK-QT (
ECHO .. Did not find ^( C:\JTSDK-QT ^), skipping update
GOTO JTSDKPY
)

REM -- JTSDK-QT SCRIPTS
IF EXIST %BASED%JTSDK-QT (
ECHO .. Updating Scripts
copy /Y %SCRIPTS%jtsdk-cmake.bat %BASED%JTSDK-QT >nul
copy /Y %SCRIPTS%jtsdk-qtenv.bat %BASED%JTSDK-QT >nul
copy /Y %SCRIPTS%jtsdk-toolchain.cmake %BASED%JTSDK-QT  >nul
copy /Y %SCRIPTS%jtsdk-toolchain1.cmake %BASED%JTSDK-QT >nul
copy /Y %SCRIPTS%jtsdk-cmakeco.bat %BASED%JTSDK-QT >nul
copy /Y %SCRIPTS%jtsdk-qtinfo.bat %BASED%JTSDK-QT\tools\scripts >nul
copy /Y %SCRIPTS%jtsdk-qtbuild-help.bat %BASED%JTSDK-QT\tools\scripts >nul
)
GOTO PKGCONFIG

REM -- Conditional Install for Pkg-Config-lite v0.28
:PKGCONFIG
ECHO .. Checking For Pkg-Config Installation
IF NOT EXIST %BASED%JTSDK-QT\tools\pkg-config.exe (
cd C:\JTSDK-DOC\doc\dev-guide\scripts
ECHO .. Not Found, Installing Pkg-Config v0.28
cp pkg-config.7z C:\JTSDK-QT\tools
cd C:\JTSDK-QT\tools
7z x pkg-config.7z > nul
ECHO .. Cleaning Up After Pkg-Config Install
rm pkg-config.7z
ECHO .. Finished Pkg-Config Installation
cd C:\JTSDK-DOC\doc
)
GOTO NSIS

REM -- Conditional Install for NSIS Installer Package
:NSIS
ECHO .. Checking For NSIS Package Installation
IF NOT EXIST C:\JTSDK-QT\NSIS\makensis.exe (
cd C:\JTSDK-DOC\doc\dev-guide\scripts
ECHO .. Not Found, Installing NSIS v0.03a2
cp NSIS.7z C:\JTSDK-QT\
cd C:\JTSDK-QT
7z x NSIS.7z > nul
ECHO .. Cleaning Up After Install
rm NSIS.7z > nul
cd C:\JTSDK-DOC\doc
ECHO .. Finished NSIS Installation
)
ECHO Done
GOTO JTSDKPY

REM -- JTSDK-PY SCRIPTS
:JTSDKPY
ECHO.
ECHO UPDATE JTSDK-PY

REM -- Skip JTSDK-PY Update if not located in C:\JTSDK-PY
IF NOT EXIST %BASED%JTSDK-PY (
ECHO .. Did not find ^( C:\JTSDK-PY ^), skipping update
GOTO JTSDKDOC
)

IF EXIST %BASED%JTSDK-PY (
ECHO .. Updating Scripts
copy /Y %SCRIPTS%jtsdk-pyenv.bat %BASED%JTSDK-PY > nul
copy /Y %SCRIPTS%jtsdk-python.bat %BASED%JTSDK-PY > nul
copy /Y %SCRIPTS%jtsdk-pyco.bat %BASED%JTSDK-PY > nul
copy /Y %SCRIPTS%python33.dll %BASED%JTSDK-PY\Python33\DLLs > nul
ECHO Done
)
GOTO JTSDKDOC

REM -- Skip JTSDK-DOC update if not located in C:\JTSDK-DOC
IF NOT EXIST %BASED%JTSDK-PY (
ECHO .. Did not find ^( C:\JTSDK-DOC ^), skipping update
GOTO EOF
)

REM -- JYSDK-DOC SCRIPTS
:JTSDKDOC
IF EXIST %BASED%JTSDK-DOC (
ECHO.
ECHO UPDATE JTSDK-DOC
ECHO .. Updating Scripts
copy /Y %SCRIPTS%jtsdk-docenv.bat %BASED%JTSDK-DOC > nul
ECHO Done
ECHO.
)
GOTO EOF

:EOF
ENDLOCAL
EXIT /B 0
