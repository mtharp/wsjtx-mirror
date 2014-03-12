set OLDPATH=%PATH%
set PATH=C:\MinGW\bin;%PATH%
c:\python27\python c:\python27\Scripts\f2py.py -c -I. --fcompiler=gnu95 --compiler=mingw32 --f77exec=gfortran --f90exec=gfortran --opt="-cpp -fbounds-check -O2" libjt.a libportaudio.a libfftw3f_win.a libsamplerate.a libpthreadGC2.a -lwinmm -m Audio ftn_init.f90 ftn_quit.f90 audio_init.f90 spec.f90  getfile.f90 azdist0.f90 astro0.f90 chkt0.f90
mv Audio.pyd WsjtMod/Audio.pyd
set PATH=%OLDPATH%
