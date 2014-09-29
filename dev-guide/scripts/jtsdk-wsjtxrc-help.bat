@ECHO OFF
SETLOCAL
REM -- WSJT-X Release Candidate Help File
REM -- Part of the JTSDK Project
SET LANG=en_US
CLS
ECHO.                               
ECHO -----------------------------------------------------------------
ECHO CONFIGURE ^& BUILD WSJT-X Release Candidate
ECHO -----------------------------------------------------------------
ECHO.
ECHO USAGE:  wsjtxrc ^(type^)
ECHO.
ECHO  Release Types .. rconfig rinstall package
ECHO    rconfig ...... Configure Release Build Tree
ECHO    rinstall ..... Build Release Install Target
ECHO    package ...... Build Win32 Installer
ECHO.
ECHO EXAMPLES
ECHO ----------------------------------------------------------
ECHO Configure Build Tree:
ECHO   Type: wsjtx rconfig
ECHO.
ECHO Build Install Target:
ECHO   Type:  wsjtxrc rinstall
ECHO.
ECHO Build NSIS Installer
ECHO   Type:  wsjtxrc package
ECHO.

ENDLOCAL
EXIT /B 0