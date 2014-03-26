REM **************************************************************************
REM * Master copies of these scripts are kept here.  This script distributes *
REM * them to where they are actualkly used.                                 *
REM **************************************************************************

SET BASED=c:\
copy /Y jtsdk-cmake.bat %BASED%JTSDK-QT
copy /Y jtsdk-docenv.bat %BASED%JTSDK-DOC
copy /Y jtsdk-pyenv.bat %BASED%JTSDK-PY
copy /Y jtsdk-python.bat %BASED%JTSDK-PY
copy /Y jtsdk-qtenv.bat %BASED%JTSDK-QT
copy /Y jtsdk-toolchain.cmake %BASED%JTSDK-QT
