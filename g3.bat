REM mingw32-make -f Makefile.jtsdk wspr.exe 
mingw32-make -f Makefile.jtsdk fmt.exe
mingw32-make -f Makefile.jtsdk fmtave.exe
mingw32-make -f Makefile.jtsdk fcal.exe
mingw32-make -f Makefile.jtsdk fmeasure.exe
mingw32-make -f Makefile.jtsdk wspr0.exe
REM mingw32-make -f Makefile.jtsdk install
rm -rf install
mkdir install
cp fcal.exe fmeasure.exe fmt.exe fmtave.exe rigctl.exe wspr0.exe install

