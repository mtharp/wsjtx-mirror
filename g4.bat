set INSTALLDIR=install
mkdir %INSTALLDIR%\bin
c:\Python33\Scripts\cxfreeze --include-path=. --include-modules=Pmw wspr.py --target-dir=%INSTALLDIR%\bin
