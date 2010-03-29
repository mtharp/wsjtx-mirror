      subroutine mept162(outfile,appdir,nappdir,f0,minsync,id,npts,
     +  nbfo,ierr)

C  Orchestrates the process of finding, synchronizing, and decoding 
C  WSPR signals.

      integer*2 id(npts)
      character*22 message
      character*80 outfile,appdir,alltxt
      character*11 datetime
      character cdate*8,ctime*10
      real*8 f0,freq,tsec
      real ps(-256:256)
      real sstf(5,275)
      real a(5)
      complex c2(65536)
      complex c3(45000),c4(45000)

C  Mix from "nbfo" +/- 100 Hz to baseband, and downsample by 1/32
      call mix162(id,npts,nbfo,c2,jz,ps)

C  Compute pixmap.dat
      call spec162(c2,jz,appdir,nappdir)

C  Look for sync patterns, get DF and DT
      call sync162(c2,jz,ps,sstf,kz)
      ierr = 0
      if(kz.eq.0) go to 900
      if (kz.gt.275 .or. kz.lt.0) then
        call getutc(cdate,ctime,tsec)

        call cs_lock('mept162')
        write(*,1000) ctime,kz
 1000   format('Time ',a8,'. Error from sync162: kz is',i10)
        call cs_unlock

        ierr = 1
        return
      endif
      do k=1,kz
         snrsync=sstf(1,k)
         snrx=sstf(2,k)
         dtx=sstf(3,k)
         dfx=sstf(4,k)
         drift=sstf(5,k)
         a(1)=-dfx
         a(2)=-0.5*drift
         a(3)=0.
         call twkfreq(c2,c3,jz,a)                    !Remove drift

         minsync=1                                   !####
         nsync=nint(snrsync)
         nsnrx=nint(snrx)
         if(nsnrx.lt.-33) nsnrx=-33
         if(nsync.lt.0) nsync=0
         freq=f0 + 1.d-6*(dfx+nbfo)
         message='                      '
         if(nsync.ge.minsync .and. nsnrx.ge.-33) then      !### -31 dB limit?

            dt=1.0/375
            do idt=0,128
               ii=(idt+1)/2
               if(mod(idt,2).eq.1) ii=-ii
               i1=nint((dtx+2.0)/dt) + ii !Start index for synced symbols
               if(i1.ge.1) then
!  Fix this earlier!
                  c4(1:jz-i1+1)=c3(i1:)
                  c4(jz-i1+2:)=0.
               else
                  c4(:-i1+1)=0.
                  c4(-i1+2:jz)=c3(:i1+jz-1)
                  if(jz.lt.45000) c4(jz:)=0.
               endif
               call decode162(c4,45000,message,ncycles,metric,nerr)
               if(message(1:6).ne.'      ' .and. 
     +            message(1:6).ne.'000AAA' .and.
     +            index(message,'A000AA').le.0) go to 23
            enddo
            go to 24

 23         i2=index(outfile,'.wav')-1
            if(i2.le.0) i2=index(outfile,'.WAV')-1
            datetime=outfile(i2-10:i2)
            datetime(7:7)=' '
            nf1=nint(-a(2))
            alltxt=appdir(:nappdir)//'/ALL_WSPR.TXT'

            call cs_lock('mept162a')
#ifdef CVF
            open(13,file=alltxt,status='unknown',position='append',
     +           share='denynone')
#else
            open(13,file=alltxt,status='unknown',position='append')
#endif
            write(13,1010) datetime,nsync,nsnrx,dtx,freq,message,nf1,
     +           ncycles/81,ii
            close(13)
            write(14,1010) datetime,nsync,nsnrx,dtx,freq,message,nf1,
     +           ncycles/81,ii
 1010       format(a11,i4,i4,f5.1,f11.6,2x,a22,i3,i6,i5)
            i1=index(message,' ')
            call cs_unlock

         endif
 24      continue
      enddo

 900  return
      end
