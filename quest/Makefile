CC = gcc
FC = g95
FFLAGS = -g -O2 -march=i686 -Wall -fbounds-check
CFLAGS=-g -O9 -march=i686 -Wall

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


OBJS1 = WSJT8codes.o srcenc.o srcdec.o parse.o msgtrim.o packcall.o \
	packgrid.o nchar.o grid2deg.o pkcall.o pkgrid.o pktext.o \
	unpkcall.o unpkgrid.o deg2grid.o unpktext.o \
	pk30.o pk48.o pk78.o packpfx.o unpackpfx.o \
	hash.o nhash.o chenc.o chdec.o packbits.o unpackbits.o \
	wrapkarn.o init_rs_int.o encode_rs_int.o decode_rs_int.o 

OBJS3 = quest.o gasdev.o ran1.o rayleigh.o packbits.o unpackbits.o \
	init_rs_int.o encode_rs_int.o decode_rs_int.o wrapkarn.o \
	tab.o second.o cencode.o vdecode.o asd1.o demod64.o \
	qsync.o qinit.o qdecode.o qdat.o qsim.o encode232.o \
	fano232.o vit215.o vit216.o vit217.o vit218.o vit316.o \
	vit416.o vit207.o vit209.o vit213.o vit211.o

OBJS6 = testrs.o set.o chksync.o \
	init_rs_int.o encode_rs_int.o decode_rs_int.o \
	wrapkarn.o asd1.o gendat2.o extracta.o demod64.o \
	ran1.o gasdev.o indexx.o rayleigh.o

all:	quest testrs WSJT8codes

quest:  $(OBJS3)
	$(FC) -o quest $(OBJS3)

testrs: $(OBJS6)
	$(FC) -o testrs $(OBJS6)

WSJT8codes: $(OBJS1)
	$(FC) -o WSJT8codes $(OBJS1)

asd1.o: asd1.c asd2.c asd3.c asd.h
	gcc -c -O asd1.c
init_rs_int.o: init_rs.c
	gcc -DBIGSYM=1 $(CFLAGS) -c -o $@ $^
encode_rs_int.o: encode_rs.c
	gcc -DBIGSYM=1 $(CFLAGS) -c -o $@ $^
decode_rs_int.o: decode_rs.c
	gcc -DBIGSYM=1 $(CFLAGS) -c -o $@ $^

.PHONY : clean
clean:
	-rm -f *.o quest testrs WSJT8codes

