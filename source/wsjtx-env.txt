@ECHO OFF
REM -- Custom CMD Window for WSJT-X Build using CMake
REM -- Part of the WSJT Documentation project
REM -- Change color so users know this is *not* a normal CMD Window
COLOR 1B
TITLE WSJT Environment
CLS
REM -- Be careful editing these variables, if wrong, the build will fail!
SET BASED=C:\wsjt-env
SET CMAKED=C:\wsjt-env\CMake\bin
SET SVND=C:\wsjt-env\SlikSvn\bin
SET QTD=C:\wsjt-env\Qt5\5.2.1\mingw48_32\bin
SET TOOLSD=C:\wsjt-env\Qt5/Tools/mingw48_32\bin
SET PATH=%BASED%;%CMAKED%;%SVND%;%QTD%;%TOOLSD%;%PATH%
CD /D %BASED%
ECHO.
ECHO Build Environment is Using
ECHO ---------------------------
 cmake --version |findstr "cmake"
 qmake --version |findstr "QMake"
 svn --version |findstr "svn,"
 mingw32-make -v |findstr "Make"
 gfortran --version |findstr "Built"
 gcc --version |findstr "gcc"
 g++ --version |findstr "g++"
ECHO.
ECHO To Build WSJT-X using CMake
ECHO ---------------------------
ECHO * Release: wsjtx-build-cmake.bat -r
ECHO * Debug  : wsjtx-build-cmake.bat -d
ECHO.
C:\Windows\System32\cmd.exe /A /Q /K