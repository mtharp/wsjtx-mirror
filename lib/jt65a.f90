subroutine jt65a(dd,npts,newdat,nutc,ntol,nfa,nfb,nfqso,nagain,ndiskdat)

!  Process id2() data to find and decode JT65 signals.

  parameter (NSZ=3413)
  parameter (NZMAX=60*12000)
  parameter (NFFT=8192)              !### ??? ###
  real dd(NZMAX)
  real*4 ss(322,NSZ),savg(NSZ)
  real tavg(-50:50)                  !Temp for finding local base level
  real tmp (200)                     !Temp storage for pctile sorting
  real a(5)
  character decoded*22,blank*22
  data blank/'                      '/
  save

  call symspec65(dd,npts,ss,nhsym,savg)    !Get normalized symbol spectra

  df=12000.0/NFFT                     !df = 12000.0/16384 = 0.732 Hz
  ftol=10.0                           !Frequency tolerance (Hz)
  fqso=nfqso                      !fqso at baseband (Hz)
  mode65=1

  do nqd=0,0,-1
     if(nqd.eq.1) then                     !Quick decode, at fQSO
        fa=nfqso - ntol
        fb=nfqso + ntol
     else                                  !Wideband decode at all freqs
        fa=500.0
        fb=2500.0
     endif
     ia=max(51,nint(fa/df))
     ib=min(NSZ-51,nint(fb/df))

     freq0=-999.
     sync10=-999.
     thresh0=1.5

     ia=641
     ib=641

     do i=ia,ib                               !Search over freq range
        freq=i*df
        if(savg(i).lt.thresh0) cycle

        call timer('ccf65   ',0)
        call ccf65(ss(1,i),nhsym,savg(i),sync1,dt,flipk,syncshort,snr2,dt2)
        call timer('ccf65   ',1)

!        write(73,3003) i,freq,savg(i),sync1,dt,flipk
!3003    format(i6,5f9.2)
!        if(ia.gt.0) cycle

! ########################### Search for Shorthand Messages #################
!  include 'shorthand1.f90'

! ########################### Search for Normal Messages ###########
        thresh1=1.0
!  Use lower thresh1 at fQSO
        if(nqd.eq.1 .and. ntol.le.100) thresh1=0.
!  Is sync1 above threshold?
        if(sync1.lt.thresh1 .or. abs(noffset).gt.ntol) cycle

!  Keep only the best candidate within ftol.
        if(freq-freq0.lt.ftol .or. sync1.lt.sync10) cycle
        nflip=nint(flipk)
        f00=i*df                   !Freq of detected sync tone (0-5000 Hz)

        call timer('decode1a',0)
        call decode1a(dd,npts,newdat,f00,nflip,mode65,nqd,   &
             nutc,ntol,sync2,a,dt,nkv,nhist,decoded)
        call timer('decode1a',1)

        nfreq=nint(freq)
        nsync1=sync1

        s2db=10.0*log10(sync2) - 40             !### empirical ###
        nsync2=nint(s2db)
        if(decoded(1:4).eq.'RO  ' .or. decoded(1:4).eq.'RRR  ' .or.  &
             decoded(1:4).eq.'73  ') nsync2=nint(1.33*s2db + 2.0)

        write(*,1010) nutc,nsync2,dt,nfreq,decoded,nflip,newdat
1010    format(i4.4,i6,f6.1,i6,2x,a22,3x,2i3)
     enddo
     if(nagain.eq.1) go to 999
  enddo

999 close(23)
  nagain=0

  return
end subroutine jt65a
