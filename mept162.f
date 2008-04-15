      subroutine mept162(outfile,f0,minsync,id,npts,rms,nsec,ltest,ndec)

C  Orchestrates the process of decoding MEPT_JT messages.

      integer*2 id(npts)

      parameter (NFFT1=2*1024*1024,NH1=NFFT1/2)
      character*22 message
      character*70 outfile
      character*11 datetime
      logical first,skip
      real*8 f0
      real ps(-128:128)
      real sstf(275)
      real s2(-127:128)
      real p(-137:137),tmp(275),snr(-137:137)
      integer np(-137:137)
      real a(5)
      real x(NFFT1)
      complex c(0:NFFT1),c2(65536),c3(65536)
      equivalence (x,c)
      data first/.true./
      save

      fac=1.e-8
      do i=1,npts
         x(i)=fac*id(i)
      enddo
      do i=npts+1,NFFT1
         x(i)=0.
      enddo
      call xfft(x,NFFT1)
      nadd=128
      df1=nadd*12000.0/NFFT1
      ia=nint(1400/df1)
      ib=nint(1600/df1)
      i0=nint(1500/df1)
      do i=ia,ib
         sq=0.
         do n=1,nadd
            k=(i-1)*nadd + n
            sq=sq + real(c(k))**2 + aimag(c(k))**2
         enddo
         freq=i*df1 - 1500 + 150
         p(i-i0)=sq
      enddo

      call pctile(p(-137),tmp,275,45,base)

      rewind 53
      do i=-137,137
         sig=p(i)/base - 1.0
         snr(i)=-33.
         if(sig.gt.0.) snr(i)=10.0*log10(sig) - 27
         p(i)=10.0*log10((p(i)/base))
      enddo

      plim=3.0
      do i=-132,132
         pp=0.
         np(i)=0
         pmin=1.e30
         do k=-3,3
            pp=pp+p(i)
            pmin=min(p(i),pmin)
         enddo
         pp=pp/7.0
         if(pp.gt.plim .and. p(i-5).lt.pp-2 .and. p(i+5).lt.pp-2 .and.
     +           pmin.gt.pp-2) then
            np(i-3)=1
            np(i-2)=1
            np(i-1)=1
            np(i)=1
            np(i+1)=1
            np(i+2)=1
         endif
      enddo

C  Mix 1500 Hz +/- 100 Hz to baseband, and downsample by 1/32
      call mix162(id,npts,c,c,c2,jz,df2,ps)

C  Look for sync patterns, get DF and DT
      call spec162(c2,jz,s2)
!      call sync162(s2,sstf,kz)

      baud=12000.0/8192.0
!      do k=1,kz
      skip=.false.
      do i=-132,132
         if(skip .and. np(i).ne.0) go to 100
         if(np(i).eq.0) then
            skip=.false.
            go to 100
         endif
         df2=i*df1
         ccfbest=-1.e30
         do kk=-5,5
!            do jj=-10,10
!               df2=sstf(k) + 0.25*baud*jj
            a(1)=-df2
            a(2)=0.25*baud*kk
            a(3)=0.
            ccf=fchisq(c2,jz,375.0,a,ccfx,dtxx)
            if(ccfx.gt.ccfbest) then
               ccfbest=ccfx
               dtbest=dtxx-2.0
               a1=a(1)
               a2=a(2)
            endif
         enddo

         sync=0.
         if(ccfbest.gt.0.0) sync=10.0*log10(ccfbest)
         nsync=nint(sync)
         df2=-a1 + 1.5
         dtx=dtbest
         nsnrx=nint(snr(i))
         message='                      '
        if(nsync.ge.minsync) then
            freq=f0 + 1.d-6*(df2+1500.0)
            a(1)=0.
            a(2)=a2
            a(3)=0.
            call twkfreq(c2,c3,jz,a)
            call decode162(c3,jz,dtbest,df2,message,ncycles,metric,nerr)
            if(message.eq.'                      ') go to 100

            ndec=1
            i2=index(outfile,'.')-1
            datetime=outfile(i2-10:i2)
            datetime(7:7)=' '
            if(ltest) then
               write(*,1012) datetime,nsnrx,dtx,freq,nf1,message,-a(3)
            else

#ifdef CVF
               open(13,file='ALL_MEPT.TXT',status='unknown',
     +                position='append',share='denynone')
#else
               open(13,file='ALL_MEPT.TXT',status='unknown',
     +                position='append')
#endif
               nf1=nint(-2.0*a(2))
               write(13,1010) datetime,nsync,nsnrx,dtx,freq,message,nf1
               close(13)
 1010          format(a11,i4,i4,f6.1,f11.6,2x,a15,i5)

               write(14,1012) datetime,nsnrx,dtx,freq,nf1,message,-a(3)
 1012          format(a11,i4,f6.1,f11.6,i4,2x,a15,f7.2)
            endif
            if(message(1:6).ne.'      ') skip=.true.
         endif
 100     continue
      enddo

      return
      end
