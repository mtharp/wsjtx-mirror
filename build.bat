@ECHO OFF
REM -- JTSDK-DOC Windows Build Script
REM -- Part of the WSJT Documentation Project

REM -- Start WSJT Documentation Build
TITLE WSJT Documentation Envirnoment
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM -- SET BASE PATH to "." & TRIM TRAILING "\" IF PRESENT
SET TARGET=%~dp0
IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
SET BASED=%TARGET%
SET ICOND=%BASED%\icons
SET PATH=%BASED%;%ICOND%

REM -- PROCESS VARS
SET ADOC=%BASED%\asciidoc\asciidoc.exe
SET TOC=%ADOC% -b xhtml11 -a toc2 -a iconsdir=../icons -a max-width=1024px
SET BUILD_LIST=(dev-guide map65 quick-ref simjt wsjt wspr wsprx)

REM -- USER INPUT CONDITIONALS
IF /I [%1]==[wsjtx] (SET DOC_NAME=wsjtx &GOTO WSJTX
) ELSE IF /I [%1]==[help] (
CLS &ECHO.
GOTO DOCHELP
) ELSE IF /I [%1]==[all] (
CLS &ECHO.
GOTO BUILD_ALL
) ELSE IF /I [%1]==[devg] (
CLS &ECHO.
SET DOC_NAME=dev-guide
GOTO GENERAL
) ELSE IF /I [%1]==[wsprx] (
CLS &ECHO.
SET DOC_NAME=wsprx
GOTO GENERAL
) ELSE IF /I [%1]==[map65] (
CLS &ECHO.
SET DOC_NAME=map65
GOTO GENERAL
) ELSE IF /I [%1]==[qref] (
CLS &ECHO.
SET DOC_NAME=quick-ref
GOTO GENERAL
) ELSE IF /I [%1]==[simjt] (
CLS &ECHO.
SET DOC_NAME=simjt
GOTO GENERAL
) ELSE IF /I [%1]==[wsjt] (
CLS &ECHO.
SET DOC_NAME=wsjt
GOTO GENERAL
) ELSE IF /I [%1]==[wspr] (
CLS &ECHO.
SET DOC_NAME=wspr
GOTO GENERAL
) ELSE IF /I [%1]==[wsprx] (
CLS &ECHO.
SET DOC_NAME=wsprx
GOTO GENERAL 
) ELSE (GOTO DOCHELP)

REM -- START BUILD OPTIONS
REM -- SPECIAL WSJTX BUILD NAME
REM --Change to: wsjtx-main.html after next WSJT-X APP Release
:WSJTX
CLS
CD %BASED%\%DOC_NAME%
ECHO Building Special Version for ^( wsjtx ^)
%TOC% -o wsjtx-main-toc2.html source\wsjtx-main.adoc
ECHO.
ECHO .. Location: %BASED%\wsjtx\wsjtx-main-toc2.html
ECHO.
PAUSE
GOTO EOF

REM -- BUILD USER SELECT DOCUMENT $1 == %1
:GENERAL
CD %BASED%\%DOC_NAME%
ECHO Building ^( %DOC_NAME% ^)
%TOC% -o %DOC_NAME%-main.html source\%DOC_NAME%-main.adoc
ECHO .. Location: %BASED%\%DOC_NAME%\%DOC_NAME%-main.html
ECHO.
GOTO EOF

REM -- BUILD ALL DOCS

:BUILD_ALL
CLS
REM -- SPECIAL WSJTX BUILD NAME
REM --Change to: wsjtx-main.html after next WSJT-X APP Release
CD %BASED%\wsjtx
ECHO Building Special Version for ^( wsjtx ^)
%TOC% -o wsjtx-main-toc2.html source\wsjtx-main.adoc
ECHO .. Location: %BASED%\wsjtx\wsjtx-main-toc2.html
ECHO.

REM -- LOOP FOR REMAINING DOCUMENTS
ECHO Building ^( ALL Other ^) Documentation
FOR %%A IN %BUILD_LIST% DO (
CD %BASED%\%%A
%TOC% -o %%A-main.html source\%%A-main.adoc 
ECHO .. Location: %BASED%\%%A\%%A-main.html
)
PAUSE
GOTO eof

:DOCHELP
@ECHO OFF
REM -- DOSKEY BUILD COMMAND FROM ENV
DOSKEY wsjt=%BASED%\build-test.bat wsjt
DOSKEY wsjtx=%BASED%\build-test.bat wsjtx
DOSKEY wspr=%BASED%\build-test.bat wspr
DOSKEY wsprx=%BASED%\build-test.bat wsprx
DOSKEY map65=%BASED%\build-test.bat map65
DOSKEY qref=%BASED%\build-test.bat qref
DOSKEY devg=%BASED%\build-test.bat devg
DOSKEY doc-help=%BASED%\build-test.bat help
CLS
ECHO.
ECHO      _ _____ ____  ____  _  __     ____   ___   ____ 
ECHO     ^| ^|_   _/ ___^|^|  _ \^| ^|/ /    ^|  _ \ / _ \ / ___^|
ECHO  _  ^| ^| ^| ^| \___ \^| ^| ^| ^| ' /_____^| ^| ^| ^| ^| ^| ^| ^|    
ECHO ^| ^|_^| ^| ^| ^|  ___) ^| ^|_^| ^| . \_____^| ^|_^| ^| ^|_^| ^| ^|___ 
ECHO  \___/  ^|_^| ^|____/^|____/^|_^|\_\    ^|____/ \___/ \____^|
ECHO.
ECHO BUILD DOCUMENTATION
ECHO ------------------------------------------------------
ECHO  Build WSJT ....... Type: build wsjt
ECHO  Build WSJT-X ..... Type: build wsjtx
ECHO  Build WSPR ....... Type: build wspr
ECHO  Build WSPR-X ..... Type: build wsprx
ECHO  Build MAP65 ...... Type: build map65
ECHO  Build Dev Guide .. Type: build devg
ECHO  Build Quick Ref .. Type: build qref
ECHO.
ECHO  For Help ......... Type: doc-help
ECHO.
EXIT /B 0

:EOF
pause
call:DOCHELP
ENDLOCAL
EXIT /B 0
