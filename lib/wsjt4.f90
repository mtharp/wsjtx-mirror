subroutine wsjt4(dat,npts,cfile6,NClearAve,MinSigdB,DFTolerance,NFreeze,    &
     mode,mode4,minw,mycall,hiscall,hisgrid,Nseg,MouseDF,NAgain,ndepth, &
     neme,idf,lumsg,nspecial,ndf,NSyncOK,ccfblue,ccfred,ndiag,ps0)

! Orchestrates the process of decoding JT4 messages, using data that 
! have been 2x downsampled.  

  use jt4
  real dat(npts)                                     !Raw data
  real*4 ccfblue(-5:540)                             !CCF in time
  real*4 ccfred(-224:224)                            !CCF in frequency
  real*4 ps0(450)
  integer DFTolerance
  logical first
  character decoded*22,cfile6*6,special*5,cooo*3
  character*22 avemsg1,avemsg2,deepmsg
  character*77 line,ave1,ave2
  character*1 csync,c1
  character*12 mycall
  character*12 hiscall
  character*6 hisgrid
  character submode*1
  data first/.true./
  save

  if(first) then
     nsave=0
     first=.false.
     ave1=' '
     ave2=' '
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
  call sync4(dat,npts,DFTolerance,NFreeze,MouseDF,mode,mode4,minw,  &
       dtx,dfx,snrx,snrsync,ccfblue,ccfred,flip,width,ps0)

!  do i=-224,224
!     write(51,3001) i,ccfred(i)
!3001 format(i6,f12.3)
!  enddo

!  do i=-5,60
!     write(52,3001) i,ccfblue(i)
!  enddo

  csync=' '
  decoded='                      '
  deepmsg='                      '
  special='     '
  cooo='   '
  ncount=-1             !Flag for convolutional decode of current record
  ncount1=-1            !Flag for convolutional decode of ave1
  ncount2=-1            !Flag for convolutional decode of ave2
  NSyncOK=0
  nqual1=0
  nqual2=0

  if(nsave.lt.MAXAVE .and. (NAgain.eq.0 .or. NClearAve.eq.1)) nsave=nsave+1
  if(nsave.le.0) go to 900          !Prevent bounds error
  
  nflag(nsave)=0                    !Clear the "good sync" flag
  iseg(nsave)=Nseg                  !Set the RX segment to 1 or 2

  nsync=snrsync
  nsnr=nint(snrx)
  nsnrlim=-33
  if(nsnr.lt.nsnrlim .or. nsync.lt.0) nsync=0
  if(nsync.lt.MinSigdB .or. nsnr.lt.nsnrlim) go to 200

! If we get here, we have achieved sync!
  NSyncOK=1
  nflag(nsave)=1            !Mark this RX file as good
  csync='*'
  if(flip.lt.0.0) then
     csync='#'
     cooo='O ?'
  endif

  call decode4(dat,npts,dtx,dfx,flip,mode4,ndepth,neme,minw,                &
       mycall,hiscall,hisgrid,decoded,ncount,deepmsg,qual,ichbest,submode)

200 kvqual=0
  if(ncount.ge.0) kvqual=1
  nqual=qual
  if(nqual.ge.nq1 .and.kvqual.eq.0) decoded=deepmsg

  ndf=nint(dfx - 1.5*mode4*11025.0/2520.0)
  if(flip.lt.0.0 .and. (kvqual.eq.1 .or. nqual.ge.nq2)) cooo='OOO'
  if(kvqual.eq.0.and.nqual.ge.nq1.and.nqual.lt.nq2) cooo(2:3)=' ?'
  if(index(decoded,'-').ge.9) cooo='   '
  if(decoded.eq.'                      ') cooo='   '
  do i=1,22
     c1=decoded(i:i)
     if(c1.ge.'a' .and. c1.le.'z') decoded(i:i)=char(ichar(c1)-32)
  enddo
  jdf=ndf+idf
  do i=22,1,-1
     if(decoded(i:i).ne.' ') exit
  enddo
  if(i.le.20) decoded(i+2:)=cooo
!  if(nqual.lt.6) decoded(22:22)='?'               !### ??? ###

  snrsave(nsave)=snrx
  dtsave(nsave)=dtx-0.8
  nfsave(nsave)=ndf+idf+1270

  write(line,1010) cfile6(1:4),nsnr,dtx-0.8,1270+jdf,csync,decoded,    &
       kvqual,nqual,submode
1010 format(a4,i4,f5.1,i5,1x,a1,1x,a22,i3,i4,1x,a1)
! Blank all end-of-line stuff if no decode
  if(line(31:40).eq.'          ') line=line(:30)

  write(lumsg,1011) line                       !Write the decoded results
1011 format(a77)

  if(decoded.eq.'                      ') then
! Decode failed, try message averaging
     if(nsave.ge.1) call avemsg4(1,mode4,ndepth,avemsg1,nused1,nq1,nq2,  &
          neme,mycall,hiscall,hisgrid,qual1,ns1,ncount1,kdec1,           &
          snrave,dtave,nfave)
     if(nsave.ge.1) call avemsg4(2,mode4,ndepth,avemsg2,nused2,nq1,nq2,  &
          neme,mycall,hiscall,hisgrid,qual2,ns2,ncount2,kdec2,           &
          snrave,dtave,nfave)
     nqual1=qual1
     nqual2=qual2
     nc1=0
     nc2=0
     if(ncount1.ge.0) nc1=nused1
     if(ncount2.ge.0) nc2=nused2

     if(ns1.ge.1) then                            !Write the average line
        write(ave1,1010) cfile6,nint(snrave),dtave,nfave,' ',           &
             avemsg1,nused1,nqual1,char(ichar('A')+kdec1-1)
1021    format(a4,4x,'Averaged:',4x,a22,i3,i4,1x,a1)
!        if(ave1(31:40).eq.'          ') ave1=ave1(:30)
        if(avemsg1.ne.'                      ') write(lumsg,1011) ave1
     endif

! If Monitor segment #2 is available, write that line also
     if(ns2.ge.1) then
        write(ave2,1021) cfile6,avemsg2,nc2,nqual2,char(ichar('A')+kdec1-1)
!        if(ave2(31:40).eq.'          ') ave2=ave2(:30)
        if(avemsg2.ne.'                      ') write(lumsg,1011) ave2
     endif
  endif

  if(decoded.ne.'                      ') nsave=0  !Good decode, restart avging

  if(mode4.gt.1 .and. ichbest.gt.1) ccfred=ccfred*sqrt(float(nch(ichbest)))

900 return
end subroutine wsjt4
