# Makefile for WSPRX, using MinGW on Windows
# Windows re-direct:
#   C> make > junk1 2>&1

CC = gcc
FC = g95

FFLAGS = -O2 -fbounds-check -Wall -Wno-precision-loss -ftrace=frame
#CFLAGS = -I. -fbounds-check -mno-stack-arg-probe
CFLAGS = -I. -fbounds-check 

# Default rules
%.o: %.c
	${CC} ${CFLAGS} -c $<
%.o: %.f
	${FC} ${FFLAGS} -c $<
%.o: %.F
	${FC} ${FFLAGS} -c $<
%.o: %.f90
	${FC} ${FFLAGS} -c $<
%.o: %.F90
	${FC} ${FFLAGS} -c $<

all:    libwspr.a wspr0.exe

OBJS1 = symspec.o timf2.o fil3.o wspr0_tx.o sound.o ptt.o gmtime2.o \
	wfile5.o genmept.o wqencode.o wqdecode.o inter_mept.o \
	encode232.o gran.o packcall.o packgrid.o pack50.o packpfx.o \
	hash.o unpackcall.o unpackgrid.o unpackpfx.o unpack50.o \
	grid2deg.o deg2grid.o nhash.o nchar.o wspr0_rx.o getrms.o \
	mept162.o mix162.o spec162.o sync162.o twkfreq.o \
	decode162.o getutc.o set.o xfft.o four2a.o flat3.o ps162.o \
	pctile.o fchisq.o db.o fano232.o sort.o ssort.o ccf2.o \
	genwsprx.o savec2.o

libwspr.a: $(OBJS1)
	ar cr libwspr.a $(OBJS1) 
	ranlib libwspr.a

OBJS2 = wspr0.o 

wspr0.exe: $(OBJS2) libwspr.a
	$(FC) -o wspr0 $(FFLAGS) $(OBJS2) libwspr.a libportaudio.a \
	   c:\MinGW\lib\libwinmm.a libfftw3f_win.a
	cp wspr0.exe ../../wsprx_install

sound.o: sound.c
	$(CC) -c sound.c
gmtime2.o: gmtime2.c
	$(CC) -c -DWin32=1 gmtime2.c

.PHONY : clean

clean:
	rm -f *.o libwspr.a wspr0.exe
