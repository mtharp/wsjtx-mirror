subroutine wsjt4(dat,npts,nutc,NClearAve,MinSigdB,ntol,emedelay,dttol,    &
     mode4,minw,mycall,hiscall,hisgrid,nfqso,NAgain,ndepth,neme,          &
     ccfblue,ccfred,ps0)

! Orchestrates the process of decoding JT4 messages, using data that 
! have been 2x downsampled.

! NB: JT4 presently looks for only one decodable signal in the FTol 
! range -- analogous to the nqd=1 step in JT9 and JT65.

  use jt4
  real dat(npts)                                     !Raw data
  real*4 ccfblue(-5:540)                             !CCF in time
  real*4 ccfred(-224:224)                            !CCF in frequency
  real*4 ps0(450)
  logical first
  character decoded*22,special*5
  character*22 avemsg,deepmsg,deepave,blank
  character*1 csync
  character*12 mycall
  character*12 hiscall
  character*6 hisgrid
  data first/.true./,nutc0/-999/,nfreq0/-999999/,syncbest/0.0/
  save

  if(first) then
     nsave=0
     first=.false.
     blank='                      '
     ccfblue=0.
     ccfred=0.
     if(nspecial.eq.999) go to 900        !Silence compiler warning
  endif

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
  nfmid=nfqso + nint(1.5*mode4*4.375)
  call sync4(dat,npts,ntol,emedelay,dttol,nfmid,mode4,minw,  &
       dtx,dfx,snrx,snrsync,ccfblue,ccfred,flip,width,ps0)

  csync=' '
  decoded=blank
  deepmsg=blank
  special='     '
  nqual1=0
  nqual2=0

!  if(nsave.lt.MAXAVE .and. (NAgain.eq.0 .or. NClearAve.eq.1)) nsave=nsave+1
!  if(nsave.le.0) go to 900          !Prevent bounds error

  nsync=snrsync
  nsnr=nint(snrx)
  nsnrlim=-33
  if(nsnr.lt.nsnrlim .or. nsync.lt.0) nsync=0
  if(nsync.lt.MinSigdB .or. nsnr.lt.nsnrlim) go to 900    !### ??? ###

! If we get here, we have achieved sync!
  csync='*'
  if(flip.lt.0.0) csync='#'

! Attempt a single-sequence decode, including deep4 if Fano fails.
  call decode4(dat,npts,dtx,dfx,flip,mode4,ndepth,neme,minw,                &
       mycall,hiscall,hisgrid,decoded,nfano,deepmsg,qual,ichbest)

  nfreq=nint(dfx + 1270.46 - 1.5*mode4*11025.0/2520.0)
  dtxx=dtx-0.8

  if(nfano.gt.0) then
! Fano succeeded: display the message and return
     write(*,1010) nutc,nsnr,dtxx,nfreq,csync,decoded,    &
          nfano,0,char(ichar('A')+ichbest-1)
1010 format(i4.4,i4,f5.2,i5,1x,a1,1x,a22,2i3,1x,a1)
     go to 900
  endif

! Single-sequence Fano decode failed, so try for an average Fano decode:
  qave=0.
! If this is a new minute or a new frequency, reset syncbest=0:
  if(nutc.ne.nutc0 .or. abs(nfreq-nfreq0).gt.ntol) syncbest=0.
! If operator tries several times, save only the one with best sync
  if(snrsync.gt.0.9999*syncbest) then
     nsave=nsave+1
     nsave=mod(nsave-1,64)+1
! Attempt an average decode
     call avg4(nutc,snrsync,dtxx,nfreq,mode4,ntol,ndepth,minw,     &
         mycall,hiscall,hisgrid,nfanoave,avemsg,qave,deepave,ichbest)
  endif

  if(nfanoave.gt.0) then
! Fan succeeded: display the message and return
     write(*,1010) nutc,nsnr,dtxx,nfreq,csync,avemsg,    &
          nfanoave,0,char(ichar('A')+ichbest-1)
     go to 900
  endif

! Average fano decode failed, so look at the attempted correlation decodes
  if(qual.gt.qave) then
! Single-sequence "qual" better than average "qave": display deepmsg
     if(qual.ge.float(nq1)) write(*,1010) nutc,nsnr,dtxx,nfreq,csync,   &
          deepmsg,0,nint(qual),char(ichar('A')+ichbest-1)
     if(qual.lt.float(nq1)) write(*,1010) nutc,nsnr,dtxx,nfreq,csync
  else
! Average "qave better than single-sequence "qual": display deepave
     if(qave.ge.float(nq1)) write(*,1010) nutc,nsnr,dtxx,nfreq,csync,   &
          deepave,0,nint(qave),char(ichar('A')+ichbest-1)
     if(qave.lt.float(nq1)) write(*,1010) nutc,nsnr,dtxx,nfreq,csync
  endif

900 return
end subroutine wsjt4

