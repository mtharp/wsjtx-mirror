subroutine spec_iscat(dat,jz,s0,nsteps)

! Compute FFTs of twice the symbol length, stepped by quarter symbols.  
! Save 2d power spectra in s0(256,nsteps).

  real dat(jz)                      !Raw data, 12000 Hz sample rate
  real s0(256,2812)                 !2d spectrum, stepped by half-symbols
  real x(1024)
  real xs1(512)

  nfft=1024
  nh=nfft/2
  nq=nfft/4
  nsteps=4*(jz-NH)/nh
  kstep=nh/4

! Compute the power spectrum for each quarter-symbol step
  do j=1,nsteps
     k=(j-1)*kstep + 1
     x(1:nh)=dat(k:k+nh-1)
     x(nh+1:)=0.
     call ps(x,nfft,xs1)
     s0(1:nq,j)=xs1(1:nq)
  enddo

  return
end subroutine spec_iscat
