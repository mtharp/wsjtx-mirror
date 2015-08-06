subroutine foldspec9f(s1,nq,jz,ja,jb,s2)

! Fold symbol spectra (quarter-symbol steps) from s1 into s2

  real s1(nq,jz)
  real s2(340,nq)                       !340 = 4*85
  integer nsum(340)

  s2=0.
  nsum=0

  do j=ja,jb
     k=mod(j-1,340)+1
     nsum(k)=nsum(k)+1
     do i=1,NQ
        s2(k,i)=s2(k,i) + s1(i,j)
     enddo
  enddo

  do k=1,340
     fac=1.0
     if(nsum(k).gt.0) fac=1.0/nsum(k)
     s2(k,1:nq)=fac*s2(k,1:nq)
  enddo

  return
end subroutine foldspec9f
