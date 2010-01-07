subroutine wsjt1(d,jz0,istart,FileID,ndepth,                       &
     MinSigdB,DFTolerance,MouseButton,NClearAve,nforce,            &
     mode,NFreeze,NAFC,NZap,mode65,mode4,idf,ntdecode0,            &
     MyCall,HisCall,HisGrid,ntx2,nxa,nxb,s2,                       &
     ps0,npkept,lumsg,basevb,rmspower,nslim2,psavg,ccf,Nseg,       &
     MouseDF,NAgain,LDecoded,nspecial,ndf,ss1,ss2)

  parameter (NP2=120*12000)

  integer*2 d(jz0)        !Buffer for raw one-byte data
  integer istart          !Starting location in original d() array
  character FileID*40     !Name of file being processed
  integer MinSigdB        !Minimum ping strength, dB
  integer DFTolerance     !Defines DF search range
  integer NSyncOK         !Set to 1 if JT65 file synchronized OK
  character*12 mycall
  character*12 hiscall
  character*6 hisgrid
  character*6 mode
  real ps0(431)           !Spectrum of best ping
  integer npkept          !Number of pings kept and decoded
  integer lumsg           !Logical unit for decoded.txt
  real basevb             !Baseline signal level, dB
  integer nslim2          !Minimum strength for single-tone pings, dB
  real psavg(450)         !Average spectrum of the whole file
  integer Nseg            !First or second Tx sequence?
  integer MouseDF         !Freeze position for DF
  logical pick            !True if this is a mouse-picked ping
  logical stbest          !True if the best decode was Single-Tone
  logical STfound         !True if at least one ST decode
  logical LDecoded        !True if anything was decoded
  real s2(64,3100)        !2D spectral array
  real ccf(-5:540)        !X-cor function in JT65 mode (blue line)
  real red(512)
  real ss1(-224:224)      !Magenta curve (for JT65 shorthands)
  real ss2(-224:224)      !Orange curve (for JT65 shorthands)
  real yellow(216)
  real yellow0(216)
  real fzap(200)
  real dat2(NP2)
  character msg3*3
  character cfile6*6
  logical lcum
  integer indx(100)
  character*90 line
  common/avecom/dat(NP2),labdat,jza,modea
  common/ccom/nline,tping(100),line(100)
  common/limcom/ nslim2a
  common/extcom/ntdecode
  save

  jz=jz0
  ntdecode=ntdecode0
  MinWidth=40                            !Minimum width of pings, ms
  call zero(psavg,450)
  rewind 11
  rewind 12

  do i=1,40
     if(FileID(i:i).eq.'.') go to 3
  enddo
  i=4
3 ia=max(1,i-6)
  cfile6=FileID(ia:i-1)

  nline=0
  ndiag=0
! If file "/wsjt.reg" exists, set ndiag=1
  open(16,file='/wsjt.reg',status='old',err=4)
  ndiag=1
  close(16)

4  sum=0.
  do j=1,jz            !Convert raw data from i*2 to real, remove DC
     dat(j)=0.1*d(j)
     sum=sum + dat(j)
  enddo
  ave=sum/jz
  do j=1,jz
     dat(j)=dat(j)-ave
  enddo

!        if(ndiag.ne.0 .and. nclip.lt.0) then
!  Intentionally degrade SNR by -nclip dB.
!           sq=0.
!           do i=1,jz
!              sq=sq + dat(i)**2
!           enddo
!           p0=sq/jz
!           p1=p0*10.0**(-0.1*nclip)
!           dnoise=sqrt(4*(p1-p0))
!           idum=-1
!           do i=1,jz
!              dat(i)=dat(i) + dnoise*gran(idum)
!           enddo
!        endif

  if(mode(1:4).ne.'JT64' .and. nzap.ne.0) then
     nfrz=NFreeze
     if(mode(1:4).eq.'JTMS') nfrz=0
     if(jz.gt.100000) call avesp2(dat,jz,2,mode,nfrz,MouseDF,DFTolerance,fzap)
     nadd=1
     call bzap(dat,jz,nadd,mode,fzap)
  endif

  sq=0.
  do j=1,jz                  !Compute power level for whole array
     sq=sq + dat(j)**2
  enddo
  avesq=sq/jz
  basevb=dB(avesq) - 44    !Base power level to send back to GUI
  if(avesq.eq.0) go to 900

  nz=600
  nstep=jz/nz
  sq=0.
  k=0
  do j=1,nz
     sum=0.
     do n=1,nstep
        k=k+1
        sum=sum+dat(k)**2
     enddo
     sum=sum/nstep
     sq=sq + (sum-avesq)**2
  enddo
  rmspower=sqrt(sq/nz)
  call zero(ccf,546)
  call zero(psavg,450)

  pick=.false.
  if(istart.gt.1) pick=.true. !This is a mouse-picked decoding
  if(.not.pick .and. nforce.eq.0 .and.                              &
       (basevb.lt.-15.0 .or. basevb.gt.20.0)) goto 900

  if(.not.pick) then
     MouseButton=0
     jza=jz
     labdat=labdat+1
  endif
  NsyncOK=0

  if(mode(1:4).eq.'JTMS') then
! JTMS mode
     call wsjtms(dat,jz,istart,cfile6,MinSigdB,pick,NSyncOK,s2,ps0,psavg)

  else if(mode(1:5).eq.'ISCAT') then
! Iscat mode:
     call iscat(dat,jz,cfile6,MinSigdB,NFreeze,MouseDF,DFTolerance,    &
          nxa,nxb,NSyncOK,ccf,psavg,ps0)
     s2=0.                                     !Why is this here?

  else if(mode(1:4).eq.'JT64' .or. mode(1:3).eq.'JT8') then

     if(mode(1:4).eq.'JT64') then
! JT64 mode:
        mode64=1
        nstest=0
        if(ntx2.ne.1) call short64(dat,jz,NFreeze,MouseDF,                &
             DFTolerance,mode64,nspecial,nstest,dfsh,iderrsh,             &
             idriftsh,snrsh,ss1,ss2,nwsh,idfsh)
     endif

!  Lowpass filter and decimate by 2
     call lpf1(dat,jz,jz2,MouseDF,MouseDF2)
     idf=mousedf-mousedf2
     jz=jz2
     nadd=1
     fzap(1)=0.
     if(nzap.eq.1) call avesp2(dat,jz,nadd,mode,NFreeze,MouseDF2,       &
          DFTolerance,fzap)
     if(nzap.eq.1.and.nstest.eq.0) call bzap(dat,jz,nadd,mode,fzap)

     i=index(MyCall,char(0))
     if(i.le.0) i=index(MyCall,' ')
     mycall=MyCall(1:i-1)//'            '
     i=index(HisCall,char(0))
     if(i.le.0) i=index(HisCall,' ')
     hiscall=HisCall(1:i-1)//'            '

     if(mode(1:4).eq.'JT64') then
        jztest=12000*ntdecode/2
        if(jz.ge.jztest) call wsjt64(dat(4097),jz-4096,cfile6,              &
             NClearAve,MinSigdB,DFTolerance,NFreeze,NAFC,mode64,Nseg,       &
             MouseDF2,NAgain,ndepth,nchallenge,idf,idfsh,                   &
             mycall,hiscall,hisgrid,lumsg,lcum,nspecial,ndf,                &
             nstest,dfsh,snrsh,NSyncOK,ccf,psavg,ndiag,nwsh)

     else if(mode(1:3).eq.'JT8') then
! JT8 mode:
        call jt8(dat,jz,cfile6,MinSigdB,DFTolerance,NFreeze,              &
             MouseDF2,NSyncOK,ccf,psavg)
     endif
  endif

900 LDecoded = ((NSyncOK.gt.0) .or. npkept.gt.0)
  endfile 11
  call flushqqq(11)
  call flushqqq(12)
  call flushqqq(21)

  df=12000.0/256.0

  return
end subroutine wsjt1
