mingw32-make -f Makefile.MinGW.gfortran wspr.exe 
mingw32-make -f Makefile.MinGW.gfortran fmt.exe
mingw32-make -f Makefile.MinGW.gfortran fmtave.exe
mingw32-make -f Makefile.MinGW.gfortran fcal.exe
mingw32-make -f Makefile.MinGW.gfortran fmeasure.exe
mingw32-make -f Makefile.MinGW.gfortran wspr0.exe
mingw32-make -f Makefile.MinGW.gfortran install
rm -rf install/bin/_MEI/tcl/tzdata

cp fcal.exe fmeasure.exe fmt.exe fmtave.exe rigctl.exe wspr0.exe install

