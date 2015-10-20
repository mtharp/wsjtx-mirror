# Makefile for Windows in JTSDK-PY environment

# Re-direct stdout and stderr:     cmd.exe              bash
#                              make > junk 2>&1      make &> junk

CC = gcc
FC = gfortran

FFLAGS = -O2 -DWIN32 -fbounds-check -fno-second-underscore -Wall \
       -Wno-conversion -Wno-character-truncation
CFLAGS = -I. -DWIN32 -DWin32 -DBIGSYM -DHAVE_STRUCT_TIMESPEC

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

all:    libsfrsd.a rsdtest rsdtest2 rsdtest3

OBJS0 = extract2.o sfrsd2.o init_rs_int.o encode_rs_int.o decode_rs_int.o
libsfrsd.a: $(OBJS0)
	ar cr libsfrsd.a $(OBJS0)
	ranlib libsfrsd.a
	cp libsfrsd.a ..

OBJS1 = rsdtest.o extract2.o sfrsd2.o encode_rs_int.o \
	decode_rs_int.o init_rs_int.o 
rsdtest: $(OBJS1) ../libjt.a
	$(FC) -o rsdtest $(OBJS1) libsfrsd.a ../libjt.a ../libpthreadGC2.a

OBJS2 = rsdtest2.o sfrsd2.o encode_rs_int.o decode_rs_int.o init_rs_int.o 
rsdtest2: $(OBJS2) ../libjt.a
	$(FC) -o rsdtest2 $(OBJS2) libsfrsd.a ../libjt.a \
	../libfftw3f_win.a ../libpthreadGC2.a

OBJS3 = rsdtest3.o sfrsd2.o encode_rs_int.o decode_rs_int.o init_rs_int.o 
rsdtest3: $(OBJS3) ../libjt.a
	$(FC) -o rsdtest3 $(OBJS3) libsfrsd.a ../libjt.a \
	../libfftw3f_win.a ../libpthreadGC2.a

sfrsd: sfrsd.o encode_rs_int.o decode_rs_int.o init_rs_int.o
	gcc -g -o $@ $^

encode_rs_int.o: encode_rs.c
	gcc -DBIGSYM=1 $(CFLAGS) -c -o $@ $^

decode_rs_int.o: decode_rs.c
	gcc -DBIGSYM=1 $(CFLAGS) -c -o $@ $^

init_rs_int.o: init_rs.c
	gcc -DBIGSYM=1 $(CFLAGS) -c -o $@ $^

.PHONY : clean

clean:
	rm -rf *.o libsfrsd.a rsdtest.exe rsdtest2.exe rsdtest3.exe sfrsd
