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
SET HAMLIBPC=C:\JTSDK-QT\hamlib3\mingw32\lib\pkgconfig\hamlib.pc

REM -- Skip JTSDK-QT update if not located in C:\JTSDK-QT
ECHO UPDATE JTSDK-QT
IF NOT EXIST %BASED%JTSDK-QT (
ECHO .. Did not find ^( C:\JTSDK-QT ^), skipping update
GOTO JTSDK_PY
)

REM -- Update JTSDK-QT Scripts
ECHO .. Updating Scripts
copy /Y %SCRIPTS%jtsdk-cmake.bat %BASED%JTSDK-QT >nul
copy /Y %SCRIPTS%jtsdk-qtenv.bat %BASED%JTSDK-QT >nul
copy /Y %SCRIPTS%jtsdk-toolchain.cmake %BASED%JTSDK-QT  >nul
copy /Y %SCRIPTS%jtsdk-toolchain1.cmake %BASED%JTSDK-QT >nul
copy /Y %SCRIPTS%jtsdk-cmakeco.bat %BASED%JTSDK-QT >nul
copy /Y %SCRIPTS%jtsdk-qtinfo.bat %BASED%JTSDK-QT\tools\scripts >nul
copy /Y %SCRIPTS%jtsdk-qtbuild-help.bat %BASED%JTSDK-QT\tools\scripts >nul
copy /Y %SCRIPTS%hamlib.pc %BASED%JTSDK-QT\hamlib3\mingw32\lib\pkgconfig >nul
GOTO PKG_CONFIG_INSTALL

REM -- Install Pkg-Config-lite v0.28
:PKG_CONFIG_INSTALL
ECHO .. Checking For Pkg-Config
IF NOT EXIST %BASED%JTSDK-QT\tools\pkg-config.exe (
ECHO .. Pkg-Config Was Not Found
ECHO .. Installing Pkg-Config v0.28
cd C:\JTSDK-DOC\doc\dev-guide\scripts
cp pkg-config.7z C:\JTSDK-QT\tools
cd C:\JTSDK-QT\tools
7z x pkg-config.7z > nul
ECHO .. Cleaning Up After Pkg-Config Install
rm pkg-config.7z
cd C:\JTSDK-DOC\doc
ECHO .. Finished Pkg-Config Installation
)
GOTO NSIS_INSTALL

REM -- Install NSIS Installer
:NSIS_INSTALL
ECHO .. Checking For NSIS
IF NOT EXIST C:\JTSDK-QT\NSIS\makensis.exe (
cd C:\JTSDK-DOC\doc\dev-guide\scripts
ECHO .. NSIS Was Not Found
ECHO .. Installing NSIS v0.03a2
cp NSIS.7z C:\JTSDK-QT\
cd C:\JTSDK-QT
7z x NSIS.7z > nul
rm NSIS.7z > nul
cd C:\JTSDK-DOC\doc
ECHO .. Finished NSIS Installation
)
GOTO INNO_QT

REM -- Install InnoSetup Installer
:INNO_QT
ECHO .. Checking For InnoSetup
IF NOT EXIST C:\JTSDK-QT\inno5\ISCC.exe (
ECHO .. InnoSetup Was Not Found
ECHO .. Installing InnoSetup 5.5.4a
cd C:\JTSDK-DOC\doc\dev-guide\scripts
cp inno5.7z  C:\JTSDK-QT\
cd C:\JTSDK-QT
7z x inno5.7z > nul
rm inno5.7z > nul
cd C:\JTSDK-DOC\doc
ECHO .. Finished InnoSetup Installation
)
GOTO HAMLIB3_UPDATE

REM -- Install Updated Version of Hamlib3 from ( G4WJS )
:HAMLIB3_UPDATE
ECHO .. Checking Hamlib3
IF NOT EXIST C:\JTSDK-QT\hamlib3\april-2014.txt (
ECHO .. Latest Version Was Not Found
ECHO .. Installing Hamlib3 April-2014 Build
cd C:\JTSDK-DOC\doc\dev-guide\scripts
cp hamlib3.7z C:\JTSDK-QT\
cd C:\JTSDK-QT
rm -rf C:\JTSDK-QT\hamlib3
7z x hamlib3.7z > nul
rm hamlib3.7z > nul
copy /Y %SCRIPTS%hamlib.pc %BASED%JTSDK-QT\hamlib3\mingw32\lib\pkgconfig >nul
cd C:\JTSDK-DOC\doc
ECHO .. Finished Hamlib3 Update
)
ECHO .. Done
GOTO JTSDK_PY

REM ------------------------------------------------------------------
REM -- JTSDK-PY SCRIPTS
REM ------------------------------------------------------------------
:JTSDK_PY
ECHO.
ECHO UPDATE JTSDK-PY

REM -- Skip JTSDK-PY Update if not located in C:\JTSDK-PY
IF NOT EXIST %BASED%JTSDK-PY (
ECHO .. Did not find ^( C:\JTSDK-PY ^), skipping update
GOTO JTSDK_DOC
)

REM -- Update JTSDK-PY Scripts
ECHO .. Updating Scripts
copy /Y %SCRIPTS%jtsdk-pyenv.bat %BASED%JTSDK-PY > nul
copy /Y %SCRIPTS%jtsdk-python.bat %BASED%JTSDK-PY > nul
copy /Y %SCRIPTS%jtsdk-pyco.bat %BASED%JTSDK-PY > nul
copy /Y %SCRIPTS%jtsdk-pyinfo.bat %BASED%JTSDK-PY\tools\scripts > nul
copy /Y %SCRIPTS%python33.dll %BASED%JTSDK-PY\Python33\DLLs > nul
copy /Y %SCRIPTS%msvcr100.dll %BASED%JTSDK-PY\Python33\DLLs > nul
GOTO INNO_PY

REM -- Install NSIS Installer
:INNO_PY
ECHO .. Checking For InnoSetup
IF NOT EXIST C:\JTSDK-PY\inno5\ISCC.exe (
ECHO .. InnoSetup Was Not Found
ECHO .. Installing InnoSetup 5.5.4a
cd C:\JTSDK-DOC\doc\dev-guide\scripts
cp inno5.7z  C:\JTSDK-PY\
cd C:\JTSDK-PY
7z x inno5.7z > nul
rm inno5.7z > nul
cd C:\JTSDK-DOC\doc
ECHO .. Finished InnoSetp Installation
)
ECHO .. Done
GOTO JTSDK_DOC

REM ------------------------------------------------------------------
REM -- Skip JTSDK-DOC update if not located in C:\JTSDK-DOC
REM ------------------------------------------------------------------
:JTSDK_DOC
ECHO.
ECHO UPDATE JTSDK-DOC
IF NOT EXIST %BASED%JTSDK-DOC (
ECHO .. Did not find ^( C:\JTSDK-DOC ^), skipping update
GOTO EOF
)

REM -- Update JYSDK-DOC Scripts
ECHO .. Updating Scripts
copy /Y %SCRIPTS%jtsdk-docenv.bat %BASED%JTSDK-DOC > nul
GOTO INNO_DOC

REM -- Install NSIS Installer for DOCS (Future use)
:INNO_DOC
ECHO .. Checking For InnoSetup
IF NOT EXIST C:\JTSDK-DOC\inno5\ISCC.exe (
ECHO .. InnoSetup Was Not Found
ECHO .. Installing InnoSetup 5.5.4a
cd C:\JTSDK-DOC\doc\dev-guide\scripts
cp inno5.7z  C:\JTSDK-DOC\
cd C:\JTSDK-DOC
7z x inno5.7z > nul
rm inno5.7z > nul
cd C:\JTSDK-DOC\doc
ECHO .. Finished NSIS Installation
)
ECHO .. Done
GOTO EOF

:EOF
ENDLOCAL
EXIT /B 0
