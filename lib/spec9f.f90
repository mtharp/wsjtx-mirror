subroutine spec9f(id2,npts,nsps,s1,jz,nq,s2)

  integer*2 id2(0:npts)
  real s1(jz,nq)
  real s2(340,nq)
  real x(480)
  complex c(0:240)
  equivalence (x,c)

  nh=nsps
  nfft=2*nh
  do j=1,jz
     ia=(j-1)*nsps/4
     ib=ia+nsps-1
     if(ib.gt.npts) exit
     x(1:nh)=id2(ia:ib)
     x(nh+1:)=0.
     call four2a(x,nfft,1,-1,0)           !r2c
     k=mod(j-1,340)+1
     do i=1,NQ
        t=1.e-10*(real(c(i))**2 + aimag(c(i))**2)
        s1(j,i)=t
        s2(k,i)=s2(k,i)+t
     enddo
  enddo

  return
end subroutine spec9f
