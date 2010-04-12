subroutine analytic(d,npts,c)
  real d(npts)
  complex c(65536)

  xn=log(float(npts))/log(2.0)
  n=xn
  if(xn-n .gt.0.001) n=n+1
  nfft=2**n
  nh=nfft/2
  fac=2.0/nfft
  do i=1,npts
     c(i)=fac*d(i)
  enddo
  c(npts+1:nfft)=0.
  call four2a(c,nfft,1,-1,1)
  c(1)=0.5*c(1)
  c(nh+2:nfft)=0.
  call four2a(c,nfft,1,1,1)

  return
end subroutine analytic
