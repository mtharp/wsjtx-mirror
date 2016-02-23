@ECHO OFF
REM -- wsjt batch file foe using AppDors
COLOR 0A
SET fsh=%LOCALAPPDATA%
SET PATH=%PATH%;%fsh%

IF NOT EXIST %LOCALAPPDATA%\WSJT\sql\NUL (
mkdir %LOCALAPPDATA%\WSJT\sql >NUL
)
xcopy .\sql\* %LOCALAPPDATA%\WSJT\sql /Y /Q >NUL

bin\wsjt.exe

EXIT /B 0
