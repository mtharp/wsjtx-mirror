set INSTALLDIR=wsjt10
rm -rf %INSTALLDIR%
mkdir %INSTALLDIR%
mkdir %INSTALLDIR%\bin
cp wsjt.py %INSTALLDIR%/bin
cp -r WsjtMod %INSTALLDIR%/bin
cp -r RxWav %INSTALLDIR%
cp DLLs/* %INSTALLDIR%/bin
cp CALL3.TXT kvasd.dat kvasd.exe wsjt.ico wsjt10.bat %INSTALLDIR%
