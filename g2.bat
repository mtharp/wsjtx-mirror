f2py.py -c -I. --fcompiler=gnu95 --compiler=mingw32 --f77exec=gfortran --f90exec=gfortran --opt="-cpp -fbounds-check -O2" libwspr.a libportaudio.a libfftw3f_win.a libsamplerate.a libpthreadGC2.a -lwinmm -m w wspr1.f90 getfile.f90 paterminate.f90 ftn_quit.f90 audiodev.f90

mv w.pyd WsprMod/w.pyd
cp WsprMod/w.pyd WsprModNoGui/w.pyd
