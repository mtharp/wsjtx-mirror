subroutine iqdemod(kwave,iwave,npts,nfiq,iqrx)

  parameter (NFFT =5760000)
  parameter (NFFT4=1440000)
  integer*2 kwave(2,npts)
  integer*2 iwave(npts)
  real*8 twopi,dt,df,f0,pha,dpha
  complex c(0:NFFT-1)
  real x1(NFFT4)
  complex c1(0:NFFT4-1)
  equivalence (x1,c1)

  twopi=8.d0*atan(1.d0)
  dt=1.d0/48000.d0
  df=48000.d0/NFFT
  f0=nfiq
  dpha=twopi*f0*dt
  pha=0.d0
  do i=1,npts
     if(iqrx.eq.0) then
        x=kwave(2,i)
        y=kwave(1,i)
     else
        x=kwave(1,i)
        y=kwave(2,i)
     endif
     c(i-1)=cmplx(x,y)
  enddo
  c(npts:)=0.

  call four2a(c,NFFT,1,-1,1)

  ia=nint(f0/df)
  ib=nint((f0+5000.d0)/df)
  j=-1
  fac=1.0/NFFT
  do i=ia,ib
     j=j+1
     c1(j)=fac*c(i)
  enddo
  c(j+1:)=0.
  c1(0)=0.

  call four2a(c1,NFFT4,1,1,-1)

  sq=0.
  do i=1,npts/4
     sq=sq + x1(i)**1
     iwave(i)=nint(x1(i))
  enddo
  rms=sqrt(sq/(npts/4.0))

  print*,'a:',rms

  return
end subroutine iqdemod
