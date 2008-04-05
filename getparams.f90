subroutine getparams(f0,ftx,nport,callsign,grid,ndbm,                 &
  pctx,idsec,ndevin,ndevout,nsave,infile)

  real*8 f0,ftx
  character callsign*6,grid*4
  character*70 infile
  character arg*20

  call getarg(1,arg)
  read(arg,*) f0
  call getarg(2,arg)
  read(arg,*) ftx
  call getarg(3,arg)
  read(arg,*) nport
  call getarg(4,callsign)
  call getarg(5,grid)
  call getarg(6,arg)
  read(arg,*) ndbm
  call getarg(7,arg)
  read(arg,*) pctx
  call getarg(8,arg)
  read(arg,*) idsec
  call getarg(9,arg)
  read(arg,*) ndevin
  call getarg(10,arg)
  read(arg,*) ndevout
  call getarg(11,arg)
  read(arg,*) nsave
  call getarg(12,infile)

  return
end subroutine getparams
