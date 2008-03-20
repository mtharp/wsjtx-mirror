#Makefile for Windows and MinGW
CC = gcc
FC = g95

FFLAGS = -cpp
CFLAGS = -I. -fbounds-check

OBJS1 = wspr.o mept_tx.o mept_rx.o genmept.o inter_mept.o \
	mix162.o xfft.o four1.o four2.o sync162.o ps162.o \
	mept162.o wfile5.o nchar.o grid2deg.o \
	packcall.o packgrid.o pack50.o unpack50.o unpackcall.o \
	unpackgrid.o deg2grid.o gran.o getrms.o ptt.o \
	set.o encode232.o fano232.o \
	xcor162.o slope.o peakup.o pctile.o db.o sort.o \
	ssort.o decode162.o playsound.o getsound.o

OBJS2 = wspr_tx.o genmept.o inter_mept.o nchar.o grid2deg.o \
	packcall.o packgrid.o pack50.o unpack50.o unpackcall.o \
	unpackgrid.o deg2grid.o ptt.o set.o gran.o encode232.o \
	playsound.o 

OBJS3 = wspr_rx.o inter_mept.o \
	mix162.o xfft.o four1.o four2.o sync162.o ps162.o \
	mept162.o nchar.o grid2deg.o unpack50.o unpackcall.o \
	unpackgrid.o deg2grid.o getrms.o \
	set.o encode232.o fano232.o wfile5.o \
	xcor162.o slope.o peakup.o pctile.o db.o sort.o \
	ssort.o decode162.o getsound.o


all:    wspr.exe wspr_tx.exe wspr_rx.exe

wspr.exe: $(OBJS1)
	$(FC) -o wspr.exe $(FFLAGS) $(OBJS1) libportaudio.a -lwinmm

wspr_tx.exe: $(OBJS2)
	$(FC) -o wspr_tx.exe $(FFLAGS) $(OBJS2) libportaudio.a -lwinmm

wspr_rx.exe: $(OBJS3)
	$(FC) -o wspr_rx.exe $(FFLAGS) $(OBJS3) libportaudio.a -lwinmm

gran.o: gran.f90
	$(FC) -c $(FFLAGS) gran.f90
mept_rx.o: mept_rx.f90
	$(FC) -c $(FFLAGS) mept_rx.f90
mept_tx.o: mept_tx.f90
	$(FC) -c $(FFLAGS) mept_tx.f90
wspr.o: wspr.f90
	$(FC) -c $(FFLAGS) wspr.f90
wspr_rx.o: wspr_rx.f90
	$(FC) -c $(FFLAGS) wspr_rx.f90
wspr_tx.o: wspr_tx.f90
	$(FC) -c $(FFLAGS) wspr_tx.f90

.PHONY : clean

clean:
	rm *.o wspr.exe wspr_tx.exe wspr_rx.exe



