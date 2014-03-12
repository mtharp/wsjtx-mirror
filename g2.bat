set OLDPATH=%PATH%
set PATH=C:\MinGW\bin;%PATH%

c:\python27\python c:\python27\Scripts\f2py.py -c -I. --fcompiler=gnu95 --compiler=mingw32 --f77exec=gfortran --f90exec=gfortran --opt="-cpp -fbounds-check -O2" libwspr.a libportaudio.a libpthreadGC2.a libfftw3f_win.a -lwinmm -m w wspr1.f90 getfile.f90 paterminate.f90 ftn_quit.f90 audiodev.f90

mv w.pyd WsprMod/w.pyd

set PATH=%OLDPATH%
