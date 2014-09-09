@ECHO OFF
REM - Batch file to run gocat.bat for Fmtest
SET PATH=%PATH%;%~dp0\bin
IF NOT EXIST "%~dp0\WSPR.INI" ( GOTO NEED_INI )

REM -- Only edit items "between" < BEGIN .. and .. END >

:: BEGIN - Edit Station Information
fmtest   660 1 1500 100 30  WFAN
fmtest   880 1 1500 100 30  WCBS
fmtest  1210 1 1500 100 30  WPHT
fmtest  2500 1 1500 100 30  WWV
fmtest  3330 1 1500 100 30  CHU
fmtest  5000 1 1500 100 30  WWV
fmtest  7850 1 1500 100 30  CHU
fmtest 10000 1 1500 100 30  WWV
fmtest 14670 1 1500 100 30  CHU
fmtest 15000 1 1500 100 30  WWV
fmtest 20000 1 1500 100 30  WWV
:: END - Edit Station Information
GOTO EOF

:EOF
EXIT /B 0

:NEED_INI
CLS
ECHO -----------------------------------
ECHO       Missing WSPR.INI File
ECHO -----------------------------------
ECHO You must first run WSPR to generate
ECHO the an WSPR.INI file before running
ECHO gocal.bat
ECHO.
EXIT /B 1