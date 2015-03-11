subroutine lpf1(dat,jz,nz,mousedf,mousedf2)

  parameter (NMAX=1024*1024)
  real dat(jz)
  complex c(0:NMAX)

  write(*,*) 'aa',jz; flush(6)

! Find FFT length
  xn=log(float(jz))/log(2.0)
  n=xn
  if((xn-n).gt.0.) n=n+1
  nfft=2**n
  nh=nfft/2
  write(*,*) 'b',nfft,nmax,nh; flush(6)

! Load data into real array x; pad with zeros up to nfft.
  c(1:jz)=dat(1:jz)
  c(jz+1:nfft)=0.0
  call four2a(c,nfft,1,-1,1)
  df=11025.0/nfft
  write(*,*) 'c',df

  ia=70/df
  c(:ia)=0.
  ib=5000.0/df
  c(ib:)=0.

  call four2a(c,nh,1,1,-1)        !Return to time domain
  fac=1.0/nfft
  nz=jz/2
  do i=1,nz
     dat(i)=fac*x(i)
  enddo


  return
end subroutine lpf1

