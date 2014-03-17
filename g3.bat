set INSTALLDIR=install
rm -rf %INSTALLDIR%
mkdir %INSTALLDIR%
mkdir %INSTALLDIR%\bin
c:\Python33\Scripts\cxfreeze --include-path=. --include-modules=Pmw wsjt.py --target-dir=%INSTALLDIR%\bin
