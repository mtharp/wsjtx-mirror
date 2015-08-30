subroutine analytic(d,npts,nfft,c)

! Convert real data to analytic signal

  parameter (NFFTMAX=512*1024)
  real d(npts)
  complex c(NFFTMAX)

  df=12000.0/nfft
  nh=nfft/2
  fac=2.0/nfft
  c(1:npts)=fac*d(1:npts)
  c(npts+1:nfft)=0.
  call four2a(c,nfft,1,-1,1)               !Forward c2c FFT

!  do i=1,nh
!     f=(i-1)*df
!     s(i)=real(c(i))**2 + aimag(c(i))**2
!     write(12,3001) f,s(i),db(s(i))
!3001 format(3f12.3)
!  enddo

  ia=500.0/df
  c(1:ia)=0.
  ib=2500.0/df
  c(ib:nfft)=0.

  c(1)=0.5*c(1)                            !Half of DC term
  c(nh+2:nfft)=0.                          !Zero the negative frequencies
  call four2a(c,nfft,1,1,1)                !Inverse c2c FFT

  return
end subroutine analytic
