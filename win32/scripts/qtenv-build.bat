::-----------------------------------------------------------------------------::
:: Name .........: qtenv-build.bat
:: Project ......: Part of the JTSDK v2.0.0 Project
:: Description ..: Build WSJT-X, WSPR and MAP65
:: Project URL ..: http://sourceforge.net/projects/wsjt/ 
:: Usage ........: This file is run from within qtenv.bat
::
:: Author .......: Greg, Beam, KI7MT, <ki7mt@yahoo.com>
:: Copyright ....: Copyright (C) 2014 Joe Taylor, K1JT
:: License ......: GPL-3
::
:: qtenv-build.bat is free software: you can redistribute it and/or modify it
:: under the terms of the GNU General Public License as published by the Free
:: Software Foundation either version 3 of the License, or (at your option) any
:: later version. 
::
:: qtenv-build.bat is distributed in the hope that it will be useful, but WITHOUT
:: ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
:: FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
:: details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-----------------------------------------------------------------------------::

:: ENVIRONMENT
@ECHO OFF
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
SET LANG=en_US
COLOR 0B

:: TEST DOUBLE CLICK, if YES, GOTO ERROR MESSAGE
FOR %%x IN (%cmdcmdline%) DO IF /I "%%~x"=="/c" SET GUI=1
IF DEFINED GUI CALL GOTO DOUBLE_CLICK_ERROR

:: PATH VARIABLES
SET BASED=C:\JTSDK
SET CMK=%BASED%\cmake\bin
SET BIN=%BASED%\tools\bin
SET HL2=%BASED%\hamlib\bin
SET HL3=%BASED%\hamlib3\bin
SET FFT=%BASED%\fftw3f
SET NSI=%BASED%\nsis
SET INO=%BASED%\inno5
SET GCCD=%BASED%\qt5\Tools\mingw48_32\bin
SET QT5D=%BASED%\qt5\5.2.1\mingw48_32\bin
SET QT5A=%BASED%\qt5\5.2.1\mingw48_32\plugins\accessible
SET QT5P=%BASED%\qt5\5.2.1\mingw48_32\plugins\platforms
SET SCR=%BASED%\scripts
SET SRCD=%BASED%\src
SET SVND=%BASED%\subversion\bin
SET LIBRARY_PATH=""
SET PATH=%BASED%;%CMK%;%BIN%;%HL3%;%HL2%;%FFT%;%GCCD%;%QT5D%;%QT5A%;%QT5P%;%NSI%;%INO%;%SRCD%;%SCR%;%SVND%;%WINDIR%;%WINDIR%\System32
CD /D %BASED%

REM ----------------------------------------------------------------------------
REM  START MAIN SCRIPT
REM ----------------------------------------------------------------------------

:: USER INPUT FILED 1 = %1
SET APP_NAME=
IF /I [%1]==[wsjtx] (SET APP_NAME=wsjtx
SET TCHAIN=%SCR%\wsjtx-toolchain.cmake
) ELSE IF /I [%1]==[wsprx] (SET APP_NAME=wsprx
SET TCHAIN=%SCR%\wsprx-toolchain.cmake
) ELSE IF /I [%1]==[map65] (SET APP_NAME=map65
SET TCHAIN=%SCR%\map65-toolchain.cmake
) ELSE ( GOTO BADNAME )

:: USER INPUT FIELD 2 == %2
:: SET RELEASE, DEBUG, and TARGET BASED ON USER INPUT
IF /I [%2]==[rconfig] (SET OPTION=Release
SET BTREE=true
) ELSE IF /I [%2]==[rinstall] (SET OPTION=Release
SET BINSTALL=true
) ELSE IF /I [%2]==[package] (SET OPTION=Release
SET BPKG=true
) ELSE IF /I [%2]==[dconfig] (SET OPTION=Debug
SET BTREE=true
) ELSE IF /I [%2]==[dinstall] (SET OPTION=Debug
SET BINSTALL=true
) ELSE ( GOTO BADTYPE )

:: VARIABLES USED IN PROCESS
SET JJ=%NUMBER_OF_PROCESSORS%
SET APP_DIR=%BASED%\%APP_NAME%
SET BUILDD=%BASED%\%APP_NAME%\build
SET INSTALLD=%BASED%\%APP_NAME%\install
SET PACKAGED=%BASED%\%APP_NAME%\package
SET WSPRX_ISS=%SRCD%\wsprx\wsprxb.iss
SET MAP65_ISS=%SRCD%\map65\map65b.iss

:: START MAIN BUILD
CLS
CD %BASED%
IF NOT EXIST %SRCD%\NUL mkdir %SRCD%
IF NOT EXIST %BUILDD%\%OPTION%\NUL mkdir %BUILDD%\%OPTION%
IF NOT EXIST %INSTALLD%\%OPTION%\NUL mkdir %INSTALLD%\%OPTION%
IF NOT EXIST %PACKAGED%\NUL mkdir %PACKAGED%
ECHO -------------------------------
ECHO %APP_NAME% CMake Build Script
ECHO -------------------------------
ECHO.
IF NOT EXIST %SRCD%\%APP_NAME%\.svn\NUL (
GOTO COMSG
) ELSE (
GOTO SVNASK
)

:: ASK USER UPDATE FROM SVN
:SVNASK
ECHO Update from SVN Before Building? ^( y/n ^)
SET ANSWER=
ECHO.
SET /P ANSWER=Type Response: %=%
If /I "%ANSWER%"=="N" GOTO BUILD
If /I "%ANSWER%"=="Y" (
GOTO SVNUP
) ELSE (
CLS
ECHO.
ECHO Please Answer With: ^( Y or N ^) & ECHO. & GOTO SVNASK
)

:: UPDATE IF USER SAID YES TO UPDATE
:SVNUP
ECHO.
ECHO UPDATING %SRCD%\%APP_NAME%
ECHO.
CD /D %SRCD%\%APP_NAME%
start /wait svn update
CD /D %BASED%
ECHO.

REM ----------------------------------------------------------------------------
REM CONFIGURE BUILD TREE ( BTREE )
REM ----------------------------------------------------------------------------
:BUILD
IF [%BTREE%]==[true] (
CD %BUILDD%\%OPTION%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Configuring %OPTION% Build Tree For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
IF /I [%1]==[wsjtx] (
cmake -G "MinGW Makefiles" -Wno-dev -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-D WSJT_INCLUDE_KVASD=ON ^
-D CMAKE_COLOR_MAKEFILE=OFF ^
-D CMAKE_BUILD_TYPE=%OPTION% ^
-D CMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
) ELSE (
cmake -G "MinGW Makefiles" -Wno-dev -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-D CMAKE_COLOR_MAKEFILE=OFF ^
-D CMAKE_BUILD_TYPE=%OPTION% ^
-D CMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
)
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished %OPTION% Build Tree Configuration for: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO BASE BUILD CONFIGURATION
ECHO   Package ............ %APP_NAME%
ECHO   Type ............... %OPTION%
ECHO   Build Directory .... %BUILDD%\%OPTION%
ECHO   Build Option List .. %BUILDD%\%OPTION%\CmakeCache.txt
ECHO   Target Directory ... %INSTALLD%\%OPTION%
ECHO.
ECHO LIST ALL BUILD CONFIG OPTIONS
ECHO   cat %BUILDD%\%OPTION%\CmakeCache.txt ^| less
ECHO   :: Arrow Up / Down to dcroll through the list
ECHO   :: Type ^(H^) for help with search commands
ECHO   :: Type ^(Ctrl+C then Q^) to exit
ECHO.
ECHO TO BUILD INSTALL TARGET
ECHO   cd %BUILDD%\%OPTION%
ECHO   cmake --build . --target install -- -j%JJ%
ECHO.
ECHO TO BUILD WINDOWS NSIS INSTALLER
ECHO   cd %BUILDD%\%OPTION%
ECHO   cmake --build . --target package -- -j%JJ%
ECHO.
GOTO EOF

REM ----------------------------------------------------------------------------
REM BUILD INSTALL TARGET ( BINSTALL )
REM ----------------------------------------------------------------------------
) ELSE IF [%BINSTALL%]==[true] (
CLS
CD %BUILDD%\%OPTION%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Building %OPTION% Install Target For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO .. Configuring %OPTION% Build Tree
ECHO.
IF /I [%1]==[wsjtx] (
cmake -G "MinGW Makefiles" -Wno-dev -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-D WSJT_INCLUDE_KVASD=ON ^
-D CMAKE_COLOR_MAKEFILE=OFF ^
-D CMAKE_BUILD_TYPE=%OPTION% ^
-D CMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
) ELSE (
cmake -G "MinGW Makefiles" -Wno-dev -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-D CMAKE_COLOR_MAKEFILE=OFF ^
-D CMAKE_BUILD_TYPE=%OPTION% ^
-D CMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%
)
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
ECHO.
ECHO .. Starting Install Target build for ^( %APP_NAME% ^)
ECHO.
cmake --build . --target install -- -j%JJ%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
GOTO POSTBUILD1

REM ----------------------------------------------------------------------------
REM  BUILD INSTALLER ( BPKG ) --
REM ----------------------------------------------------------------------------
) ELSE IF [%BPKG%]==[true] (
CLS
CD %BUILDD%\%OPTION%
ECHO.
ECHO -----------------------------------------------------------------
ECHO Building Installer Package For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
cmake -G "MinGW Makefiles" -Wno-dev -DCMAKE_TOOLCHAIN_FILE=%TCHAIN% ^
-D CMAKE_COLOR_MAKEFILE=OFF ^
-D CMAKE_BUILD_TYPE=%OPTION% ^
-D CMAKE_INSTALL_PREFIX=%INSTALLD%/%OPTION% %SRCD%/%APP_NAME%

IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
IF /I [%1]==[wsjtx] ( GOTO NSIS_PKG )
IF /I [%1]==[wsprx] ( GOTO INNO_PKG )
IF /I [%1]==[map65] ( GOTO INNO_PKG )

:: NSIS PACKAGE ( WSJT-X / Win32 ONLY)
:NSIS_PKG
cmake --build . --target package --clean-first -- -j%JJ%

IF NOT EXIST %BUILDD%\%OPTION%\*win32.exe ( GOTO NSIS_BUILD_ERROR )
mv -u %BUILDD%\%OPTION%\*win32.exe %PACKAGED%
GOTO FINISH_PKG

:: INNO PACKAGE ( WSPR-X and MAP65 )
:INNO_PKG
cmake --build . --target install -- -j%JJ%
IF ERRORLEVEL 1 ( GOTO CMAKE_ERROR )
ECHO -- Installing: Additional Support Files for ^( %APP_NAME% ^)

REM ----------------------------------------------------------------------------
REM -- MAP65 PACKAGE COPY ROUTINE
REM    Needs to be added to CMakeLists.txt
REM ----------------------------------------------------------------------------
:MAP65_PACKAGE_COPY
IF /I [%1]==[map65] (SET ISS=%MAP65_ISS%
IF NOT EXIST %INSTALLD%\%OPTION%\bin\save\Samples ( mkdir %INSTALLD%\%OPTION%\bin\save\Samples )
IF NOT EXIST %INSTALLD%\%OPTION%\bin\platforms ( mkdir %INSTALLD%\%OPTION%\bin\platforms )
:: QT5 Runtime
XCOPY /Y /R %QT5D%\icudt51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\icuin51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\icuuc51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Core.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Gui.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Network.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Widgets.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5P%\qwindows.dll %INSTALLD%\%OPTION%\bin\platforms >nul
:: GCC Runtime
XCOPY /Y /R %FFT%\libfftw3f-3.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libgfortran-3.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libquadmath-0.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R "%GCCD%\libstdc++-6.dll" %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libwinpthread-1.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libgcc_s_dw2-1.dll %INSTALLD%\%OPTION%\bin >nul
:: Add Misc files
XCOPY /Y /R %BUILDD%\%OPTION%\contrib\* %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\palir-02.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %BASED%\mingw32\bin\mingwm10.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\wsjt.ico %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\*.dat %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\LICENSE_WHEATLEY.txt %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %HL2%\rigctl.exe %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %HL2%\rigctld.exe %INSTALLD%\%OPTION%\bin >nul
)

REM ----------------------------------------------------------------------------
REM -- WSPR-X PACKAGE COPY ROUTINE
REM    Needs to be added to CMakeLists.txt
REM ----------------------------------------------------------------------------
:WSPRX_PACKAGE_COPY
IF /I [%1]==[wsprx] (SET ISS=%WSPRX_ISS%
IF NOT EXIST %INSTALLD%\%OPTION%\bin\save\Samples ( mkdir %INSTALLD%\%OPTION%\bin\save\Samples )
IF NOT EXIST %INSTALLD%\%OPTION%\bin\platforms ( mkdir %INSTALLD%\%OPTION%\bin\platforms )
:: QT5 Runtime
XCOPY /Y /R %QT5D%\icudt51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\icuin51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\icuuc51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Core.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Gui.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Network.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Widgets.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5P%\qwindows.dll %INSTALLD%\%OPTION%\bin\platforms >nul
:: GCC Runtime
XCOPY /Y /R %FFT%\libfftw3f-3.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libgfortran-3.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libquadmath-0.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R "%GCCD%\libstdc++-6.dll" %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libwinpthread-1.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libgcc_s_dw2-1.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %HL2%\rigctl.exe %INSTALLD%\%OPTION%\bin >nul
:: Add Misc files
XCOPY /Y /R %SRCD%\%APP_NAME%\palir-02.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\wsjt.ico %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\*.dat %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\LICENSE_WHEATLEY.txt %INSTALLD%\%OPTION%\bin >nul
)
REM -- Build The Installer
ECHO -- Building Win32 Installer ^( %APP_NAME%-Win32.exe ^)
ECHO.

%INO%\ISCC.exe /O"%PACKAGED%" /F"%APP_NAME%-Win32" /cc %ISS%
IF ERRORLEVEL 1 ( GOTO INNO_BUILD_ERROR )

REM -- We can use the installer name here, as we state the output
REM    name and location with /O and /F to ISCC. ISCC adds the .exe
IF NOT EXIST %PACKAGED%\%APP_NAME%-Win32.exe ( GOTO INNO_BUILD_ERROR )
GOTO FINISH_PKG

:: FINISHED PACKAGE MESSAGE
:FINISH_PKG
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished Installer Build For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
ECHO  Installer Location ..: %PACKAGED%
ECHO.
ECHO  To Install the package, browse to Installer Location, and
ECHO  run as you normally do to install Windows applications.
ECHO.
GOTO EOF
) ELSE ( GOTO UNSUPPORTED )

REM ----------------------------------------------------------------------------
REM  POST BUILD ACTIVITIES
REM ----------------------------------------------------------------------------

:: POST BUILD FOR WSJT-X
:POSTBUILD1
IF /I [%1]==[wsjtx] ( GOTO POSTBUILD2 ) ELSE ( GOTO CPFILES )

:: POST BUILD ( WSPR-X and MAP65 )
:POSTBUILD2
IF /I [%OPTION%]==[Debug] ( GOTO WSJTX_MAKEBAT ) ELSE ( GOTO FINISH )

:: COPY FILES ( WSPR-X and MAP65 )
:CPFILES
ECHO -- Installing: Aditional Support Files for ^( %APP_NAME% ^)

REM ----------------------------------------------------------------------------
REM -- MAP65 INSTALL COPY ROUTINE
REM    Needs to be added to CMakeLists.txt
REM ----------------------------------------------------------------------------

:MAP65_INSTALL_COPY
IF /I [%1]==[map65] (
IF NOT EXIST %INSTALLD%\%OPTION%\bin\save\Samples ( mkdir %INSTALLD%\%OPTION%\bin\save\Samples )
IF NOT EXIST %INSTALLD%\%OPTION%\bin\platforms ( mkdir %INSTALLD%\%OPTION%\bin\platforms )
:: QT5 Runtime
XCOPY /Y /R %QT5D%\icudt51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\icuin51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\icuuc51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Core.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Gui.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Network.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Widgets.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5P%\qwindows.dll %INSTALLD%\%OPTION%\bin\platforms >nul
:: GCC Runtime
XCOPY /Y /R %FFT%\libfftw3f-3.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libgfortran-3.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libquadmath-0.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R "%GCCD%\libstdc++-6.dll" %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libwinpthread-1.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libgcc_s_dw2-1.dll %INSTALLD%\%OPTION%\bin >nul
:: Add Misc files
XCOPY /Y /R %BUILDD%\%OPTION%\contrib\* %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\palir-02.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %BASED%\mingw32\bin\mingwm10.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\wsjt.ico %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\*.dat %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\LICENSE_WHEATLEY.txt %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %HL2%\rigctl.exe %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %HL2%\rigctld.exe %INSTALLD%\%OPTION%\bin >nul
)

REM ----------------------------------------------------------------------------
REM -- WSPR-X INSTALLL COPY ROUTINE
REM    Needs to be added to CMakeLists.txt
REM ----------------------------------------------------------------------------
:WSPRX_INSTALL_COPY
IF /I [%1]==[wsprx] (
IF NOT EXIST %INSTALLD%\%OPTION%\bin\save\Samples ( mkdir %INSTALLD%\%OPTION%\bin\save\Samples )
IF NOT EXIST %INSTALLD%\%OPTION%\bin\platforms ( mkdir %INSTALLD%\%OPTION%\bin\platforms )
:: QT5 Runtime
XCOPY /Y /R %QT5D%\icudt51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\icuin51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\icuuc51.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Core.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Gui.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Network.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5D%\Qt5Widgets.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %QT5P%\qwindows.dll %INSTALLD%\%OPTION%\bin\platforms >nul
:: GCC Runtime
XCOPY /Y /R %FFT%\libfftw3f-3.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libgfortran-3.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libquadmath-0.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R "%GCCD%\libstdc++-6.dll" %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libwinpthread-1.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %GCCD%\libgcc_s_dw2-1.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %HL2%\rigctl.exe %INSTALLD%\%OPTION%\bin >nul
:: Add Misc files
XCOPY /Y /R %SRCD%\%APP_NAME%\palir-02.dll %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\wsjt.ico %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\*.dat %INSTALLD%\%OPTION%\bin >nul
XCOPY /Y /R %SRCD%\%APP_NAME%\LICENSE_WHEATLEY.txt %INSTALLD%\%OPTION%\bin >nul
)

:: CHECK IF DEBUG 
IF /I [%OPTION%]==[Debug] ( GOTO DEBUG_MAKEBAT ) ELSE ( GOTO FINISH )
GOTO EOF

:: DEBUG MAKE BATCH FILE 
:DEBUG_MAKEBAT
ECHO -- Generating Debug Batch File for ^( %APP_NAME% ^ )
SET FILENAME=%APP_NAME%.bat
ECHO.
ECHO -----------------------------------------------------------------
ECHO Finished Building %OPTION% Install Target For: ^( %APP_NAME% ^)
ECHO -----------------------------------------------------------------
ECHO.
IF NOT [%APP_NAME%]==[wsjtx] ( GOTO OTHER_MAKEBAT )

:: DEBUG BATCH FILE ( WSJT-X )
:WSJTX_MAKEBAT
ECHO -- Generating Batch File for ^( %APP_NAME% ^ )
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
IF EXIST %APP_NAME%.bat (DEL /Q %APP_NAME%.bat)
>%APP_NAME%.bat (
ECHO @ECHO OFF
ECHO REM -- Debug Batch File
ECHO REM -- Part of the JTSDK v2.0 Project
ECHO TITLE JTSDK QT Debug Terminal
ECHO SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
ECHO SET PATH=.;.\bin;%FFT%;%GCCD%;%QT5D%;%QT5A%;%QT5P%;%HL3%;%HL3%\lib
ECHO CALL %APP_NAME%.exe
ECHO ENDLOCAL
ECHO EXIT /B 0
)
GOTO DEBUG_FINISH

:: DEBUG BATCH FILE ( WSPR-X and MAP65 )
:OTHER_MAKEBAT
ECHO -- Generating Batch File for ^( %APP_NAME% ^ )
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
IF EXIST %APP_NAME%.bat (DEL /Q %APP_NAME%.bat)
>%APP_NAME%.bat (
ECHO @ECHO OFF
ECHO REM -- Debug Batch File
ECHO REM -- Part of the JTSDK v2.0 Project
ECHO TITLE JTSDK QT Debug Terminal
ECHO SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
ECHO SET PATH=%INSTALLD%\%OPTION%\bin;%FFT%;%GCCD%;%QT5D%;%QT5A%;%QT5P%;%HL2%;%HL2%\lib
ECHO CALL %APP_NAME%.exe
ECHO ENDLOCAL
ECHO EXIT /B 0
)
IF /I [%OPTION%]==[Debug] ( GOTO DEBUG_FINISH ) ELSE ( GOTO FINISH )

:: DISPLAY DEBUG_FINISHED MESSAGE
:DEBUG_FINISH
ECHO BUILD SUMMARY
ECHO   Build Tree Location .. %BUILDD%\%OPTION%
ECHO   Install Location ..... %INSTALLD%\%OPTION%\bin\%APP_NAME%.bat
ECHO.
ECHO NOTE: When Running ^( %APP_NAME% ^) Debug versions, please use
ECHO       the provided  ^( %APP_NAME%.bat ^) file as this sets up
ECHO       environment variables and support file paths.
ECHO.
GOTO ASK_DEBUG_RUN

:: ASK USER IF THEY WANT TO RUN THE APP, DEBUG MODE
:ASK_DEBUG_RUN
ECHO.
ECHO  Would You Like To Run %APP_NAME% Now? ^( y/n ^)
ECHO.
SET ANSWER=
SET /P ANSWER=Type Response: %=%
ECHO.
If /I "%ANSWER%"=="Y" ( GOTO RUN_DEBUG )
If /I "%ANSWER%"=="N" ( GOTO EOF
) ELSE (
CLS
ECHO.
ECHO   Please Answer With: ^( y or n ^) & ECHO. & GOTO ASK_DEBUG_RUN
)

:: RUN APP, DEBUG MODE
:RUN_DEBUG
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
ECHO .. Starting: ^( %APP_NAME% ^) in Debug Mode
CALL %APP_NAME%.bat
GOTO EOF

:: DISPLAY FINISH MESSAGE
:FINISH
ECHO.
ECHO BUILD SUMMARY
ECHO   Build Tree Location .. %BUILDD%\%OPTION%
ECHO   Install Location ..... %INSTALLD%\%OPTION%\bin\%APP_NAME%.exe
ECHO.
GOTO ASK_FINISH_RUN

:: ASK USER IF THEY WANT TO RUN THE APP
:ASK_FINISH_RUN
ECHO.
ECHO  Would You Like To Run %APP_NAME% Now? ^( y/n ^)
ECHO.
SET ANSWER=
SET /P ANSWER=Type Response: %=%
ECHO.
If /I "%ANSWER%"=="Y" GOTO RUN_INSTALL
If /I "%ANSWER%"=="N" (
GOTO EOF
) ELSE (
CLS
ECHO.
ECHO   Please Answer With: ^( y or n ^) & ECHO. & GOTO ASK_FINISH_RUN
)

:: RUN APP
:RUN_INSTALL
ECHO.
CD /D %INSTALLD%\%OPTION%\bin
ECHO .. Starting: ^( %APP_NAME% ^) in Release Mode
CALL %APP_NAME%.exe
)
GOTO EOF

REM ----------------------------------------------------------------------------
REM  MESSAGE SECTIONS
REM ----------------------------------------------------------------------------

:: DOUBLE-CLICK ERROR MESSAGE
:DOUBLE_CLICK_ERROR
CLS
@ECHO OFF
ECHO -------------------------------
ECHO       Execution Error
ECHO -------------------------------
ECHO.
ECHO Please Run from JTSDK Enviroment
ECHO.
ECHO          qtenv.bat
ECHO.
GOTO EOF

:: SVN CHECKOUT MESSAGE 
:COMSG
CLS
ECHO -----------------------------------------------------------------
ECHO  %SRCD%\%APP_NAME% Was Not Found
ECHO -----------------------------------------------------------------
ECHO.
ECHO In order to build ^( %APP_NAME% ^) you
ECHO must first perform an SVN checkout.
ECHO.
ECHO ANONYMOUS CHECKOUT ^( %APP_NAME% ^):
ECHO  Type: .. checkout %APP_NAME%
ECHO.
ECHO DEVELOPER CHECKOUT:
ECHO  ^cd src
ECHO  svn co https://%USERNAME%@svn.code.sf.net/p/wsjt/wsjt/branches/%APP_NAME%
ECHO  ^cd ..
ECHO  NOTE: Change ^( %USERNAME% ^) to your Sourforge Username
ECHO.
ECHO ACTIONS AFTER CHECKOUT:
ECHO  Configure Build Tree: .... build %APP_NAME% rconfig
ECHO  Build Install Target: .... build %APP_NAME% rinstall
ECHO.
ECHO OPTIONAL
ECHO  Build Installer Package: .. build %APP_NAME% package
ECHO.
GOTO EOF

:: UNSUPPORTED APPLICATION NAME
:BADNAME
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO                UNSUPPORTED APPLICATION
ECHO -----------------------------------------------------------------
ECHO ^( %1% ^) Check Spelling or Syntax
ECHO.
ECHO USAGE:  build ^(app_name^) ^(type^)
ECHO.
ECHO  Applications ... wsjtx wsprx, map65
ECHO  Release Types .. rconfig rinstall package
ECHO  Debug Types .... dconfig dinstall
ECHO    rconfig ...... Configure Release Build Tree
ECHO    rinstall ..... Build Release Install Target
ECHO    dconfig ...... Configure Debug Build Tree
ECHO    dinstall ..... Build Debug Install Target
ECHO    package ...... Build Win32 Installer
ECHO.
ECHO  NOTE: MAP65 ^& WSPR-X Package Builds are ^( Experimental ^)
ECHO.
ECHO EXAMPLES
ECHO ----------------------------------------------------------
ECHO Configure Build Tree:
ECHO   Type:  build wsjtx rconfig
ECHO.
ECHO Build Install Target:
ECHO   Type:  build wsjtx rinstall
ECHO.
ECHO Build NSIS Installer
ECHO   Type:  build wsjtx package
ECHO.
GOTO EOF

:: UNSUPPORTED BUILD TYPE
:BADTYPE
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO                UNSUPPORTED BUILD TYPE
ECHO -----------------------------------------------------------------
ECHO ^( %2% ^) Check Spelling or Syntax
ECHO.
ECHO USAGE:  build ^(app_name^) ^(type^)
ECHO.
ECHO  Applications ... wsjtx wsprx, map65
ECHO  Release Types .. rconfig rinstall package
ECHO  Debug Types .... dconfig dinstall
ECHO    rconfig ...... Configure Release Build Tree
ECHO    rinstall ..... Build Release Install Target
ECHO    dconfig ...... Configure Debug Build Tree
ECHO    dinstall ..... Build Debug Install Target
ECHO    package ...... Build Win32 Installer
ECHO.
ECHO  NOTE: MAP65 ^& WSPR-X Package Builes are ^( Experimental ^)
ECHO.
ECHO.
ECHO EXAMPLES
ECHO ----------------------------------------------------------
ECHO Configure Build Tree:
ECHO   Type:  build wsjtx rconfig
ECHO.
ECHO Build Install Target:
ECHO   Type:  build wsjtx rinstall
ECHO.
ECHO Build NSIS Installer
ECHO   Type:  build wsjtx package
ECHO.
GOTO EOF

:: UNSUPPORTED INSTALLER TYPE
:PKGMSG
CLS
ECHO.
ECHO -----------------------------------------------------------------
ECHO             UNSUPPORTED INSTALLER BUILD
ECHO -----------------------------------------------------------------
ECHO.
ECHO  ^( %APP_NAME% ^) - Does not have a Package Target. Only
ECHO  WSJT-X is supported at the this time. Furute updates will
ECHO  include an installer build, either InnoSetup or NSIS, but
ECHO  a date has yet to be determined.
ECHO.
ECHO  You can still build and run ^( %APP_NAME% ^) by issuing the
ECHO  folling command:
ECHO.
ECHO  build %APP_NAME% rinstall
ECHO.
ECHO  Then, browse too, and run:
ECHO  %INSTALLD%\%OPTION%\%APP_NAME%.exe
ECHO.
ECHO.
GOTO EOF

:: GENERAL CMAKE ERROR MESSAGE
:CMAKE_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO                    CMAKE BUILD ERROR
ECHO -----------------------------------------------------------------
ECHO.
ECHO  There was a problem building ^( App: %1%  Target: %2 ^)
ECHO.
ECHO  Check the screen for error messages, correct, then try to
ECHO  re-build ^( App: %1%  Target: %2 ^)
ECHO.
ECHO.
GOTO EOF

:: NSIS INSTALLER BUILD ERROR MESSAGE
:NSIS_BUILD_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO                    INSTALLER BUILD ERROR
ECHO -----------------------------------------------------------------
ECHO.
ECHO  There was a problem building the package, or the script
ECHO  could not find:
ECHO.
ECHO  %BUILDD%\%OPTION%\%WSJTXPKG%
ECHO.
ECHO  Check the Cmake logs for any errors, or correct any build
ECHO  script issues that were obverved and try to rebuild the package.
ECHO.
ECHO.
GOTO EOF

:: INNO SETUOP BUILD ERROR MESSAGE
:INNO_BUILD_ERROR
ECHO.
ECHO -----------------------------------------------------------------
ECHO                    INSTALLER BUILD ERROR
ECHO -----------------------------------------------------------------
ECHO.
ECHO  There was a problem building ^( App: %1%  Target: %2 ^)
ECHO.
ECHO  Check the screen for error messages, correct, then try to
ECHO  re-build ^( App: %1%  Target: %2 ^)
ECHO.
ECHO.
GOTO EOF

:: END QTENV-BUILD.BAT
:EOF
CD /D %BASED%
ENDLOCAL

EXIT /B 0
