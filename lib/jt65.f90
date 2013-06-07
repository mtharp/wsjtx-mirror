program jt65

! Test the JT65 decoder for WSJT-X

  parameter (NZMAX=60*12000)
  integer*4 ihdr(11)
  integer*2 id2(NZMAX)
  real*4 dd(NZMAX)
  character*80 infile,infile0
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  common/hdr/ariff,lenfile,awave,afmt,lenfmt,nfmt2,nchan2, &
     nsamrate,nbytesec,nbytesam2,nbitsam2,adata,ndata
  common/tracer/limtrace,lu
  equivalence (ariff,ihdr)

  nargs=iargc()
  if(nargs.lt.1) then
     print*,'Usage: jt65 <infile>'
     go to 999
  endif
  call getarg(1,infile0)
  limtrace=0
  lu=12

  newdat=1
  ntol=50
  nfa=500
  nfb=2500
  mousefqso=1500
  nagain=0
  ndiskdat=1

  open(12,file='timer.out',status='unknown')
  open(22,file='kvasd.dat',access='direct',recl=1024,status='unknown')

  call timer('jt9     ',0)

  infile='/users/joe/wsjt_k1jt/wsjtx_install/save/'//infile0
  open(10,file=infile,access='stream',status='old',err=998)
  read(10) ihdr
  nutc=ihdr(1)                           !Silence compiler warning
  i1=index(infile0,'.wav')
  read(infile0(i1-4:i1-1),*,err=1) nutc
  go to 2
1 nutc=0
2 npts=52*12000
  read(10) id2(1:npts)
  dd(1:npts)=id2(1:npts)
  dd(npts+1:)=0.

  call jt65a(dd,npts,newdat,nutc,ntol,nfa,nfb,mousefqso,nagain,ndiskdat)

  call timer('jt9     ',1)
  call timer('jt9     ',101)
  go to 999

998 print*,'Cannot open file:'
  print*,infile

999 end program jt65
