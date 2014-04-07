@ECHO OFF
REM -- JTSDK-DOC Windows Build Script
REM -- Part of the WSJT Documentation Project

REM -- Start WSJT Documentation Build
TITLE WSJT Documentation Envirnoment
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

REM -- SET BASE PATH to "." & TRIM TRAILING "\" IF PRESENT
REM SET TARGET=%~dp0
REM IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
REM SET BASED=%TARGET%
REM SET PATH=%BASED%;%ICOND%
SET ICOND=%BASED%\icons

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
REM -- Remove this section with WSJT-X v1.4.0 release
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
REM -- Remove this section with WSJT-X v1.4.0 release
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
GOTO EOF

:DOCHELP
@ECHO OFF
CLS
ECHO.
ECHO      _ _____ ____  ____  _  __     ____   ___   ____ 
ECHO     ^| ^|_   _/ ___^|^|  _ \^| ^|/ /    ^|  _ \ / _ \ / ___^|
ECHO  _  ^| ^| ^| ^| \___ \^| ^| ^| ^| ' /_____^| ^| ^| ^| ^| ^| ^| ^|    
ECHO ^| ^|_^| ^| ^| ^|  ___) ^| ^|_^| ^| . \_____^| ^|_^| ^| ^|_^| ^| ^|___ 
ECHO  \___/  ^|_^| ^|____/^|____/^|_^|\_\    ^|____/ \___/ \____^|
ECHO.
ECHO.
ECHO BUILD WSJT DOCUMENTATION
ECHO ------------------------------------------------------
ECHO USAGE: build [document name]
ECHO. 
ECHO  build wsjt
ECHO  build wsjtx
ECHO  build wspr
ECHO  build wsprx
ECHO  build map65
ECHO  build devg
ECHO  build qref
ECHO.
ECHO ------------------------------------------------------
ECHO.
ECHO To View, Type:  [document name]
ECHO For Help, Type: doc-help
ECHO.
EXIT /B 0

:EOF
call:DOCHELP
ENDLOCAL
EXIT /B 0
