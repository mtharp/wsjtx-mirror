subroutine ccf2(ss,nz,lag1,lag2,ccfbest,lagpk)

  real ss(nz)
  real pr(162)
  logical first

! The WSPR pseudo-random sync pattern:
  integer npr(162)
  data npr/                                     &
       1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0, &
       0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1, &
       0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1, &
       1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1, &
       0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0, &
       0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1, &
       0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1, &
       0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0, &
       0,0/
  data first/.true./
  save

  if(first) then
     nsym=162
     do i=1,nsym
        pr(i)=2*npr(i)-1
     enddo
  endif

  ccfbest=0.

  do lag=lag1,lag2
     x=0.
     do i=1,nsym
        j=16*i + lag
        if(j.ge.1 .and. j.le.nz) x=x+ss(j)*pr(i)
     enddo
     if(x.gt.ccfbest) then
        ccfbest=x
        lagpk=lag
     endif
  enddo

  return
end subroutine ccf2
