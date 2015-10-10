subroutine jt65a(dd0,npts,newdat,nutc,nf1,nf2,nfqso,ntol,nsubmode,   &
     minsync,nagain,ndecoded)

!  Process dd0() data to find and decode JT65 signals.

  parameter (NSZ=3413,NZMAX=60*12000)
  parameter (NFFT=8192)
  real dd0(NZMAX)
  real dd(NZMAX)
  real ss(322,NSZ)
  real savg(NSZ)
  real a(5)
  character*22 decoded,decoded0
  type candidate
     real freq
     real dt
     real sync
  end type candidate
  type(candidate) ca(300)
  common/decstats/num65,numbm,numkv,num9,numfano
  save

  dd=0.
  tpad=2.0
  npad=12000*tpad
  dd(1+npad:npts+npad)=dd0(1:npts)
  npts=npts+npad

!  if(newdat.ne.0) then
     call timer('symsp65 ',0)
     ss=0.
     call symspec65(dd,npts,ss,nhsym,savg)    !Get normalized symbol spectra
     call timer('symsp65 ',1)
!  endif
  nfa=nf1
  nfb=nf2
!  if(newdat.eq.0) then
  if(newdat.eq.0 .or. nfqso.eq.1270) then
     nfa=nfqso-ntol
     nfb=nfqso+ntol
  endif

  ncand=0
  call timer('sync65  ',0)
  call sync65(ss,nfa,nfb,nhsym,ca,ncand)    !Get a list of JT65 candidates
  call timer('sync65  ',1)

  df=12000.0/NFFT                     !df = 12000.0/8192 = 1.465 Hz
  mode65=2**nsubmode
  nflip=1                             !### temporary ###
  nqd=0
  decoded0=""

  do icand=1,ncand
     freq=ca(icand)%freq
     dtx=ca(icand)%dt
     sync1=ca(icand)%sync
     call timer('decod65a',0)
     call decode65a(dd,npts,newdat,nqd,freq,nflip,mode65,sync2,a,dtx,   &
          nbmkv,nhist,decoded)
     call timer('decod65a',1)
     if(decoded.eq.decoded0) cycle            !Don't display dupes

!     if(decoded.ne.'                      ') then
     if(decoded.ne.'                      ' .or. minsync.lt.0) then
        ndecoded=1
        nfreq=nint(freq+a(1))
        ndrift=nint(2.0*a(2))
        s2db=10.0*log10(sync2) - 32             !### empirical (was 40) ###
        nsnr=nint(s2db)
        if(nsnr.lt.-30) nsnr=-30
        if(nsnr.gt.-1) nsnr=-1
        dtx=dtx-tpad
        if(nbmkv.eq.1) numbm=numbm+1
        if(nbmkv.eq.2) numkv=numkv+1

! Serialize writes - see also decjt9.f90
!$omp critical(decode_results) 

        write(*,1010) nutc,nsnr,dtx,nfreq,decoded
1010    format(i4.4,i4,f5.1,i5,1x,'#',1x,a22)
        write(13,1012) nutc,nint(sync1),nsnr,dtx,float(nfreq),ndrift,  &
             decoded,nbmkv
1012    format(i4.4,i4,i5,f6.1,f8.0,i4,3x,a22,' JT65',i4)
        call flush(6)
        call flush(13)
        decoded0=decoded
!$omp end critical(decode_results)
     endif
  enddo

!     if(nagain.eq.1) exit
!  enddo

  return
end subroutine jt65a
