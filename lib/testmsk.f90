program testmsk

  parameter (NMAX=359424)
  integer*2 id2(NMAX)
  integer narg(0:11)
  character*80 line(100)
  character infile*80
  integer*8 count0,count1,clkfreq
  common/mskcom/tmskdf,tsync,tsoft,tvit,ttotal

  nargs=iargc()
  if(nargs.lt.1) then
     print*,'Usage:    testmsk infile1 [infile2 ...]'
     print*,'Example:  testmsk ~/data/JTMSK/150819_120445.wav'
     go to 999
  endif

  open(81,file='testmsk.out',status='unknown',position='append')
  nfiles=nargs

  tmskdf=0.
  tsync=0.
  tsoft=0.
  tvit=0.
  ttotal=0.
  call system_clock(count0,clkfreq)
  do ifile=1,nfiles
     call getarg(ifile,infile)
     open(10,file=infile,access='stream',status='old')
     read(10) id2(1:22)                     !Skip 44 header bytes
     npts=NMAX
     read(10,end=1) id2(1:npts)                   !Read the raw data
     close(10)

1    i1=index(infile,'.wav')
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
  enddo
  call system_clock(count1,clkfreq)
  ttotal=(count1-count0)/float(clkfreq)
  write(*,1100) tmskdf/ttotal,tsync/ttotal,tsoft/ttotal,tvit/ttotal,ttotal
1100 format(4f8.3,f8.1)

999 end program testmsk
