subroutine analytic(d,npts,c,fshort,smax)
  real d(npts)
  real s(32768)
  complex c(65536)

  xn=log(float(npts))/log(2.0)
  n=xn
  if(xn-n .gt.0.001) n=n+1
  nfft=2**n
  nh=nfft/2
  nq=nfft/4
  fac=2.0/nfft
  do i=1,npts
     c(i)=fac*d(i)
  enddo
  c(npts+1:nfft)=0.
  call four2a(c,nfft,1,-1,1)
  do i=1,nq
     s(i)=real(c(i))**2 + aimag(c(i))**2
  enddo
  call smooth(s,nq)
  call pctile(s,s(nq+1),nq,50,base)
  df=12000.0/nfft
  fac=1.0/base
  smax=0.
  do i=1,nq
     x=fac*s(i)
     s(i)=-10.0
     if(x.gt.0.0) s(i)=db(x)
     if(s(i).gt.smax) then
        smax=s(i)
        fshort=i*df
     endif
  enddo

  c(1)=0.5*c(1)
  c(nh+2:nfft)=0.
  call four2a(c,nfft,1,1,1)

  return
end subroutine analytic
