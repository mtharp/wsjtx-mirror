subroutine wsjt4(dat,npts,nutc,NClearAve,ntol,emedelay,dttol,    &
     mode4,minw,mycall,hiscall,hisgrid,nfqso,NAgain,ndepth,neme)

! Orchestrates the process of decoding JT4 messages, using data that 
! have been 2x downsampled.

! NB: JT4 presently looks for only one decodable signal in the FTol 
! range -- analogous to the nqd=1 step in JT9 and JT65.

  use jt4
  real dat(npts)                                     !Raw data
  logical first
  character decoded*22,special*5
  character*22 avemsg,deepmsg,deepave,blank
  character csync*1,cqual*3
  character*12 mycall
  character*12 hiscall
  character*6 hisgrid
  data first/.true./,nutc0/-999/,nfreq0/-999999/
  save

  if(first) then
     nsave=0
     first=.false.
     blank='                      '
     ccfblue=0.
     ccfred=0.
     if(nspecial.eq.999) go to 900        !Silence compiler warning
     nagain=0                             !Ditto
  endif

  zz=0.
  syncmin=1.0
  naggressive=0
  if(ndepth.ge.2) naggressive=1
  nq1=3
  nq2=6
  if(naggressive.eq.1) nq1=1
  if(NClearAve.ne.0) then
     nsave=0
     iutc=-1
     nfsave=0.
     listutc=0
     ppsave=0.
     rsymbol=0.
     dtsave=0.
     syncsave=0.
  endif

! Attempt to synchronize: look for sync pattern, get DF and DT.
  call sync4(dat,npts,ntol,emedelay,dttol,nfqso,mode4,minw,  &
       dtx,nfreq,snrx,sync,flip)

  csync=' '
  decoded=blank
  deepmsg=blank
  special='     '
  nsync=sync
  nsnr=nint(snrx)
  nsnrlim=-33

!  write(91,3101) nutc,syncmin,sync,dtx,nfreq
!3101 format(i4.4,3f8.2,i6)

!  if(nsync.lt.syncmin .or. nsnr.lt.nsnrlim) then
  if(sync.lt.syncmin) then
     write(*,1010) nutc,nsnr,dtx,nfreq
     go to 900
  endif

! If we get here, we have achieved sync!
  csync='*'
  if(flip.lt.0.0) csync='#'

! Attempt a single-sequence decode, including deep4 if Fano fails.
  call decode4(dat,npts,dtx,nfreq,flip,mode4,ndepth,neme,minw,            &
       mycall,hiscall,hisgrid,decoded,nfano,deepmsg,qual,ichbest)

  if(nfano.gt.0) then
! Fano succeeded: display the message and return
     write(*,1010) nutc,nsnr,dtx,nfreq,csync,decoded,' *',             &
          char(ichar('A')+ichbest-1)
1010 format(i4.4,i4,f5.2,i5,a1,1x,a22,a2,1x,a1,i3)
     nsave=0
     go to 900
  endif

! Single-sequence Fano decode failed, so try for an average Fano decode:
  qave=0.
! If this is a new minute or a new frequency, call avg4
  if(nutc.ne.nutc0 .or. abs(nfreq-nfreq0).gt.ntol) then
     nutc0=nutc
     nfreq0=nfreq
     nsave=nsave+1
     nsave=mod(nsave-1,64)+1
     call avg4(nutc,sync,dtx,flip,nfreq,mode4,ntol,ndepth,neme,      &
         mycall,hiscall,hisgrid,nfanoave,avemsg,qave,deepave,ichbest,    &
         ndeepave)
  endif

  if(nfanoave.gt.0) then
! Fano succeeded: display the message and return
     write(*,1010) nutc,nsnr,dtx,nfreq,csync,avemsg,' *',              &
          char(ichar('A')+ichbest-1),nfanoave
!     go to 900
  endif

! Average fano decode failed, so look at the attempted correlation decodes
!  if(qual.ge.qave) then
! Single-sequence "qual" better than average "qave": display deepmsg
  if(nfano.eq.0) then
     write(cqual,'(i2)') nint(qual)
     if(qual.ge.float(nq1)) write(*,1010) nutc,nsnr,dtx,nfreq,csync,   &
          deepmsg,cqual,char(ichar('A')+ichbest-1)
     if(qual.lt.float(nq1)) write(*,1010) nutc,nsnr,dtx,nfreq,csync
  endif
!  else
! Average "qave better than single-sequence "qual": display deepave
  if(nfanoave.eq.0) then
     write(cqual,'(i2)') nint(qave)
     if(qave.ge.float(nq1)) write(*,1010) nutc,nsnr,dtx,nfreq,csync,   &
          deepave,cqual,char(ichar('A')+ichbest-1),ndeepave
!  endif
  endif

900 return
end subroutine wsjt4

