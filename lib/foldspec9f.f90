subroutine foldspec9f(s1,jz,nq,s2)

! Fold the symbol spectra into 

  real s1(nq,jz)
  real s2(340,nq)

  do j=1,jz
     k=mod(j-1,340)+1
     do i=1,NQ
        s2(k,i)=s2(k,i) + s1(i,j)
     enddo
  enddo

  return
end subroutine foldspec9f
