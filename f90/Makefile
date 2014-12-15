# Makefile for MinGW on Windows
CC  = c:/JTSDK-QT/Qt5/Tools/mingw48_32/bin/gcc
FC = c:/JTSDK-QT/Qt5/Tools/mingw48_32/bin/gfortran
CXX = c:/JTSDK-QT/Qt5/Tools/mingw48_32/bin/g++

FFLAGS = -O2 -fbounds-check -Wall -Wno-precision-loss -fno-second-underscore
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

all:    libastro.a


OBJS7 = astrosub.o astro0.o astro.o tm2.o grid2deg.o sun.o moondop.o \
	coord.o dot.o moon2.o tmoonsub.o toxyz.o geocentric.o \
	dcoord.o

libastro.a: $(OBJS7)
	ar cr libastro.a $(OBJS7)
	ranlib libastro.a

.PHONY : clean

clean:
	rm -f *.o libm65.a m65.exe jt65code.exe
