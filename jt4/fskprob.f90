program fskprob

! Compute probability distributions for power values in non-coherent FSK
!   p0 - pdf for channel(s) with no signal
!   p1 - pdf for channel with signal

! Assume average power is normalized to 1.0 in the no-signal channels

  character*12 arg

  nargs=iargc()
  if(nargs.ne.2) then
     print*,'Usage: fskprob nadd amp'
     go to 999
  endif

  call getarg(1,arg)
  read(arg,*) nadd
  call getarg(2,arg)
  read(arg,*) amp

  n=2*nadd
  s=amp*sqrt(float(nadd))
  a1=-0.5*n*log(2.0) - gammln(0.5d0*n)
  sum0=0.
  sum1=0.
  p1z=-999.

  do i=0,100000
     y=0.01*i
     p0=pdfChisq(y,n,0.0)
     p1=pdfChisq(y,n,s)

     if(p1.le.p0) then
        sum0=sum0+p0
        sum1=sum1+p1
     endif

     write(70,1010) y/n,p0,p1,sum0,sum1
1010 format(f10.6,4e15.6)
     if(p1.lt.p1z .and. p1.lt.1.e-6) exit
     p1z=p1
  enddo

  sum0=0.01*sum0
  sum1=0.01*sum1
  ber=sum1/sum0
  write(*,1020) ber
1020 format('2-FSK BER:',f8.3)

999 end program fskprob
