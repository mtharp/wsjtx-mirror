subroutine wsjt1(d,jz0,istart,FileID,ndepth,                       &
     MinSigdB,DFTolerance,MouseButton,NClearAve,nforce,            &
     Mode,NFreeze,NAFC,NZap,mode65,mode4,idf,ntdecode0,            &
     MyCall,HisCall,HisGrid,ntx2,s2,                               &
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

  if(mode.eq.8) nzap=0
  lcum=.true.
  jz=jz0
  ntdecode=ntdecode0
  modea=Mode
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

4 if(mode.lt.8 .and. jz.gt.655360) jz=655360
  if(mode.eq.4 .and. jz.gt.330750) jz=330750      !### Fix this!
  if(mode.eq.8 .and. jz.gt.1323000) jz=1323000

  sum=0.
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

  if(mode.ne.2 .and. nzap.ne.0) then
     nfrz=NFreeze
     if(mode.eq.1) nfrz=0
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
  nchan=64                   !Save 64 spectral channels
  nstep=221                  !Set step size to ~20 ms
  nz=jz/nstep - 1            !# of spectra to compute
  if(.not.pick) then
     MouseButton=0
     jza=jz
     labdat=labdat+1
  endif
  tbest=0.
  NsyncOK=0


! Iscat mode:
  if(mode.eq.4) then
! For waterfall plot
     call spec2d(dat,jz,nstep,s2,nchan,nz,psavg,sigma)
  endif

! JT8 mode:
  if(mode.eq.6 .or. mode.eq.7) then
     goto 900
  endif

!  JT64 mode:
  if(mode.eq.9) then
     mode64=1
     nstest=0
!           if(ntx2.ne.1) call short65(dat,jz,NFreeze,MouseDF,
!     +        DFTolerance,mode64,nspecial,nstest,dfsh,iderrsh,
!     +        idriftsh,snrsh,ss1,ss2,nwsh,idfsh)

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

!  Offset data by about 1 s.
!           jztest=126*2048
     jztest=12000*ntdecode/2 - 2755

     if(jz.ge.jztest) call wsjt64(dat(4097),jz-4096,cfile6,              &
          NClearAve,MinSigdB,DFTolerance,NFreeze,NAFC,mode64,Nseg,       &
          MouseDF2,NAgain,ndepth,nchallenge,idf,idfsh,                   &
          mycall,hiscall,hisgrid,lumsg,lcum,nspecial,ndf,                &
          nstest,dfsh,snrsh,NSyncOK,ccf,psavg,ndiag,nwsh)
     goto 900
  endif

!  We're in JTMS mode. Compute the 2D spectrum.
  df=12000.0/256.0            !FFT resolution ~43 Hz
  dtbuf=nstep/12000.0
  stlim=nslim2                !Single-tone threshold
  call spec2d(dat,jz,nstep,s2,nchan,nz,psavg,sigma)
  if(sigma.lt.0.0) basevb=-99.0
  if(sigma.lt.0.0) go to 900
  nline0=nline
  call s2shape(s2,nchan,nz,tbest)

900 LDecoded = ((NSyncOK.gt.0) .or. npkept.gt.0)
  endfile 11
  call flushqqq(11)
  call flushqqq(12)
  call flushqqq(21)

  return
end subroutine wsjt1
