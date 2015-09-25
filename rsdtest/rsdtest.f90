program rsdtest

  real s3(64,63)
  character msg*22,arg*12
  integer param(0:7)

  nargs=iargc()
  if(nargs.ne.2) then
     print*,'Usage: rsdtest ntrials nfiles'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) ntrials
  call getarg(2,arg)
  read(arg,*) nfiles

  open(10,file='s3_1000.bin',form='unformatted', status='old')
  open(22,file='kvasd.dat',access='direct',recl=1024,status='unknown')

  nadd=1
  ngood=0
  ifile0=0
  if(nfiles.lt.0) then
     ifile0=-nfiles
     nfiles=99999
  endif

  ndone=0
  do ifile=1,nfiles
     read(10,end=999) s3
     if(ifile.lt.ifile0) cycle
     ndone=ndone+1
     call extract2(s3,nadd,ntrials,param,msg)
     if(msg.ne.'                      ') ngood=ngood+1
     write(*,1010) ifile,float(ngood)/ndone,param,msg
     write(32,1010) ifile,float(ngood)/ndone,param,msg
1010 format(i5,f8.3,i9,7i4,2x,a22)
     if(ifile.eq.ifile0) exit
  enddo

999 end program rsdtest
