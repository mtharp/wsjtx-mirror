      subroutine mept162(outfile,f0,minsync,id,npts,rms,nsec,ltest,ndec)

C  Orchestrates the process of finding, synchronizing, and decoding 
C  WSPR signals.

      integer*2 id(npts)
      character*22 message
      character*70 outfile
      character*11 datetime
      logical first,ltest
      real*8 f0
      real ps(-256:256)
      real sstf(5,275)
      real a(5)
      complex c2(65536),c3(65536)
      data first/.true./
      save

C  Mix 1500 Hz +/- 100 Hz to baseband, and downsample by 1/32
      call mix162(id,npts,c2,jz,ps)

C  Compute pixmap.dat
      call spec162(c2,jz)

C  Look for sync patterns, get DF and DT
      call sync162(c2,jz,ps,sstf,kz)

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

         minsync=1                                   !####
         nsync=nint(snrsync)
         nsnrx=nint(snrx)
         if(nsnrx.lt.-33) nsnrx=-33
         if(nsync.lt.0) nsync=0
         freq=f0 + 1.d-6*(dfx+1500.0)
         message='                      '
         if(nsync.ge.minsync .and. nsnrx.ge.-33) then      !### -31 dB limit?
            call decode162(c3,jz,dtx,dfx,message,ncycles,metric,nerr)
            if(message(1:6).eq.'      ') go to 24
!            call rect(c3,dtx,dfx,message,dfx2,width,pmax)
!            write(51)(c3(j),j=1,45000),dtx,dfx,ncycles/81,metric,message
            i2=index(outfile,'.')-1
            datetime=outfile(i2-10:i2)
            datetime(7:7)=' '
            nf1=nint(-a(2))

#ifdef CVF
            open(13,file='ALL_MEPT.TXT',status='unknown',
     +                position='append',share='denynone')
#else
            open(13,file='ALL_MEPT.TXT',status='unknown',
     +                position='append')
#endif
            write(13,1010) datetime,nsync,nsnrx,dtx,freq,message,nf1,
     +           ncycles/81,metric
            close(13)
 1010       format(a11,i4,i4,f5.1,f11.6,2x,a22,i3,i6,i5,2f5.1)
            write(14,1012) datetime,nsnrx,dtx,freq,nf1,width,message
 1012       format(a11,i4,f5.1,f11.6,i3,f5.1,2x,a22)
            i1=index(message,' ')
            call bestdx(datetime,message(i1+1:i1+4))
         endif
 24      continue
      enddo

      return
      end
