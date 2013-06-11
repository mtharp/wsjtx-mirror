subroutine jt65a(dd,npts,newdat,nutc,nfa,nfb,nfqso,ntol,nagain,ndiskdat)

!  Process dd() data to find and decode JT65 signals.

  parameter (NSZ=3413)
  parameter (NZMAX=60*12000)
  parameter (NFFT=8192)
  real dd(NZMAX)
  real*4 ss(322,NSZ)
  real*4 savg(NSZ)
  logical done(NSZ)
  real a(5)
  character decoded*22
  save

  call timer('symsp65 ',0)
  call symspec65(dd,npts,ss,nhsym,savg)    !Get normalized symbol spectra
  call timer('symsp65 ',1)

  df=12000.0/NFFT                     !df = 12000.0/16384 = 0.732 Hz
  ftol=15.0                           !Frequency tolerance (Hz)
  mode65=1
  done=.false.

  do nqd=1,0,-1
     if(nqd.eq.1) then                !Quick decode, at fQSO
        fa=nfqso - ntol
        fb=nfqso + ntol
     else                             !Wideband decode at all freqs
        fa=200.0
        fb=2700.0
     endif
     ia=max(51,nint(fa/df))
     ib=min(NSZ-51,nint(fb/df))

     freq0=-999.
     sync10=-999.
     thresh0=1.5

     do i=ia,ib                               !Search over freq range
        if(savg(i).lt.thresh0 .or. done(i)) cycle
        freq=i*df

        call timer('ccf65   ',0)
        call ccf65(ss(1,i),nhsym,savg(i),sync1,dt,flipk,syncshort,snr2,dt2)
        call timer('ccf65   ',1)

! ########################### Search for Shorthand Messages #################
!  include 'shorthand1.f90'

! ########################### Search for Normal Messages ###########
        thresh1=1.0
!  Use lower thresh1 at fQSO
        if(nqd.eq.1 .and. ntol.le.100) thresh1=0.
!  Is sync1 above threshold?
        if(sync1.lt.thresh1) cycle

!  Keep only the best candidate within ftol.
        if(freq-freq0.lt.ftol .or. sync1.lt.sync10) cycle
        nflip=nint(flipk)
        f0=i*df                   !Freq of detected sync tone (0-5000 Hz)

        call timer('decode1a',0)
        call decode1a(dd,npts,newdat,f0,nflip,mode65,nqd,   &
             nutc,ntol,sync2,a,dt,nkv,nhist,decoded)
        call timer('decode1a',1)

        if(decoded.ne.'                      ') then
           nfreq=nint(freq)
           s2db=10.0*log10(sync2) - 40             !### empirical ###
           nsnr=nint(s2db)
           if(nsnr.lt.-30) nsnr=-30
           if(nsnr.gt.-1) nsnr=-1
           write(*,1010) nutc,nsnr,dt,nfreq,decoded
1010       format(i4.4,i4,f5.1,i5,1x,'#',1x,a22)
           write(39,3010) nutc,decoded,sync1,s2db
3010       format(i4.4,2x,a22,2x,2f6.1)
           freq0=freq
           sync10=sync1
           i2=min(NSZ,i+10)                !### ??? ###
           done(i:i2)=.true.
        endif
     enddo
     if(nagain.eq.1) exit
  enddo

  call flush(39)
  return
end subroutine jt65a
