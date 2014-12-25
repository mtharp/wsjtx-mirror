subroutine cspec(c,fdop,cs)

  parameter (NFFT=256*1024,NTX=27*8192)
  complex c(0:NFFT-1)
  complex ct(0:NFFT-1)
  complex cs(-1000:1000)     !Complex spectrum +/- 1000 bins from expected echo
  real s(0:NFFT-1)
  logical first
  data first/.true./
  save first

  if(first) s=0.
  first=.false.

  fsample=96000.0
  fac=1.0/NFFT
  ct(0:NTX-1)=fac*conjg(c(0:NTX-1))
  ct(NTX:)=0.
  call four2a(ct,NFFT,1,-1,1)
  df=fsample/NFFT
  i0=nint((fdop+48000.0)/df)
  cs=ct(i0-1000:i0+1000)

!  rewind 24
!  do i=0,NFFT-1
!     s(i)=s(i) + real(ct(i))**2 + aimag(ct(i))**2
!     write(24,3001) i*df-48000.0,s(i)
!3001 format(f10.3,e12.3)
!  enddo
!  call flush(24)

  return
end subroutine cspec
