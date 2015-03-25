subroutine wsjt4(dat,npts,nutc,NClearAve,MinSigdB,ntol,                    &
     NFreeze,mode,mode4,minw,mycall,hiscall,hisgrid,Nseg,nfqso,NAgain,     &
     ndepth,neme,lumsg,nspecial,NSyncOK,ccfblue,ccfred,ndiag,ps0)

! Orchestrates the process of decoding JT4 messages, using data that 
! have been 2x downsampled.  

  use jt4
  real dat(npts)                                     !Raw data
  real*4 ccfblue(-5:540)                             !CCF in time
  real*4 ccfred(-224:224)                            !CCF in frequency
  real*4 ps0(450)
  logical first
  character decoded*22,special*5
  character*22 avemsg,deepmsg,deepave,blank
  character*77 line,ave1,ave2
  character*1 csync
  character*12 mycall
  character*12 hiscall
  character*6 hisgrid
  data first/.true./,nutc0/-999/,nfreq0/-999999/,syncbest/0.0/
  save

  if(first) then
     nsave=0
     first=.false.
     ave1=' '
     ave2=' '
     blank='                      '
     ccfblue=0.
     ccfred=0.
     if(ndiag.eq.-999) ave1='  '          !Silence compiler warning
     if(nspecial.eq.999) go to 900        !Silence compiler warning
  endif

  naggressive=0
  if(ndepth.ge.2) naggressive=1
  nq1=3
  nq2=6
  if(naggressive.eq.1) nq1=1

  if(NClearAve.ne.0) then
     nsave=0                        !Clear the averaging accumulators
     ave1=' '
     ave2=' '
  endif

! Attempt to synchronize: look for sync pattern, get DF and DT.
  call sync4(dat,npts,DFTolerance,NFreeze,nfqso,mode,mode4,minw,  &
       dtx,dfx,snrx,snrsync,ccfblue,ccfred,flip,width,ps0)

!  do i=-224,224
!     write(51,3001) i,ccfred(i)
!3001 format(i6,f12.3)
!  enddo

!  do i=-5,60
!     write(52,3001) i,ccfblue(i)
!  enddo

  csync=' '
  decoded=blank
  deepmsg=blank
  special='     '
  ncount=-1             !Flag for convolutional decode of current record
  ncount1=-1            !Flag for convolutional decode of ave1
  ncount2=-1            !Flag for convolutional decode of ave2
  NSyncOK=0
  nqual1=0
  nqual2=0

!  if(nsave.lt.MAXAVE .and. (NAgain.eq.0 .or. NClearAve.eq.1)) nsave=nsave+1
!  if(nsave.le.0) go to 900          !Prevent bounds error
!  nflag(nsave)=0                    !Clear the "good sync" flag
!  iseg(nsave)=Nseg                  !Set the RX segment to 1 or 2

  nsync=snrsync
  nsnr=nint(snrx)
  nsnrlim=-33
  if(nsnr.lt.nsnrlim .or. nsync.lt.0) nsync=0
  if(nsync.lt.MinSigdB .or. nsnr.lt.nsnrlim) go to 900    !### ??? ###

! If we get here, we have achieved sync!
  NSyncOK=1
!  nflag(nsave)=1            !Mark this RX file as potentially good
  csync='*'
  if(flip.lt.0.0) then
     csync='#'
  endif

  call decode4(dat,npts,dtx,dfx,flip,mode4,ndepth,neme,minw,                &
       mycall,hiscall,hisgrid,decoded,nfano,deepmsg,qual,ichbest)

  nfreq=nint(dfx + 1270.46 - 1.5*mode4*11025.0/2520.0)
  dtxx=dtx-0.8

  if(nfano.gt.0) then
     write(*,1010) nutc,nsnr,dtxx,nfreq,csync,decoded,    &
          nfano,0,char(ichar('A')+ichbest-1)
1010 format(i4.4,i4,f5.1,i5,1x,a1,1x,a22,2i3,1x,a1)
     go to 900
  endif

  qave=0.
  if(nutc.ne.nutc0 .or. abs(nfreq-nfreq0).gt.ntol) syncbest=0.
  if(snrsync.gt.0.9999*syncbest) then
     nsave=nsave+1
     nsave=mod(nsave-1,64)+1
     call avg4(nutc,snrsync,dtxx,nfreq,mode4,ntol,ndepth,nfanoave,avemsg,   &
     qave,deepave,ichbest)
  endif

  if(nfanoave.gt.0) then
     write(*,1010) nutc,nsnr,dtxx,nfreq,csync,avemsg,    &
          nfanoave,0,char(ichar('A')+ichbest-1)
     go to 900
  endif

  if(qual.gt.qave) then
     if(qual.ge.float(nq1)) write(*,1010) nutc,nsnr,dtxx,nfreq,csync,deepmsg, &
          0,nint(qual),char(ichar('A')+ichbest-1)
     if(qual.lt.float(nq1)) write(*,1010) nutc,nsnr,dtxx,nfreq,csync
  else
     if(qave.ge.float(nq1)) write(*,1010) nutc,nsnr,dtxx,nfreq,csync,deepmsg, &
          0,nint(qave),char(ichar('A')+ichbest-1)
     if(qave.lt.float(nq1)) write(*,1010) nutc,nsnr,dtxx,nfreq,csync
  endif

!  if(decoded.ne.'                      ') nsave=0  !Good decode, restart avging
!  if(mode4.gt.1 .and. ichbest.gt.1) ccfred=ccfred*sqrt(float(nch(ichbest)))

900 return
end subroutine wsjt4

