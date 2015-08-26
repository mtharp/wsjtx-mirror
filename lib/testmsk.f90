program testmsk

  parameter (NMAX=359424)
  integer*2 id2(NMAX)
  integer narg(0:11)
  character*80 line(100)
  character infile*80
  integer*8 count0,count1,clkfreq
  common/mskcom/tsync1,tsync2,tsoft,tvit,ttotal

  nargs=iargc()
  if(nargs.lt.1) then
     print*,'Usage:     testmsk infile1 [infile2 ...]'
     print*,'Examples:  testmsk ~/data/JTMSK3/150825_115515.wav'
     print*,'           testmsk ~/data/JTMSK3/150825_120245.wav'
     go to 999
  endif

  open(81,file='testmsk.out',status='unknown',position='append')
  nfiles=nargs

  tsync1=0.
  tsync2=0.
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
     narg(1)=NMAX        !nutc
     narg(2)=0           !nsubmode
     narg(3)=1           !newdat
     narg(4)=0           !minsync
     narg(5)=0           !npick
     narg(6)=0           !t0 (ms)
     narg(7)=29951       !t1 (ms) ???
     narg(8)=1           !maxlines
     narg(9)=103         !nmode
     narg(10)=1500       !nrxfreq
     narg(11)=500        !ntol

     call jtmsk(id2,narg,line)
  enddo
  call system_clock(count1,clkfreq)
  ttotal=(count1-count0)/float(clkfreq)
  write(*,1100) tsync1/ttotal,tsync2/ttotal,tsoft/ttotal,tvit/ttotal,ttotal
1100 format(4f8.3,f8.1)

999 end program testmsk
