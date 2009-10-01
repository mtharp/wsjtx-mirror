subroutine wsjt64(dat,npts,cfile6,NClearAve,MinSigdB,               &
     DFTolerance,NFreeze,NAFC,mode64,Nseg,MouseDF,NAgain,           &
     ndepth,nchallenge,idf,idfsh,mycall,hiscall,hisgrid,            &
     lumsg,lcum,nspecial,ndf,nstest,dfsh,                           &
     snrsh,NSyncOK,ccfblue,ccfred,ndiag,nwsh)

! Orchestrates the process of decoding JT64 messages, using data that
! have been 2x downsampled.  The search for shorthand messages has
! already been done.

  parameter (MAXAVE=120)
  real dat(npts)                        !Raw data
  integer DFTolerance
  logical first
  logical lcum
  character decoded*22,cfile6*6,special*5,cooo*3
  character*22 deepmsg
  character*67 line,ave1,ave2
  character*1 csync,c1
  character*12 mycall
  character*12 hiscall
  character*6 hisgrid
  real ccfblue(-5:540),ccfred(-224:224)
  integer itf(2,9)
  common/ave/ppsave(64,63,MAXAVE),nflag(MAXAVE),nsave,iseg(MAXAVE)
  data first/.true./,ns10/0/,ns20/0/
  data itf/0,0, 1,0, -1,0, 0,-1, 0,1, 1,-1, 1,1, -1,-1, -1,1/
  save

  if(first) then
     nsave=0
     first=.false.
     ave1=' '
     ave2=' '
  endif

  naggressive=0
  if(ndepth.ge.2) naggressive=1
  nq1=3
  nq2=6
  if(naggressive.eq.1) nq1=1
  
  if(NClearAve.ne.0) then
     nsave=0                        !Clear the averaging accumulators
     ns10=0
     ns20=0
     ave1=' '
     ave2=' '
  endif
  if(MinSigdB.eq.99 .or. MinSigdB.eq.-99) then
     ns10=0                         !For Include/Exclude ?
     ns20=0
  endif

! Attempt to synchronize: look for sync tone, get DF and DT.
  call sync64(dat,npts,DFTolerance,NFreeze,MouseDF,                      &
       mode64,dtx,dfx,snrx,snrsync,ccfblue,ccfred,isbest)

  nsync=snrsync
  if(nsync.lt.0) nsync=0
  nsnr=nint(snrx)
  jdf=nint(dfx)
!  write(11,1010) cfile6,nsync,nsnr,dtx,jdf,isbest
!1010 format(a6,i3,i5,f5.1,i5,i3,1x,a1,1x,a5,a19,1x,a3,i4,i4)
!  write(21,1010) cfile6,nsync,nsnr,dtx,jdf,isbest

  csync=' '
  decoded='                      '
  deepmsg='                      '
  special='     '
  cooo='   '
  ncount=-1             !Flag for RS decode of current record
  ncount1=-1            !Flag for RS Decode of ave1
  ncount2=-1            !Flag for RS Decode of ave2
  NSyncOK=0
  nqual1=0
  nqual2=0

  if(nsave.lt.MAXAVE .and. (NAgain.eq.0 .or. NClearAve.eq.1)) nsave=nsave+1
  if(nsave.le.0) go to 900          !Prevent bounds error

  nflag(nsave)=0                    !Clear the "good sync" flag
  iseg(nsave)=Nseg                  !Set the RX segment to 1 or 2
  nsync=nint(snrsync-3.0)
  nsnr=nint(snrx)
  if(nsnr.lt.-30 .or. nsync.lt.0) nsync=0
  nsnrlim=-32

! Good Sync takes precedence over a shorthand message:
  if(nsync.ge.MinSigdB .and. nsnr.ge.nsnrlim .and. nsync.ge.nstest) nstest=0

  if(nstest.gt.0) then
     dfx=dfsh
     nsync=nstest
     nsnr=snrsh
     dtx=1.
     ccfblue(-5)=-999.0
     if(nspecial.eq.1) special='RO   '
     if(nspecial.eq.2) special='RRR  '
     if(nspecial.eq.3) special='73   '
     NSyncOK=1              !Mark this RX file as good (for "Save Decoded")
     if(NFreeze.eq.0 .or. DFTolerance.ge.200) special(5:5)='?'
     width=nwsh
     idf=idfsh
     go to 200
  endif

  if(nsync.lt.MinSigdB .or. nsnr.lt.nsnrlim) go to 200

! If we get here, we have achieved sync!

!### From here onward, code from wsjt65.f was deleted.  Must restore
!### and modify.

  NSyncOK=1
  nflag(nsave)=1            !Mark this RX file as good
  csync='*'
  qual=0.

!  call decode65(dat,npts,dtx,dfx,flip,ndepth,neme,               &
!       mycall,hiscall,hisgrid,mode65,nafc,decoded,               &
!       ncount,deepmsg,qual)

  if(ncount.eq.-999) qual=0                 !Bad data
200 kvqual=0
  if(ncount.ge.0) kvqual=1
  nqual=qual
  if(ndiag.eq.0 .and. nqual.gt.10) nqual=10
  if(nqual.ge.nq1 .and.kvqual.eq.0) decoded=deepmsg

  ndf=nint(dfx)
  if(decoded.eq.'                      ') cooo='   '
  do i=1,22
     c1=decoded(i:i)
     if(c1.ge.'a' .and. c1.le.'z') decoded(i:i)=char(ichar(c1)-32)
  enddo
  jdf=ndf+idf
  if(nstest.gt.0) jdf=ndf

  call cs_lock('wsjt64')
  write(line,1010) cfile6,nsync,nsnr,dtx-1.0,jdf,                      &
       isbest,csync,special,decoded(1:19),cooo,kvqual,nqual
1010 format(a6,i3,i5,f5.1,i5,i3,1x,a1,1x,a5,a19,1x,a3,i4,i4)

! Blank all end-of-line stuff if no decode
  if(line(31:40).eq.'          ') line=line(:30)

! Blank DT if shorthand message  (### wrong logic? ###)
  if(special.ne.'     ') then
     line(15:19)='     '
     line=line(:35)
     ccfblue(-5)=-9999.0
  else
     nspecial=0
  endif

  if(lcum) write(21,1011) line
1011 format(a67)
! Write decoded msg unless this is an "Exclude" request:
  if(MinSigdB.lt.99) write(lumsg,1011) line
  call cs_unlock

900 continue

  return
end subroutine wsjt64
