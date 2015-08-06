subroutine sync9f(s2,nq,nfa,nfb,ss2,ss3,ipk,ccfbest)

! Look for JT9 sync pattern in the folded symbol spectra, s2.
! Frequency search extends from nfa to nfb.  Synchronized symbol
! spectra are put into ss2() and ss3().

  integer ii4(16)
  real s2(340,nq)
  real ss2(0:8,85)
  real ss3(0:7,69)
  real ccf(0:340-1,160)              !### What should 2nd bound be? ###
  include 'jt9sync.f90'

  ii4=4*ii-3
  ccf=0.
  ccfbest=0.
  nfft=4*nq
  df=12000.0/nfft
  k1=nfa/df
  k2=nfb/df + 0.9999
!  print*,nfft,k1,k2,k1*df,k2*df

  do k=k1,k2
     do lag=0,339
        t=0.
        do i=1,16
           j=ii4(i)+lag
           if(j.gt.340) j=j-340
           t=t + s2(j,k)
        enddo
        ccf(lag,k)=t
        if(t.gt.ccfbest) then
           lagpk=lag
           kpk=k
           ccfbest=t
!           print*,lagpk,kpk,kpk*df,ccfbest
        endif
     enddo
  enddo

  ipk=kpk

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
