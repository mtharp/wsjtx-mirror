      subroutine ccf2(ss,nz,ccfbest,lagpk)

!      parameter (LAGMAX=20)
      parameter (LAGMAX=200)
      real ss(nz)
      real ccf(-LAGMAX:LAGMAX)
      real pr(162)
      logical first

C  The WSPR pseudo-random sync pattern:
      integer npr(162)
      data npr/
     +       1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,
     +       0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,
     +       0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,
     +       1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,
     +       0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,
     +       0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,
     +       0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,
     +       0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,
     +       0,0/
      data first/.true./
      save

      if(first) then
         nsym=162
         do i=1,nsym
            pr(i)=2*npr(i)-1
         enddo
      endif

      ccfbest=0.
      lag1=-LAGMAX
      lag2=LAGMAX

      do lag=lag1,lag2
         x=0.
         do i=1,nsym
            j=16*i + lag
            if(j.ge.1 .and. j.le.nz) x=x+ss(j)*pr(i)
         enddo
         ccf(lag)=x
         if(ccf(lag).gt.ccfbest) then
            ccfbest=ccf(lag)
            lagpk=lag
         endif
      enddo

!      rewind 14
!      do i=lag1,lag2
!         write(14,3001) i,ccf(i)
! 3001    format(i5,f12.3)
!      enddo

      return
      end
