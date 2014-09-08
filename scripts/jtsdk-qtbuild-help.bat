@ECHO OFF
SETLOCAL
REM -- JTSDK-QT BUILD HELP
REM -- Part of the JTSDK Project
SET LANG=en_US
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
ECHO  package ........ Build Win32 Installer
ECHO.
ECHO NOTE: MAP65 ^& WSPR-X Package Builds are ^( Experimental ^)
ECHO.
ECHO EXAMPLE ^( WSJT-X Release ^):
ECHO -----------------------------------------------------------------
ECHO Configure Build Tree:
ECHO  Type:  build wsjtx rconfig
ECHO.
ECHO Build Install Target:
ECHO  Type:  build wsjtx rinstall
ECHO.
ECHO Build Win32 Installer
ECHO  Type:  build wsjtx package
ECHO.
ECHO NOTE: Building the ^( package ^) target will automatically
ECHO       build everthing needed to produce the Win32 Installer.
ECHO       Likewise, building ^( rinstall or dinstall ^) will build
ECHO       everything needed to produce a fully functional app to
ECHO       run from a local directory.
ECHO.

ENDLOCAL
EXIT /B 0