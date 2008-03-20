subroutine mept_rx(nargs,ntr)

!  Read Rx command-line args and the decode MEPT_JT signals from disk
!  or real-time data.

#ifdef CVF
  use dfport
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
  logical first
  real*8 t,dt,phi,f,f0,dfgen,dphi,pi,twopi,tsymbol
  character*20 arg
  character*70 infile
  character*6 cfile6
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
  data first/.true./,nsec0/999999/
  save

  call getarg(2,arg)
  read(arg,*) f0
  nfiles=0
  if(ntr.eq.0) nfiles=nargs-2

  nsym=162                  !Symbols per transmission
  if(first) then
     do i=1,nsym
        pr3(i)=2*npr3(i)-1
     enddo
     pi=4.d0*atan(1.d0)
     twopi=2.d0*pi
     open(13,file='ALL_MEPT.TXT',status='unknown',access='append')
     first=.false.
  endif

  if(nfiles.ge.1) then
     do ifile=1,nfiles
        call getarg(2+ifile,infile)
#ifdef CVF
        open(10,file=infile,form='binary',status='old')
#else
        open(10,file=infile,access='stream',status='old')
#endif
        read(10) hdr
        read(10) iwave
        cfile6=infile
        i1=index(infile,'.')
        if(i1.ge.2) then
           i0=max(1,i1-6)
           cfile6=infile(i0:i1-1)
        endif
        call getrms(iwave,NMAX,ave,rms)
        call mept162(cfile6,f0,iwave,NMAX,rms)
     enddo
  else
20   nsec=time()
     isec=mod(nsec,86400)
     ih=isec/3600
     im=(isec-ih*3600)/60
     is=mod(isec,60)
     if(mod(im,2).ne.0) go to 30
     if(is.eq.0) then
        write(cfile6,1030) ih,im,is
1030    format(3i2.2)
        ierr=getsound(iwave)
        npts=114*12000
        call getrms(iwave,npts,ave,rms)
        call mept162(cfile6,f0,iwave,NMAX,rms)
        if(ntr.ne.0) go to 999
     endif
30   call pa_sleep(100)
     go to 20
  endif
      
999 return
end subroutine mept_rx

