program wspr_rx

!  Receive and decode MEPT_JT signals for one 2-minute sequence.

#ifdef CVF
  use dfport
#else
  integer time
  integer unlink
#endif

  character*12 callsign
  character*4 grid
  parameter (NMAX=120*12000)                          !Max length of waveform
  integer*2 iwave(NMAX)                               !Generated waveform
  parameter (MAXSYM=176)
  integer*1 symbol(MAXSYM)
  integer*1 data1(11),i1
  integer*1 hdr(44)
  integer mettab(0:255,0:1)                           !Metric table
  integer npr3(162)
  integer getsound
  real pr3(162)
  real*8 f0
  character*12 arg
  character*6 cfile6
  character*70 outfile
  character*32 devin
  equivalence(i1,i4)
  data npr3/                                          &
      1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,        &
      0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,        &
      0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,        &
      1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,        &
      0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,        &
      0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,        &
      0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,        &
      0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,        &
      0,0/

  data mettab/                                             &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   4,   &
         4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   &
         4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   &
         3,   3,   3,   3,   3,   3,   3,   3,   3,   2,   &
         2,   2,   2,   2,   1,   1,   1,   1,   0,   0,   &
        -1,  -1,  -1,  -2,  -2,  -3,  -4,  -4,  -5,  -6,   &
        -7,  -7,  -8,  -9, -10, -11, -12, -12, -13, -14,   &
       -15, -16, -17, -17, -18, -19, -20, -21, -22, -22,   &
       -23, -24, -25, -26, -26, -27, -28, -29, -30, -30,   &
       -31, -32, -33, -33, -34, -35, -36, -36, -37, -38,   &
       -38, -39, -40, -41, -41, -42, -43, -43, -44, -45,   &
       -45, -46, -47, -47, -48, -49, -49, -50, -51, -51,   &
       -52, -53, -53, -54, -54, -55, -56, -56, -57, -57,   &
       -58, -59, -59, -60, -60, -61, -62, -62, -62, -63,   &
       -64, -64, -65, -65, -66, -67, -67, -67, -68, -69,   &
       -69, -70, -70, -71, -72, -72, -72, -72, -73, -74,   &
       -75, -75, -75, -77, -76, -76, -78, -78, -80, -81,   &
       -80, -79, -83, -82, -81, -82, -82, -83, -84, -84,   &
       -84, -87, -86, -87, -88,-105, -94,-105, -88, -87,   &
       -86, -87, -84, -84, -84, -83, -82, -82, -81, -82,   &
       -83, -79, -80, -81, -80, -78, -78, -76, -76, -77,   &
       -75, -75, -75, -74, -73, -72, -72, -72, -72, -71,   &
       -70, -70, -69, -69, -68, -67, -67, -67, -66, -65,   &
       -65, -64, -64, -63, -62, -62, -62, -61, -60, -60,   &
       -59, -59, -58, -57, -57, -56, -56, -55, -54, -54,   &
       -53, -53, -52, -51, -51, -50, -49, -49, -48, -47,   &
       -47, -46, -45, -45, -44, -43, -43, -42, -41, -41,   &
       -40, -39, -38, -38, -37, -36, -36, -35, -34, -33,   &
       -33, -32, -31, -30, -30, -29, -28, -27, -26, -26,   &
       -25, -24, -23, -22, -22, -21, -20, -19, -18, -17,   &
       -17, -16, -15, -14, -13, -12, -12, -11, -10,  -9,   &
        -8,  -7,  -7,  -6,  -5,  -4,  -4,  -3,  -2,  -2,   &
        -1,  -1,  -1,   0,   0,   1,   1,   1,   1,   2,   &
         2,   2,   2,   2,   3,   3,   3,   3,   3,   3,   &
         3,   3,   3,   4,   4,   4,   4,   4,   4,   4,   &
         4,   4,   4,   4,   4,   4,   4,   4,   4,   4,   &
         4,   4,   4,   4,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5,   5,   5,   5,   5,   5,   5,   5,   5,   &
         5,   5/
  save

  nargs=iargc()
  if(nargs.ne.6) then
     print*,'Usage: wspr_rx f0 nsec minsync nsave devin outfile'
     go to 999
  endif

  call getarg(1,arg)
  read(arg,*) f0
  call getarg(2,arg)
  read(arg,*) nsec
  call getarg(3,arg)
  read(arg,*) minsync
  call getarg(4,arg)
  read(arg,*) nsave
  call getarg(5,devin)
  ndevin=0
  read(devin,*,err=1) ndevin
1 call getarg(6,outfile)

  nsym=162                  !Symbols per transmission
  do i=1,nsym
     pr3(i)=2*npr3(i)-1
  enddo
  isec=mod(nsec,86400)
  ih=isec/3600
  im=(isec-ih*3600)/60
  is=mod(isec,60)
  write(cfile6,1030) ih,im,is
1030 format(3i2.2)

  open(13,file='ALL_MEPT.TXT',status='unknown',access='append')
  open(14,file='decoded.txt',status='unknown')

  if(ndevin.ge.0) then
     ierr=unlink('abort')
     ierr=getsound(ndevin,iwave)
     npts=114*12000
     call getrms(iwave,npts,ave,rms)
  else
#ifdef CVF
     open(12,file=outfile,form='binary',status='unknown')
#else
     open(12,file=outfile,access='stream',status='unknown')
#endif
     read(12) hdr
     read(12) (iwave(i),i=1,114*12000)
     close(12)
  endif
  call mept162(cfile6,f0,minsync,iwave,NMAX,rms,nsec)
  if(nsave.gt.0) then
     outfile='save/'//outfile
     call wfile5(iwave,npts,12000,outfile)
  endif

999 continue
end program wspr_rx

