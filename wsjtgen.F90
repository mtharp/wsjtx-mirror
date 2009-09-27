subroutine wsjtgen

! Compute the waveform to be transmitted.  

! Input:    txmsg        message to be transmitted, up to 24 characters

! Output:   iwave        waveform data, i*2 format
!           nwave        number of samples
!           sendingsh    0=normal; 1=shorthand; -1=plain text; 2=test file

  parameter (NMSGMAX=24)             !Max characters per message
  parameter (NWMAX=60*12000)         !Max length of Tx waveform

  character msg*24,msgsent*24,idmsg*24
  real*8 fsample,freq,pha,dpha,twopi,dt
  character testfile*27,tfile2*80
  logical lcwid
  integer*2 icwid(120000),jwave(NWMAX)

  integer*1 hdr(44)
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  common/hdr/ariff,lenfile,awave,afmt,lenfmt,nfmt2,nchan2, &
     nsamrate,nbytesec,nbytesam2,nbitsam2,adata,ndata,jwave
  equivalence (ariff,hdr)

  data twopi/6.28318530718d0/
  include 'gcom1.f90'
  include 'gcom2.f90'

  call cs_lock('wsjtgen')
  fsample=12000.d0
  dt=1.d0/fsample
  lcwid=.false.
  if(idinterval.gt.0) then
     n=(mod(int(tsec/60.d0),idinterval))
     if(n.eq.(1-txfirst)) lcwid=.true.
     if(idinterval.eq.1) lcwid=.true.
  endif

  msg=txmsg
  ntxnow=ntxreq

! Convert message to upper case, compress whitespace, get length
  call msgtrim(msg,nmsg)
  nmsg0=nmsg

  if(msg(1:1).eq.'@') then
     if(msg(2:2).eq.'/' .or. ichar(msg(2:2)).eq.92) then
        txmsg=msg
        testfile=msg(2:)
#ifdef CVF
        open(18,file=testfile,form='binary',status='old',err=12)
        go to 14
12      print*,'Cannot open test file ',msg(2:)
        go to 999
14      read(18) hdr
        if(ndata.gt.NTxMax) ndata=NTxMax
        call rfile(18,iwave,ndata,ierr)
        close(18)
        if(ierr.ne.0) print*,'Error reading test file ',msg(2:)

#else
        tfile2=testfile
        call rfile2(tfile2,hdr,44+2*120*12000,nr)
        if(nr.le.0) then
           print*,'Error reading ',testfile
           stop
        endif
        do i=1,ndata/2
           iwave(i)=jwave(i)
        enddo
#endif
        nwave=ndata/2
        do i=nwave,NTXMAX
           iwave(i)=0
        enddo
        sending=txmsg
        sendingsh=2
        go to 999
     endif
! Transmit a fixed tone at specified frequency
     read(msg(2:),*,err=1) freq
     goto 2
1    txmsg='@1000'
     nmsg=5
     nmsg0=5
2    nwave=60*fsample
     dpha=twopi*freq/fsample
     do i=1,nwave
        iwave(i)=32767.0*sin(i*dpha)
     enddo
     goto 900
  endif

  if(mode(1:4).eq.'JT64') then
     mode64=1
     call gen64(msg,mode64,ntxdf,iwave,nwave,sendingsh,nbit,msgsent,nmsg0)
  else if(mode(1:4).eq.'JTMS') then
     call genms(msg,txsnrdb,iwave,nwave,nbit,msgsent)
  else if(mode(1:5).eq.'ISCAT') then
     call geniscat(msg,iwave,nwave,sendingsh,nbit,msgsent)
  else if(mode(1:3).eq.'JT8') then
     call genjt8(msg,iwave,nwave,nbit,msgsent)
  else 
     print*,'Unknown Tx mode requested.'
     stop 'Unknown Tx mode requested.'
  endif
  nbitsent=nbit

  if(lcwid) then
!  Generate and insert the CW ID.
     wpm=25.
     freqcw=800.
     idmsg=MyCall//'          '
     call gencwid(idmsg,wpm,freqcw,samfacout,icwid,ncwid)
     k=nwave
     do i=1,ncwid
        k=k+1
        iwave(k)=icwid(i)
     enddo
     do i=1,2205                   !Add 0.2 s of silence
        k=k+1
        iwave(k)=0
     enddo
     nwave=k
  endif

  goto 900

  if(mode(1:4).eq.'Echo') then
!  We're in Echo mode.
!     dither=AmpA
!     call echogen(dither,wavefile,nbytes,f1)
!     AmpB=f1
     goto 900
  endif
  
900 sending=txmsg
  if(mode(1:4).eq.'JT64' .and. sendingsh.ne.1) sending=msgsent
  do i=NMSGMAX,1,-1
     if(sending(i:i).ne.' '.and. ichar(sending(i:i)).ne.0) go to 910
  enddo
  i=1
910 nmsg=i

999 continue
  call cs_unlock
  return
end subroutine wsjtgen
