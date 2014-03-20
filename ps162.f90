subroutine ps162(c2,s)

  parameter (NFFT=512,NH=256)
  complex c2(0:NFFT)
  real s(-NH:NH)
  complex c(0:NFFT)
  common/fftcom2/c       !This keeps the absolute address of c() constant

  do i=0,NH-1
     c(i)=c2(i)
  enddo
  do i=nh,nfft-1
     c(i)=0.
  enddo

  call four2a(c,nfft,1,-1,1)

  fac=1.0/nfft
  do i=0,NFFT-1
     j=i
     if(j.gt.NH) j=j-NFFT
     s(j)=fac*(real(c(i))**2 + aimag(c(i))**2)
  enddo
  s(-NH)=s(-NH+1)

  return
end subroutine ps162
