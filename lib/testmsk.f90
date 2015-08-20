program testmsk

  parameter (NMAX=359424)
  integer*2 id2(NMAX)
  integer narg(0:11)
  character*80 line(100)
  character submode*1,infile*80
  
  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage:    testmsk infile'
     print*,'Example:  testmsk ~/data/JTMSK/150819_120445.wav'
     go to 999
  endif
  call getarg(1,infile)
  open(10,file=infile,access='stream',status='old')
  read(10) id2(1:22)                     !Skip 44 header bytes
  npts=NMAX
  read(10,end=1) id2(1:npts)                   !Read the raw data

1 i1=index(infile,'.wav')
  read(infile(i1-6:i1-1),*) narg(0)
  narg(1)=NMAX
  narg(2)=0
  narg(3)=1
  narg(4)=0
  narg(5)=0
  narg(6)=0
  narg(7)=29951
  narg(8)=1
  narg(9)=103
  narg(10)=1500
  narg(11)=500

  call jtmsk(id2,narg,line)
  print*,line(1)

999 end program testmsk
