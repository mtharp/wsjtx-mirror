program rsdtest3

  parameter (NPTS=54*11025)
  character cfile6*6
  character*12 mycall
  character*12 hiscall
  character*6 hisgrid
  character*80 infile
  integer*1 d1(NPTS)
  integer ihdr(11)
  real dat(NPTS)
  real ps0(450)           !Spectrum of best ping
  real fzap(200)
  logical lcum
  real ccfblue(-5:540)
  real ccfred(-224:224)
  real ss1(-224:224)      !Magenta curve (for JT65 shorthands)
  real ss2(-224:224)      !Orange curve (for JT65 shorthands)
  integer*1 n1
  equivalence(n1,n4)
  include '../avecom.f90'

  nargs=iargc()
  if(nargs.lt.1) then
     print*,'Usage: rsdtest file1 [file2 ...]'
     go to 999
  endif

  nadd=1
  ifile0=0
  if(nfiles.lt.0) then
     ifile0=-nfiles
     nfiles=99999
  endif

  call cs_init
  nsave=1
  ndepth=0
  neme=0
  mycall='VK7MO'
  hiscall='K1JT'
  hisgrid='FN20qi'
  mode65=1
  nfast=1
  nafc=0
  nclearave=0
  minsigdb=0
  ntol=400
  nfreeze=0
  mousedf=0
  nagain=0
  idf=0
  idfsh=0
  lumsg=6
  lcum=.true.
  ndf=0
  ndiag=0
  nzap=0
  nadd=1
  nspecial=0

  do ifile=1,nargs
     call getarg(ifile,infile)
     write(cfile6,'(i6.6)') ifile
     open(10,file=infile,access='stream',status='unknown')
     read(10,end=999) ihdr,d1
     close(10)
     n4=0
     do i=1,NPTS
        n1=d1(i)
        dat(i)=n4-128
     enddo
     nseg=mod(ifile,2)+1

! Check for a JT65 shorthand message
     nstest=0
      call short65(dat,npts,NFreeze,MouseDF,                   &
           ntol,mode65,nspecial,nstest,dfsh,iderrsh,           &
           idriftsh,snrsh,ss1,ss2,nwsh,idfsh)

! Lowpass filter and downsample by 1/2
     call lpf1(dat,npts,jz,MouseDF,MouseDF2)
     idf=mousedf-mousedf2
     fzap(1)=0.
     if(nzap.eq.1) call avesp2(dat,jz,nadd,mode,NFreeze,MouseDF2,    &
          ntol,fzap)
     if(nzap.eq.1.and.nstest.eq.0) call bzap(dat,jz,nadd,mode,fzap)

!     i1=4096 + 17
     i1=0
     call wsjt65(dat(i1+1),jz-i1,cfile6,                                 &
          NClearAve,MinSigdB,ntol,NFreeze,NAFC,mode65,nfast,Nseg,        &
          MouseDF2,NAgain,ndepth,neme,idf,idfsh,                         &
          mycall,hiscall,hisgrid,lumsg,lcum,nspecial,ndf,                &
          nstest,dfsh,snrsh,NSyncOK,ccfblue,ccfred,ndiag,nwsh,ps0)
     flush(6)
  enddo

999 end program rsdtest3

