@ECHO OFF
SETLOCAL
REM -- JTSDK-QT BUILD HELP
REM -- Part of the JTSDK Project

REM - UNDER DEVELOPMENT. This script is not included in
REM   install-scripts yet.

SET DOCURL=https://svn.code.sf.net/p/wsjt/wsjt/branches/doc
SET SCRIPTURL=https://svn.code.sf.net/p/wsjt/wsjt/branches/doc/dev-guide/scripts
CLS
ECHO.                               
ECHO -----------------------------------------------------------------
ECHO JTSDK Critical Script Version Information
ECHO -----------------------------------------------------------------

REM GET INFO FROM SVN, this takes a while
ECHO.
ECHO JTSDK-QT
ECHO ------------------------
install-scripts.bat
jtsdk-cmake.bat
jtsdk-makeco.bat
jtsdk-qtenv.bat
jtsdk-qtinfo.bat
jtsdk-toolchain.cmake
jtsdk-toolchain1.cmake

ECHO JTSDK-PY
ECHO ------------------------
jtsdk-pyco.bat
jtsdk-pyenv.bat
jtsdk-python.bat
python33.dll


ECHO JTSDK-DOC
ECHO ------------------------
jtsdk-docenv.bat
doc-env.bat
update1.bat
update2.bat

PAUSE

ENDLOCAL
EXIT /B 0