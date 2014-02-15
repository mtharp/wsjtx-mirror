@ECHO OFF
REM -- WSJT-X Windows Build Script Using CMake
REM -- Part of the WSJT Documentation Project
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
SET BASED=C:\wsjt-env
SET SRCD=C:\wsjt-env\src
SET BUILDD=C:\wsjt-env\wsjtx-build
SET DLLD=C:\wsjt-env\Qt5\5.2.1\mingw48_32\bin
SET LIBD=C:\wsjt-env\Qt5\Tools\mingw48_32\bin
SET INSTALLD=C:\wsjt-env\wsjtx-install
SET TCHAIN=C:\wsjt-env\wsjtx-toolchain.cmake
SET CHECKOUT=svn co svn://svn.berlios.de/wsjt/branches/wsjtx
SET CPTXT=*.txt *.dat *.conf
SET CPQT=Qt5Core.dll Qt5Gui.dll Qt5Multimedia.dll Qt5Network.dll Qt5Widgets.dll
SET CPICU=icu*.dll
SET CPLIB=libgcc_s_dw2-1.dll libgfortran-3.dll libstdc++-6.dll libquadmath-0.dll libwinpthread-1.dll
SET RBCPY=ROBOCOPY /NS /NC /NFL /NDL /NP

REM -- Start CMake Build
IF /I [%1]==[-d] (SET OPTION=Debug) ELSE (SET OPTION=Release)
CD %SRCD%
%CHECKOUT%
CD %BUILDD%\%OPTION%

REM -- CMake && Make Install
cmake -G "MinGW Makefiles" -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/wsjtx
mingw32-make install

REM -- Post Build File Copy
CD %BASED%
%RBCPY% %SRCD%\wsjtx %INSTALLD%\%OPTION%\bin %CPTXT% /XF CMake* *.cmake
%RBCPY% %DLLD% %INSTALLD%\%OPTION%\bin %CPICU% %CPQT%
%RBCPY% %LIBD% %INSTALLD%\%OPTION%\bin %CPLIB%
GOTO EOF
:EOF
ENDLOCAL
EXIT /B 0