program wspr_tx

!  Generate one transmission in the MEPT_JT mode.

#ifdef CVF
  use dfport
#endif

  parameter (NMAX=120*12000)
  real*8 f0,ftx
  character*12 arg
  character*12 call1
  character*4 grid
  character*3 cdbm
  character*22 message
  integer*2 iwave(NMAX)
  integer playsound,ptt

  nargs=iargc()
  if(nargs.ne.5) then
     print*,'Usage: wspr_tx call grid dBm nport ntxdf'
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

  write(cdbm,'(i3)'),ndbm
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  message=call1(1:i1)//grid//' '//cdbm
  call genmept(call1,grid,ndbm,ntxdf,99.0,iwave)
  if(nport.gt.0) ierr=ptt(nport,junk,1,iptt)
  ierr=playsound(iwave)
  if(nport.gt.0) ierr=ptt(nport,junk,0,iptt)

999 continue
end program wspr_tx
