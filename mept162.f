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
      real sstf(4,275)
      complex c(0:NFFT1),c2(65536)
      data first/.true./
      save

      end file 14
      rewind 14

C  Mix 1500 Hz +/- 100 Hz to baseband, and downsample by 1/32
      call mix162(id,npts,c,c,c2,jz,df2,ps)

C  Look for sync patterns, get DF and DT
      call sync162(c2,jz,dtx,dfx,snrx,snrsync,sstf,kz)
      call spec162(c2,jz)

      siglev=20.0*log10(rms/300.0) 
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
           call decode162(c2,jz,dtx,dfx,message,ncycles,metric,nerr)
           i2=index(outfile,'.')-1
           datetime=outfile(i2-10:i2)
           datetime(7:7)=' '
           write(13,1010) datetime,nsync,nsnrx,dtx,freq,message
           write(14,1010) datetime,nsync,nsnrx,dtx,freq,message,
     +          siglev,nsec/120,nint(dfx)
 1010      format(a11,i4,i4,f6.1,f11.6,2x,a15,f8.1,i9,i4)
         endif
      enddo

      return
      end
