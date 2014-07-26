@ECHO OFF
REM -- JTSDK-DOC Windows Build Script
REM -- Part of the WSJT Documentation Project

REM -- Start WSJT Documentation Build
TITLE WSJT Documentation Envirnoment
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
SET SCRIPTVER=0.9.1

REM -- SET BASE PATH to "." & TRIM TRAILING "\" IF PRESENT
REM SET TARGET=%~dp0
REM IF %TARGET:~-1%==\ SET TARGET=%TARGET:~0,-1%
REM SET BASED=%TARGET%
REM SET PATH=%BASED%;%ICOND%
SET ICOND=%BASED%\icons

REM -- PROCESS VARS
SET ADOC=%BASED%\asciidoc\asciidoc.exe
SET TOC=%ADOC% -b xhtml11 -a toc2 -a iconsdir=../icons -a max-width=1024px
SET BUILD_LIST=(dev-guide map65 quick-ref simjt wsjt wsjtx wspr wfmt wsprx)

REM -- USER INPUT CONDITIONALS
IF /I [%1]==[help] (
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
) ELSE IF /I [%1]==[wsjtx] (
CLS &ECHO.
SET DOC_NAME=wsjtx
GOTO GENERAL
) ELSE IF /I [%1]==[wspr] (
CLS &ECHO.
SET DOC_NAME=wspr
GOTO GENERAL
) ELSE IF /I [%1]==[wfmt] (
CLS &ECHO.
SET DOC_NAME=wfmt
GOTO GENERAL
) ELSE IF /I [%1]==[wsprx] (
CLS &ECHO.
SET DOC_NAME=wsprx
GOTO GENERAL 
) ELSE (GOTO DOCHELP)

REM -- BUILD USER SELECT DOCUMENT $1 == %1
:GENERAL
CD %BASED%\%DOC_NAME%
ECHO Building ^( %DOC_NAME% ^)
%TOC% -o %DOC_NAME%-main.html source\%DOC_NAME%-main.adoc
ECHO.
ECHO  Finished building ^( %DOC_NAME% ^)
ECHO  Location: %BASED%\%DOC_NAME%\%DOC_NAME%-main.html
ECHO.
ECHO  To Open, At The Promt, Type: %DOC_NAME%
ECHO.
PAUSE
ECHO.
GOTO EOF

REM -- BUILD ALL DOCS
:BUILD_ALL
CLS
REM -- LOOP FOR REMAINING DOCUMENTS
ECHO Building ^( ALL ^) Documentation
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
ECHO USAGE: build.bat [document name] or "all" for all docs.
ECHO. 
ECHO  build.bat wsjt
ECHO  build.bat wsjtx
ECHO  build.bat wspr
ECHO  build.bat wsprx
ECHO  build.bat wfmt
ECHO  build.bat map65
ECHO  build.bat devg
ECHO  build.bat qref
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
