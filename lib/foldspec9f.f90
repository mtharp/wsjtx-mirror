subroutine foldspec9f(s1,jz,nq,s2)

! Fold symbol spectra (quarter-symbol steps) from s1 into s2

  real s1(nq,jz)
  real s2(340,nq)                       !340 = 4*85

  do j=1,jz
     k=mod(j-1,340)+1
     do i=1,NQ
        s2(k,i)=s2(k,i) + s1(i,j)
     enddo
  enddo

  return
end subroutine foldspec9f
