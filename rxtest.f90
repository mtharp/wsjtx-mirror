program rxtest

#ifdef CVF
  use dfport
#else
  integer unlink
#endif

! Logical units:
!  10  wspr_tr.in
!  11  Transmitting/Receiving and UTC
!  12
!  13  ALL_MEPT.TXT
!  14  decoded.txt

  character cjunk*1
  character*74 line
  character*17 message
  character*12 arg
  real*8 tsec
  logical idle,receiving,transmitting,decoding,gui,cmnd,list
  integer istat(13)
  integer soundinit,soundexit
  integer*1 hdr(44)
  include 'acom1.f90'
  data nsec0/9999999/,itr/0/
  data idle/.false./,receiving/.false./,transmitting/.false./
  data decoding/.false./,gui/.false./,cmnd/.false./

  nargs=iargc()
  if(nargs.eq.0) then
     print*,'Usage: rxtest infile1 [infile2 ...]'
     go to 999
  endif 

  open(11,file='txrxtime.txt',status='unknown')
  open(14,file='decoded.txt',status='unknown')
  open(13,file='ALL_MEPT.TXT',status='unknown',position='append')
  write(*,1028)
1028 format(/' Date   UTC Sync dB    DT     Freq    Message'/           &
             '------------------------------------------------------')
  close(13)

  f0=0.
  pctx=-1.
  ndevin=-1
  list=.false.
  nfiles=1
  call getarg(1,infile)
  if(infile(:).eq.'files.dat') then
     open(19,file='files.dat',status='old')
     list=.true.
     nfiles=99999
  endif
  do ifile=1,nfiles
     if(list) read(19,1001,end=999) infile
1001format(a)
#ifdef CVF
     open(12,file=infile,form='binary',status='old')
#else
     open(12,file=infile,access='stream',status='old')
#endif
     npts=114*12000
     read(12) hdr
     read(12) (iwave(i),i=1,npts)
     close(12)
     call getrms(iwave,npts,ave,rms)
     minsync=1
     nsec=time()
     outfile=infile
     call mept162(outfile,f0,minsync,iwave,NMAX,rms,nsec,.true.)
  enddo

999 end program rxtest
