@ECHO OFF
set OLDPATH=%PATH%
set PATH=.;.\bin
.\bin\wsjt 
set PATH=%OLDPATH%
