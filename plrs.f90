program plrs

! Pseudo-Linrad "Send" program.  Reads recorded Linrad data from "*.tf2"
! files, and multicasts it as Linrad would do for timf2 data.

  integer RMODE
  parameter(RMODE=0)
  parameter (NBPP=1392)                  !Bytes of sampled data per packet
!  parameter (NZ=60*96000)
  parameter (NZ=6*952381)
  parameter (NBYTES=4*NZ)
  parameter (NPPR=NBYTES/NBPP)
  integer*1 userx_no,iusb
  integer*2 nblock
  real*8 d(NZ),buf8
  integer fd
  integer open,read,close
  integer nm(11)
  character*8 fname,arg,cjunk*1
  logical fast,pause
  real*8 center_freq,dmsec,dtmspacket,tmsec
  common/plrscom/center_freq,msec2,fsample,iptr,nblock,userx_no,iusb,buf8(174)
  data nm/45,46,48,50,52,54,55,56,57,58,59/
  data nblock/0/,fast/.false./,pause/.false./

  nargs=iargc()
  if(nargs.ne.4) then
     print*,'Usage: plrs <fast|pause|slow> <minutes> <iters> <iwait>'
     go to 999
  endif

  call getarg(1,arg)
  if(arg(1:1).eq.'f' .or. arg(1:1).eq.'p') fast=.true.
  if(arg(1:1).eq.'p') pause=.true.
  call getarg(2,arg)
  read(arg,*) nfiles
  call getarg(3,arg)
  read(arg,*) iters
  call getarg(4,arg)
  read(arg,*) iwait

  if(iwait.ne.0) then
1    if(mod(int(sec_midn()),60).eq.0) go to 2
     call sleep_msec(100)
     go to 1
  endif

2 fname="all.iq"//char(0)
  userx_no=0
  iusb=1
  center_freq=144.125d0
!  dtmspacket=1000.d0*NBPP/(8.d0*96000.d0)
  dtmspacket=1000.d0*NBPP/(4.d0*95238.1d0)
  print*,nz,nbytes,nppr,dtmspacket

!  fsample=96000.0
  fsample=95238.1
  npkt=0

  call setup_ssocket                       !Open a socket for multicasting

  do iter=1,iters
     open(10,file=fname,access='stream',status='old')
     dmsec=-dtmspacket
     nsec0=sec_midn()

     do ifile=1,nfiles
        ns0=0
        tmsec=1000*(3600*7 + 60*nm(ifile))-dtmspacket
        k=0
        do ipacket=1,NPPR
           dmsec=dmsec+dtmspacket
           tmsec=tmsec+dtmspacket
           msec2=nint(tmsec)
           msec=nint(dmsec)

           read(10) buf8
           nblock=nblock+1
           call send_pkt(center_freq)
           npkt=npkt+1
              
           if(mod(npkt,100).eq.0) then
              nsec=int(sec_midn())-nsec0
              nwait=msec-1000*nsec
!  Pace the data at close to its real-time rate
              if(nwait.gt.0 .and. .not.fast) call sleep_msec(nwait)
           endif
           ns=mod(msec2/1000,60)
           if(ns.ne.ns0) write(*,1010) ns,center_freq,0.001*msec2,sec_midn()
1010       format('ns:',i3,'   f0:',f10.3,'   t1:',f10.3,'   t2:',f10.3)
           ns0=ns
        enddo
        if(pause) then
           print*,'Type anything to continue:'
           read(*,*) cjunk,pause,fast
        endif
     enddo
     close(10)
  enddo


999 end program plrs

! To compile: % gfortran -o plrs plrs.f90 plrs_subs.c cutil.c
