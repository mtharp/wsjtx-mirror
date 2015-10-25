program jt65

! Test the JT65 decoder for WSJT-X

  parameter (NZMAX=60*12000)
  integer*4 ihdr(11)
  integer*2 id2(NZMAX)
  real*4 dd(NZMAX)
  character*80 infile
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
!  common/hdr/ariff,lenfile,awave,afmt,lenfmt,nfmt2,nchan2, &
!     nsamrate,nbytesec,nbytesam2,nbitsam2,adata,ndata
  common/tracer/limtrace,lu
  equivalence (lenfile,ihdr(2))

  nargs=iargc()
  if(nargs.lt.1) then
     print*,'Usage: jt65 file1 [file2 ...]'
     go to 999
  endif
  limtrace=0
  lu=12

  ntol=50
  nfqso=3000
  nagain=0
  minsync=2.5
  nsubmode=0

  open(12,file='timer.out',status='unknown')

  call timer('jt65    ',0)

  do ifile=1,nargs
     newdat=1
     nfa=200
     nfb=3000
     call getarg(ifile,infile)
     write(*,*) ifile, nargs,infile
     open(10,file=infile,access='stream',status='old',err=998)

     call timer('read    ',0)
     read(10) ihdr
     nutc=ihdr(1)                           !Silence compiler warning
     i1=index(infile,'.wav')
     read(infile(i1-4:i1-1),*,err=10) nutc
     go to 20
10    nutc=0
20    npts=52*12000
     read(10) id2(1:npts)
     call timer('read    ',1)
     dd(1:npts)=id2(1:npts)
     dd(npts+1:)=0.
!open(56,file='subtracted.wav',access='stream',status='old')
!write(56) ihdr(1:11)
     call timer('jt65a   ',0)
     call jt65a(dd,npts,newdat,nutc,nfa,nfb,nfqso,ntol,nsubmode, &
                minsync,nagain,ndecoded)
     call timer('jt65a   ',1)
  enddo

  call timer('jt65    ',1)
  call timer('jt65    ',101)
!  call four2a(a,-1,1,1,1)                  !Free the memory used for plans
!  call filbig(a,-1,1,0.0,0,0,0,0,0)        ! (ditto)
  go to 999

998 print*,'Cannot open file:'
  print*,infile

999 end program jt65
