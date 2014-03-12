mingw32-make -f Makefile.MinGW.gfortran wsjt10.exe 
mingw32-make -f Makefile.MinGW.gfortran jt65code.exe 
mingw32-make -f Makefile.MinGW.gfortran jt4code.exe 
mingw32-make -f Makefile.MinGW.gfortran install
copy kvasd.exe install\kvasd.exe
copy kvasd.dat install\kvasd.dat
rm -rf install/bin/_MEI/tcl/tzdata
