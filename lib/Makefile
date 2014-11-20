# Makefile for Echo, using MinGW on Windows
# Windows re-direct:
#   C> make > junk1 2>&1

CC  = c:/JTSDK-QT/Qt5/Tools/mingw48_32/bin/gcc
FC = c:/JTSDK-QT/Qt5/Tools/mingw48_32/bin/gfortran

FFLAGS = -O2 -fbounds-check -Wall -Wno-precision-loss 
CFLAGS = -I.

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

all:    libecho.a

OBJS1 = ccf2.o db.o decode162.o deg2grid.o encode232.o fano232.o \
	fchisq.o fil3c.o flat3.o four2a.o genwsprx.o grid2deg.o \
	hash.o inter_mept.o mept162a.o mix162.o mix162a.o \
	nchar.o nhash.o pack50.o packcall.o packgrid.o packpfx.o \
	pctile.o ps162.o ptt.o savec2.o set.o sort.o ssort.o symspec.o \
	sync162.o timf2.o twkfreq.o unpack50.o unpackcall.o \
	unpackgrid.o unpackpfx.o wqdecode.o wqencode.o xfft.o \
	mixlpf.o morse.o blanker.o

libecho.a: $(OBJS1)
	ar cr libecho.a $(OBJS1) 
	ranlib libecho.a

.PHONY : clean

clean:
	rm -f *.o libecho.a
