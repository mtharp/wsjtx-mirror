subroutine wsjtgen

! Compute the waveform to be transmitted.  

! Input:    txmsg        message to be transmitted, up to 28 characters
!           samfacout    fsample_out/12000.d0

! Output:   iwave        waveform data, i*2 format
!           nwave        number of samples
!           sendingsh    0=normal; 1=shorthand; -1=plain text; 2=test file

  parameter (NMSGMAX=28)             !Max characters per message
  parameter (NSPD=25)                !Samples per dit
  parameter (NDPC=3)                 !Dits per character
  parameter (NWMAX=150*12000)        !Max length of Tx waveform
  parameter (NTONES=4)               !Number of FSK tones

  integer   itone(84)
  character msg*28,msgsent*22,idmsg*22
  real*8 freq,pha,dpha,twopi,dt
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
  fsample_out=12000.d0*samfacout
  lcwid=.false.
  if(idinterval.gt.0) then
     n=(mod(int(tsec/60.d0),idinterval))
     if(n.eq.(1-txfirst)) lcwid=.true.
     if(idinterval.eq.1) lcwid=.true.
  endif

  msg=txmsg
  ntxnow=ntxreq
! Convert all letters to upper case
  do i=1,28
     if(msg(i:i).ge.'a' .and. msg(i:i).le.'z')                  &
          msg(i:i)= char(ichar(msg(i:i))+ichar('A')-ichar('a'))
  enddo
  txmsg=msg

! Find message length
  do i=NMSGMAX,1,-1
     if(msg(i:i).ne.' ') go to 10
  enddo
  i=1
10 nmsg=i
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
     freq=1000.0
     if(msg(2:2).eq.'A' .or. msg(2:2).eq.'a') freq=882
     if(msg(2:2).eq.'B' .or. msg(2:2).eq.'b') freq=1323
     if(msg(2:2).eq.'C' .or. msg(2:2).eq.'c') freq=1764
     if(msg(2:2).eq.'D' .or. msg(2:2).eq.'d') freq=2205
     if(freq.eq.1000.0) then
        read(msg(2:),*,err=1) freq
        goto 2
1       txmsg='@1000'
        nmsg=5
        nmsg0=5
     endif
2    nwave=60*fsample_out
     dpha=twopi*freq/fsample_out
     do i=1,nwave
        iwave(i)=32767.0*sin(i*dpha)
     enddo
     goto 900
  endif

  dt=1.d0/fsample_out
  LTone=2

  if(mode(1:4).eq.'JT64') then
     mode64=1
     call gen64(msg,mode64,samfacout,ntxdf,iwave,nwave,sendingsh,   &
          msgsent,nmsg0)
  else
     print*,'Unknown Tx mode requested.'
!     stop 'Unknown Tx mode requested.'
  endif

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
  if((mode(1:4).eq.'JT65' .or. mode(1:4).eq.'JT64' .or. &
       mode(1:4).eq.'WSPR') .and. sendingsh.ne.1) sending=msgsent
  do i=NMSGMAX,1,-1
     if(sending(i:i).ne.' '.and. ichar(sending(i:i)).ne.0) go to 910
  enddo
  i=1
910 nmsg=i

  if(lcwid .and. (mode.eq.'FSK441' .or. mode(1:4).eq.'JT6M')) then
!  Generate and insert the CW ID.
     wpm=25.
     freqcw=440.
     idmsg=MyCall//'          '
     call gencwid(idmsg,wpm,freqcw,samfacout,icwid,ncwid)
     k=0
     do i=ncwid+1,int(trperiod*fsample_out)
        k=k+1
        if(k.gt.nwave) k=k-nwave
        iwave(i)=iwave(k)
     enddo
     do i=1,ncwid
        iwave(i)=icwid(i)
     enddo
     nwave=trperiod*fsample_out
  endif

999 continue
  call cs_unlock
  return
end subroutine wsjtgen

