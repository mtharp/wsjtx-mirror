      subroutine mept162(outfile,f0,minsync,id,npts,rms,nsec,ltest,ndec)

C  Orchestrates the process of decoding MEPT_JT messages.

      integer*2 id(npts)

      parameter (NFFT1=2*1024*1024)
      character*22 message
      character*70 outfile
      character*11 datetime
      logical first,ltest
      real*8 f0
      real ps(-128:128)
      real sstf(5,275)
      real a(5)
      complex c(0:NFFT1),c2(65536),c3(65536)
      data first/.true./
      save

!      end file 14
!      rewind 14

C  Mix 1500 Hz +/- 100 Hz to baseband, and downsample by 1/32
      call mix162(id,npts,c,c,c2,jz,df2,ps)

C  Look for sync patterns, get DF and DT
!      a(1)=0.
!      a(2)=-0.5*12000.0/8192.
!      a(3)=0.
!      print*,'A',a
!      call twkfreq(c2,c3,jz,a)
!      c2=c3

      call sync162(c2,jz,sstf,kz)
      call spec162(c2,jz)

      do k=1,kz
         snrsync=sstf(1,k)
         snrx=sstf(2,k)
         dtx=sstf(3,k)
         dfx=sstf(4,k)
         drift=sstf(5,k)

         a(1)=0.
         a(2)=-0.5*drift
         a(3)=0.
         call twkfreq(c2,c3,jz,a)                    !Remove drift

         minsync=0                                   !####
         nsync=nint(snrsync)
         if(nsync.lt.0) nsync=0
         nsnrx=nint(snrx)
         if(nsnrx.lt.-33) nsnrx=-33
         freq=f0 + 1.d-6*(dfx+1500.0)
         message='                      '
         if(nsync.ge.minsync) then
            call decode162(c3,jz,dtx,dfx,message,ncycles,metric,nerr)
            i2=index(outfile,'.')-1
            datetime=outfile(i2-10:i2)
            datetime(7:7)=' '
            nf1=nint(-2.0*a(2))
!           write(13,1010) datetime,nsync,nsnrx,dtx,freq,message
            write(*,1010) datetime,nsync,nsnrx,dtx,freq,message,nf1
 1010       format(a11,i4,i4,f6.1,f11.6,2x,a15,i5)
         endif
 24      continue
      enddo

      return
      end
