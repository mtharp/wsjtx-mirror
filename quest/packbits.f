      subroutine packbits(dbits,nsymd,m0,sym)

C  Pack 0s and 1s from dbits() into sym() with m0 bits per byte.
C  NB: nsymd is the number of packed output bytes.

      integer sym(nsymd)
      integer*1 dbits(*)

      k=0
      do i=1,nsymd
         n=0
         do j=1,m0
            k=k+1
            n=n+n+dbits(k)
         enddo
         sym(i)=n
      enddo

      return
      end
