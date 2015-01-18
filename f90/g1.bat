gcc -c gran.c
gfortran -o lor.exe -Wall -fbounds-check lor.f90 functn.f90 curfit.o fderiv.o fchisq.o matinv.o gran.o
