program test

! Test program for finding good approximations to correct f, fdot
! of WSPR transmissions.  Most of this code will become the wspr_sync()
! routine.

  parameter (NFFT=512,NH=256)
  parameter (LAGMAX=12)
  complex c2(45000)
  real s2(-NH:NH,351)
  real psmo(-NH:NH)
  real psavg(-NH:NH)
  real freq(-NH:NH)
  real p1(-NH:NH)
  real drift(-NH:NH)
  real dtx(-NH:NH)
  real sstf(5,275)
  character*32 infile
  character*22 message

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: test <infile>'
     go to 999
  endif

  call getarg(1,infile)
  open(55,file=infile,form='unformatted',status='old')
  read(55) jz,c2,s2,psavg

  call sync162a(c2,jz,s2,psavg,sstf,kz)

  call mept162a(c2,jz,sstf,kz)

999 end program test

