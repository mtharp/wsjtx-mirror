subroutine jt8(dat,npts,cfile6,MinSigdB,DFTolerance,NFreeze,              &
             MouseDF2,NSyncOK,ccfblue,ccfred)

! Orchestrates the process of decoding JT8 messages, using data that
! have been 2x downsampled.  The search for shorthand messages has
! already been done.

  real dat(npts)                        !Raw data
  integer DFTolerance
  real ccfblue(-5:540),ccfred(-224:224)
  character line*90,decoded*24,deepmsg*24,special*5
  character csync*1,cfile6*6

! Attempt to synchronize: look for sync tone, get DF and DT.
!  call sync64(dat,npts,DFTolerance,NFreeze,MouseDF,                      &
!       mode64,dtx,dfx,snrx,snrsync,ccfblue,ccfred,isbest)
  nsync=0
  nsnr=-33
  ncount=0
  nq1=0
  dtx=0.
  dfx=0.
  idf=0
  isbest=3
  special='     '
  decoded='                        '

! If we get here, we have achieved sync!

!### From here onward, code from wsjt65.f was deleted.  Must restore
!### and modify.

  NSyncOK=1
  csync='*'
  qual=0.

!  call decode64(dat,npts,dtx,dfx,flip,ndepth,isbest,             &
!       mycall,hiscall,hisgrid,mode64,nafc,decoded,               &
!       ncount,deepmsg,qual)

  if(ncount.eq.-999) qual=0                 !Bad data
200 kvqual=0
  if(ncount.ge.0) kvqual=1
  nqual=qual

  ndf=nint(dfx)
  jdf=ndf+idf

  call cs_lock('jt8')
  write(line,1010) cfile6,nsync,nsnr,dtx-1.0,jdf,                      &
       isbest,csync,special,decoded(1:19),kvqual,nqual
1010 format(a6,i3,i5,f5.1,i5,i3,1x,a1,1x,a5,a19,i8,i4)

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

! Write decoded msg
  write(11,1011) line
1011 format(a67)
  call cs_unlock

900 continue

  return
end subroutine jt8
