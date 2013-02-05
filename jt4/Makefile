# Makefile for Windows
# For re-direct:
#   C> make > junk 2>&1

CC = /mingw/bin/gcc
FC = /mingw/bin/g95

FFLAGS = -O2 -fbounds-check -Wall -Wno-precision-loss
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

all:    libjt.a jt4metrics.exe simsync.exe jt4code.exe simjt4.exe

OBJS1 = chkmsg.o deg2grid.o encode232.o encode4.o entail.o fano232.o \
	getmet4.o getpfx1.o getpfx2.o gran.o grid2deg.o grid2k.o \
	interleave4.o k2grid.o nchar.o packcall.o packgrid.o packmsg.o \
	packtext.o unpackcall.o unpackgrid.o unpackmsg.o unpacktext.o

libjt.a: $(OBJS1)
	ar cr libjt.a $(OBJS1) 
	ranlib libjt.a

OBJS2 = jt4metrics.o libjt.a 
jt4metrics.exe: $(OBJS2)
	$(FC) -o jt4metrics.exe $(FFLAGS) $(OBJS2)  libjt.a 

OBJS3 = simsync.o  libjt.a 
simsync.exe: $(OBJS3)
	$(FC) -o simsync.exe $(FFLAGS) $(OBJS3) libjt.a 

OBJS4 = jt4code.o libjt.a 
jt4code.exe: $(OBJS4)
	$(FC) -o jt4code.exe $(FFLAGS) $(OBJS4) libjt.a 

OBJS5 = simjt4.o libjt.a 
simjt4.exe: $(OBJS5)
	$(FC) -o simjt4.exe $(FFLAGS) $(OBJS5) libjt.a 

.PHONY : clean

clean:
	rm -f *.o jt4metrics.exe simsync.exe jt4code.exe simjt4.exe
