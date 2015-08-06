subroutine sync9f(s2,nq,ss2,ss3,lagpk,ipk,ccfbest)

  integer ii4(16)
  real s2(340,nq)
  real ss2(0:8,85)
  real ss3(0:7,69)
  real ccf(0:340-1,10)
  include 'jt9sync.f90'

  ii4=4*ii-3
  ccf=0.
  ccfbest=0.
  do k=1,10
     do lag=0,339
        t=0.
        do i=1,16
           j=ii4(i)+lag
           if(j.gt.340) j=j-340
           t=t + s2(j,k)
        enddo
        ccf(lag,k)=t
        if(t.gt.ccfbest) then
           ccfbest=t
           lagpk=lag
           kpk=k
        endif
!        if(k.eq.7) write(14,3002) lag,ccf(lag,7)    !Blue
!3002    format(i6,f10.3)
     enddo
  enddo

!  do k=1,10
!     write(16,3002) k,ccf(lagpk,k)                  !Red
!  enddo

  ipk=7

  do i=0,8
     j4=lagpk-4
     i2=2*i + ipk
     m=0
     do j=1,85
        j4=j4+4
        if(j4.gt.340) j4=j4-340
        if(j4.lt.1) j4=j4+340
        ss2(i,j)=s2(j4,i2)
        if(i.ge.1 .and. isync(j).eq.0) then
           m=m+1
           ss3(i-1,m)=ss2(i,j)
        endif
     enddo
  enddo

!  do j=1,85
!     write(15,3003) j,ss2(0:8,j)
!3003 format(i2,9f8.2)
!  enddo

! ###########################################

  return
end subroutine sync9f
