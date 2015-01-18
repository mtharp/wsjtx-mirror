# Makefile for MinGW on Windows
CC  = c:/JTSDK/Qt5/Tools/mingw48_32/bin/gcc
FC = c:/JTSDK/Qt5/Tools/mingw48_32/bin/gfortran
CXX = c:/JTSDK/Qt5/Tools/mingw48_32/bin/g++

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

#all:    libastro.a tstecho.exe polecho.exe echodop.exe testmoon3.exe 

all:	lor.exe

OBJS1 = astrosub.o astro0.o astro.o tm2.o grid2deg.o sun.o moondop.o \
	coord.o dot.o moon2.o tmoonsub.o toxyz.o geocentric.o \
	dcoord.o 

libastro.a: $(OBJS1)
	ar cr libastro.a $(OBJS1)
	ranlib libastro.a

OBJS2 = tstecho.o four2a.o avecho.o avecho65.o txtone.o smo121.o \
	pctile.o sort.o ssort.o cspec.o polfit.o

tstecho.exe: $(OBJS2) libastro.a
	$(FC) -o tstecho.exe $(OBJS2) libastro.a ../libfftw3f_win.a
	cp tstecho.exe /JTSDK/src/echo_install

OBJS3 = polecho.o polfit2.o pctile.o sort.o ssort.o 

polecho.exe: $(OBJS3) libastro.a
	$(FC) -o polecho.exe $(OBJS3) 
	cp polecho.exe /JTSDK/src/echo_install

OBJS4 = echodop.o

echodop.exe: $(OBJS4) libastro.a
	$(FC) -o echodop.exe $(OBJS4) libastro.a
	cp echodop.exe /JTSDK/src/echo_install

OBJS5 = testmoon3.o grid2deg.o deg2grid.o jplsubs.o geocentric.o \
	ephem.o libration.o 
testmoon3.exe: $(OBJS5) libsla1.a
	$(FC) -o testmoon3 $(OBJS5) libsla.a libastro.a
	cp testmoon3.exe /JTSDK/src/echo_install

OBJS6 = lor.o functn.o curfit.o fchisq.o fderiv.o gran.o
lor.exe: $(OBJS6)
	$(FC) -o lor.exe $(OBJS6)

.PHONY : clean

clean:
	rm -f *.o
