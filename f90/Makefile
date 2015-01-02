# Makefile for MinGW on Windows
CC  = c:/JTSDK-QT/Qt5/Tools/mingw48_32/bin/gcc
FC = c:/JTSDK-QT/Qt5/Tools/mingw48_32/bin/gfortran
CXX = c:/JTSDK-QT/Qt5/Tools/mingw48_32/bin/g++

FFLAGS = -O2 -fbounds-check -Wall -fno-second-underscore
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

all:    libastro.a tstecho.exe


OBJS1 = astrosub.o astro0.o astro.o tm2.o grid2deg.o sun.o moondop.o \
	coord.o dot.o moon2.o tmoonsub.o toxyz.o geocentric.o \
	dcoord.o

libastro.a: $(OBJS1)
	ar cr libastro.a $(OBJS1)
	ranlib libastro.a

OBJS2 = tstecho.o four2a.o avecho.o avecho65.o txtone.o smo121.o \
	pctile.o sort.o ssort.o cspec.o polfit.o

tstecho.exe: $(OBJS2)
	$(FC) -o tstecho.exe $(OBJS2) libastro.a ../libfftw3f_win.a
	cp tstecho.exe /JTSDK-QT/src/echo_install

.PHONY : clean

clean:
	rm -f *.o libm65.a m65.exe jt65code.exe
