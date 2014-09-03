@ECHO OFF
SETLOCAL
REM -- JTSDK-QT BUILD HELP
REM -- Part of the JTSDK Project
CLS
ECHO.                               
ECHO -----------------------------------------------------------------
ECHO CONFIGURE ^& BUILD APPS: ^( WSJTX WSPRX MAP65 ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO USAGE:  build ^(app_name^) ^(type^)
ECHO.
ECHO  App Names ...... wsjtx wsprx map65
ECHO  Release Types .. rconfig rinstall package
ECHO  Debug Types .... dconfig dinstall
ECHO.
ECHO DEFINITIONS:
ECHO -----------------------------------------------------------------
ECHO  rconfig ........ Configure Release Build Tree
ECHO  rinstall ....... Build Release Install Target
ECHO  dconfig ........ Configure Debug Build Tree
ECHO  dinstall ....... Build Debug Install Target
ECHO  package ........ Build NSIS Installer ^( WSJT-X Only ^)
ECHO.
ECHO EXAMPLE ^( WSJT-X Release ^):
ECHO -----------------------------------------------------------------
ECHO Configure Build Tree:
ECHO  Type:  build wsjtx rconfig
ECHO.
ECHO Build Install Target:
ECHO  Type:  build wsjtx rinstall
ECHO.
ECHO Build NSIS Installer
ECHO  Type:  build wsjtx package
ECHO.
ECHO NOTE: Building the ^( package ^) target will automatically
ECHO       build everthing needed to produce the NSIS Installer.
ECHO       Likewise, building ^( rinstall ^) will build everything
ECHO       needed to produce a fully functional app. 
ECHO.

ENDLOCAL
EXIT /B 0