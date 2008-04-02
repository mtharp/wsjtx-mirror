program wspr_tx

!  Generate one transmission in the MEPT_JT mode.

#ifdef CVF
  use dfport
#else
  integer time
  integer unlink
#endif

  parameter (NMAX=120*12000)
  real*8 f0,ftx
  character*12 arg
  character*12 call1
  character*4 grid
  character*3 cdbm
  character*22 message
  character*32 devout
  integer*2 iwave(NMAX)
  integer playsound,ptt

  nargs=iargc()
  if(nargs.ne.7) then
     print*,'Usage: wspr_tx call grid dBm nport ntxdf devout f0'
     go to 999
  endif

  call getarg(1,call1)
  call getarg(2,grid)
  call getarg(3,arg)
  read(arg,*) ndbm
  call getarg(4,arg)
  read(arg,*) nport
  call getarg(5,arg)
  read(arg,*) ntxdf
  call getarg(6,devout)
  ndevout=0
  read(devout,*,err=1) ndevout
1 call getarg(7,arg)
  read(arg,*) f0

  nsec=time()
  isec=mod(nsec,86400)
  ih=isec/3600
  im=(isec-ih*3600)/60
  is=mod(isec,60)
  if(nport.gt.0) ierr=ptt(nport,junk,1,iptt)
  write(cdbm,'(i3)'),ndbm
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  do i=6,1,-1
     if(call1(i:i).ne.' ') go to 10
  enddo
10 iz=i
  message=call1(1:iz)//' '//grid//' '//cdbm
  do i=22,1,-1
     if(message(i:i).ne.' ') go to 20
  enddo
20 iz=i
  open(13,file='ALL_MEPT.TXT',status='unknown',access='append')
!  open(13,file='ALL_MEPT.TXT',status='unknown',position='append')   ! or that if compiler error
  ftx=f0 + 0.001500d0
  write(13,1010) ih,im,ftx,message(1:iz)
1010 format(2i2.2,14x,f11.6,'  Transmitting "',a,'"')
  close(13)

  call genmept(call1,grid,ndbm,ntxdf,99.0,iwave)
  if(nport.gt.0) ierr=ptt(nport,junk,1,iptt)
  ierr=unlink('abort')
  ierr=playsound(ndevout,iwave)
  if(nport.gt.0) ierr=ptt(nport,junk,0,iptt)

999 continue
end program wspr_tx
