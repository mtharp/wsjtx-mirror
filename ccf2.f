      subroutine ccf2(ss,nz,ccfbest,lagpk)

!      parameter (LAGMAX=20)
      parameter (LAGMAX=200)
      real ss(nz)
      real ccf(-LAGMAX:LAGMAX)

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

      ccfbest=0.
      lag1=-LAGMAX
      lag2=LAGMAX
      nsym=162

      do lag=lag1,lag2
         s0=0.
         s1=0.
         do i=1,nsym
            j=2*(8*i + 43) + lag
            if(j.ge.1 .and. j.le.nz-8) then
               x=ss(j)+ss(j+8)
               if(npr(i).eq.0) then
                  s0=s0 + x
               else
                  s1=s1 + x
               endif
            endif
         enddo
         ccf(lag)=s1-s0
         if(ccf(lag).gt.ccfbest) then
            ccfbest=ccf(lag)
            lagpk=lag
         endif
      enddo

      return
      end
