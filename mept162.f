      subroutine mept162(outfile,f0,minsync,id,npts,rms,nsec)

C  Orchestrates the process of decoding MEPT_JT messages.

      integer*2 id(npts)

      parameter (NFFT1=2*1024*1024)
      character*22 message
      character*70 outfile
      character*11 datetime
      logical first
      real*8 f0
      real ps(-128:128)
      real sstf(8,275)
      real a(5)
      complex c(0:NFFT1),c2(65536),c3(65536)
      data first/.true./
      save

      write(14,1000)
 1000 format('$EOF')
      rewind 14

C  Mix 1500 Hz +/- 100 Hz to baseband, and downsample by 1/32
      call mix162(id,npts,c,c,c2,jz,df2,ps)

C  Look for sync patterns, get DF and DT
      call sync162(c2,jz,dtx,dfx,snrx,snrsync,sstf,kz)
      call spec162(c2,jz)

      siglev=20.0*log10(rms/300.0)  
!      do k=kz,1,-1
      do k=1,kz
         snrsync=sstf(1,k)
         snrx=sstf(2,k)
         dtx=sstf(3,k)
         dfx=sstf(4,k)
         nsync=nint(snrsync)
         if(nsync.lt.0) nsync=0
         nsnrx=nint(snrx)
         if(nsnrx.lt.-33) nsnrx=-33
         freq=f0 + 1.d-6*(dfx+1500.0)
         message='                      '
         if(nsync.ge.minsync) then
            do jj=-15,15
               a(1)=-sstf(6,k) -0.55 + 0.3*jj
               a(2)=0.
               a(3)=0.
               ccf=fchisq(c2,jz,375.0,a,ccfbest,dtbest)
               call afc(c2,jz,a,ccfbest,dtbest)
               call twkfreq(c2,c3,jz,a)
               call decode162(c3,jz,dtx,0.0,message,ncycles,metric,nerr)
               write(*,3001) jj,sstf(6,k),a(1),a(2),a(3),dtbest,
     +                ccfbest,message
 3001          format(i4,6f8.2,2x,a22)
            enddo
            i2=index(outfile,'.')-1
            datetime=outfile(i2-10:i2)
            datetime(7:7)=' '
            write(13,1010) datetime,nsync,nsnrx,dtx,freq,message
            write(14,1010) datetime,nsync,nsnrx,dtx,freq,message,
     +           -a(1),-a(2),-a(3)
 1010       format(a11,i4,i4,f6.1,f11.6,2x,a15,3f7.2)
         endif
      enddo

      return
      end
