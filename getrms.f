      subroutine getrms(iwave,npts,ave,rms)

      parameter (NMAX=120*12000)
      integer*2 iwave(NMAX)
      real*8 sq

      s=0.
      do i=1,npts
         s=s + iwave(i)
      enddo
      ave=s/npts
      sq=0.
      do i=1,npts
         sq=sq + (iwave(i)-ave)**2
      enddo
      rms=sqrt(sq/npts)
      fac=3000.0/rms
      do i=1,npts
         n=nint(fac*(iwave(i)-ave))
         if(n.gt.32767) n=32767
         if(n.lt.-32767) n=-32767
         iwave(i)=n
      enddo

      if(npts.lt.NMAX) then
         do i=npts+1,NMAX
            iwave(i)=0
         enddo
      endif

      if(rms.lt.2000.0) print*,'*** Bad Rx data? *** ',ave,rms

      return
      end
