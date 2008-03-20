#Makefile for Windows
!include <dfinc.mak>   #Some definitions for Compaq Visual Fortran
CC = cl
FC = df
#FFLAGS = /traceback /fast /nologo /check:all /fpp /DCVF
FFLAGS = /traceback /fast /nologo /fpp /DCVF
CFLAGS = /DWin32 /DCVF /I. 

OBJS2 = wspr_tx.obj genmept.obj inter_mept.obj nchar.obj grid2deg.obj \
	packcall.obj packgrid.obj pack50.obj unpack50.obj unpackcall.obj \
	unpackgrid.obj deg2grid.obj ptt.obj set.obj gran.obj encode232.obj \
	playsound.obj 

OBJS3 = wspr_rx.obj inter_mept.obj \
	mix162.obj xfft.obj four1.obj four2.obj sync162.obj ps162.obj \
	mept162.obj nchar.obj grid2deg.obj unpack50.obj unpackcall.obj \
	unpackgrid.obj deg2grid.obj getrms.obj \
	set.obj encode232.obj fano232.obj wfile5.obj \
	xcor162.obj slope.obj peakup.obj pctile.obj db.obj sort.obj \
	ssort.obj decode162.obj getsound.obj

all:    WSPR.EXE wspr_tx.exe wspr_rx.exe

WSPR.EXE: wspr.spec
	c:\python25\python c:\pyinstaller-1.3\Build.py wspr.spec

wspr_tx.exe: $(OBJS2)
	$(FC) /exe:wspr_tx.exe $(FFLAGS) $(OBJS2) pa.lib

wspr_rx.exe: $(OBJS3)
	$(FC) /exe:wspr_rx.exe $(FFLAGS) $(OBJS3) pa.lib

wspr.spec: wspr.py g.py options.py palettes.py 
	c:\python25\python c:\pyinstaller-1.3\makespec.py --icon wsjt.ico \
	--tk --onefile wspr.py

wspr_rx.obj: wspr_rx.f90
	$(FC) /compile_only $(FFLAGS) wspr_rx.f90
wspr_tx.obj: wspr_tx.f90
	$(FC) /compile_only $(FFLAGS) wspr_tx.f90

.PHONY : clean

clean:
	-del *.obj wspr.exe wspr_rx.exe wspr_tx.exe



