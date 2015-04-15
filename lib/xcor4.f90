subroutine xcor4(s2,ipk,nsteps,nsym,ich,mode4,ccfblue,ccf0,lagpk,flip)

! Computes ccf of the 4-FSK spectral array s2 and the pseudo-random 
! array pr2.  Returns peak of CCF and the lag at which peak occurs.  
! The CCF peak may be either positive or negative, with negative
! implying a message with report.

  use jt4
  parameter (NHMAX=1260)           !Max length of power spectra
  parameter (NSMAX=525)            !Max number of half-symbol steps
  real s2(NHMAX,NSMAX)             !2d spectrum, stepped by half-symbols
  real a(NSMAX)
  real ccfblue(65)
  data lagmin/0/                    !Silence compiler warning
  save

  ccfmax=0.
  ccfmin=0.
  nw=nch(ich)
  do j=1,nsteps
     n=2*mode4
     if(mode4.eq.1) then
        a(j)=max(s2(ipk+n,j),s2(ipk+3*n,j)) - max(s2(ipk  ,j),s2(ipk+2*n,j))
     else
        kz=max(1,nw/2)
        ss0=0.
        ss1=0.
        ss2=0.
        ss3=0.
        wsum=0.
        do k=-kz+1,kz-1
           w=float(kz-iabs(k))/nw
           wsum=wsum+w
           ss0=ss0 + w*s2(ipk    +k,j)
           ss1=ss1 + w*s2(ipk+  n+k,j)
           ss2=ss2 + w*s2(ipk+2*n+k,j)
           ss3=ss3 + w*s2(ipk+3*n+k,j)
        enddo
        a(j)=(max(ss1,ss3) - max(ss0,ss2))/sqrt(wsum)
     endif
  enddo

  do lag=1,65
     x=0.
     do i=1,nsym
        j=2*i-1+lag
        if(j.ge.1 .and. j.le.nsteps) x=x+a(j)*float(2*npr(i)-1)
     enddo
     ccfblue(lag)=x
     if(ccfblue(lag).gt.ccfmax) then
        ccfmax=ccfblue(lag)
        lagpk=lag
     endif

     if(ccfblue(lag).lt.ccfmin) then
        ccfmin=ccfblue(lag)
        lagmin=lag
     endif
  enddo

  zz(ipk,1:65,ich)=ccfblue
  ccf0=ccfmax
  flip=1.0
  if(-ccfmin.gt.ccfmax) then
! Negative peak was best
     ccfblue=-ccfblue
     lagpk=lagmin
     ccf0=-ccfmin
     flip=-1.0
  endif

  return
end subroutine xcor4
