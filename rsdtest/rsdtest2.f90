program rsdtest2

  character msg*22,arg*12,cfile6*6,deepmsg*22
  character*12 mycall
  character*12 hiscall
  character*6 hisgrid
  integer*2 d2(293579)
  real dat(293579)
  include '../avecom.f90'

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: rsdtest nfiles'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) nfiles

  open(10,file='dat_1000_24dB.bin',access='stream',status='unknown')

  nadd=1
  ifile0=0
  if(nfiles.lt.0) then
     ifile0=-nfiles
     nfiles=99999
  endif

  call cs_init
  call setup65
  nsave=1
  ndepth=0
  neme=0
  mycall='VK7MO'
  hiscall='K1JT'
  hisgrid='FN20qi'
  mode65=1
  nfast=1
  nafc=0
  ngood=0
  nbad=0

  do ifile=1,nfiles
     read(10,end=999) cfile6,nsync,dtx,f0,flip,npts,d2
     if( ifile.lt.ifile0 ) cycle
     dat=d2
     dfx=f0-1270.46
     call decode65(dat,npts,dtx,dfx,flip,ndepth,neme,mycall,hiscall,hisgrid,  &
       mode65,nfast,nafc,msg,ncount,deepmsg,qual)

     if(msg.eq.'VK7MO K1JT FN20       ') ngood=ngood+1
     if(msg.ne.'VK7MO K1JT FN20       ' .and.                           &
        msg.ne.'                      ') nbad=nbad+1
     fgood=float(ngood)/ifile
     fbad=float(nbad)/ifile

     write(*,1010) cfile6,fgood,fbad,nsync,dtx,f0,msg
1010 format(a6,2f6.3,i3,f7.2,f7.1,1x,a22)
     if(ifile.eq.ifile0) exit
  enddo

999 end program rsdtest2
