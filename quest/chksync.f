      subroutine chksync(s2,nn,nsyncok,snrsync)

      real s2(64,79)
      real ccf(0:55)
      integer nc8(8)
      data nc8/3,6,2,4,5,0,7,1/
      save

      nd1=nn/2
      do lag=0,17
         sum=0.
         do j=1,8
            i=nc8(j)
            sum=sum + s2(i,lag+j) + s2(i,lag+j+nd1+8)
         enddo
         ccf(lag)=sum
      enddo

      smax=-1.e30
      do i=0,17
         if(ccf(i).gt.smax) then
            smax=ccf(i)
            i1=i
         endif
      enddo

      snrsync=(ccf(0)-2.0)/4.0
      nsyncok=0
      if(i1.eq.0) nsyncok=1

      return
      end
