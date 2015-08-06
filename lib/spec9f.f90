subroutine spec9f(id2,npts,nsps,s1,jz,nq)

! Compute "fast-JT9" symbol spectra at quarter-symbol steps.

  integer*2 id2(0:npts)
  real s1(nq,jz)
  real x(480)
  complex c(0:240)
  equivalence (x,c)

  nh=nsps
  nfft=2*nh                               !FFTs at twice the symbol length
  do j=1,jz
     ia=(j-1)*nsps/4
     ib=ia+nsps-1
     if(ib.gt.npts) exit
     x(1:nh)=id2(ia:ib)
     x(nh+1:)=0.
     call four2a(x,nfft,1,-1,0)           !r2c
     k=mod(j-1,340)+1
     do i=1,NQ
        s1(i,j)=1.e-10*(real(c(i))**2 + aimag(c(i))**2)
     enddo
  enddo

  return
end subroutine spec9f
