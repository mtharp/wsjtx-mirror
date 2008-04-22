      subroutine afc(cx,npts,a,ccfbest,dtbest)

      complex cx(npts)
      real a(5),deltaa(5)

      fsample=375.0
      lags=5
!      a(1)=0.
      a(2)=0.
      a(3)=0.
      a(4)=0.
      a(5)=0.

      deltaa(1)=0.73
      deltaa(2)=0.1
      deltaa(3)=0.1
      deltaa(4)=0.1
      deltaa(5)=0.1
      nterms=3

      chisqr=0.
      nfree=npts-nterms

C  Start the iteration
      free=nfree
      chisqr0=1.e6
      do iter=1,10                               !One iteration is enough?
         do j=1,nterms
            chisq1=fchisq(cx,npts,fsample,a,lags,ccfmax,dtmax)
            fn=0.
            delta=deltaa(j)
 10         a(j)=a(j)+delta
            chisq2=fchisq(cx,npts,fsample,a,lags,ccfmax,dtmax)
            if(chisq2.eq.chisq1) go to 10
            if(chisq2.gt.chisq1) then
               delta=-delta                      !Reverse direction
               a(j)=a(j)+delta
               tmp=chisq1
               chisq1=chisq2
               chisq2=tmp
            endif
 20         fn=fn+1.0
            a(j)=a(j)+delta
            chisq3=fchisq(cx,npts,fsample,a,lags,ccfmax,dtmax)
            if(chisq3.lt.chisq2) then
               chisq1=chisq2
               chisq2=chisq3
               go to 20
            endif

C  Find minimum of parabola defined by last three points
            delta=delta*(1./(1.+(chisq1-chisq2)/(chisq3-chisq2))+0.5)
            a(j)=a(j)-delta
            deltaa(j)=deltaa(j)*fn/3.
         enddo
         chisqr=fchisq(cx,npts,fsample,a,lags,ccfmax,dtmax)
         if(chisqr/chisqr0.gt.0.9999) go to 30
         chisqr0=chisqr
      enddo

 30   continue
!      ccfbest=ccfmax * (375.0/fsample)**2
      ccfbest=chisqr
      dtbest=dtmax
!      print*,'Z',iter,chisqr,chisqr0,chisqr/chisqr0

      return
      end
