subroutine savec2(fname,ntrseconds,dialFreq)

  parameter (NMAX=900*12000)         !Total sample intervals per 30 minutes
  parameter (NDMAX=900*1500)         !Sample intervals at 1500 Hz rate
  parameter (NSMAX=1366)             !Max length of saved spectra
  character*(*) fname
  character c2file*14
  real*8 dialFreq
  complex c0
  common/datcom/nutc,ndiskdat,id2(NMAX),savg(NSMAX),c0(NDMAX)

  open(18,file=fname,status='unknown',access='stream')

  i1=index(fname,'.c2')
  c2file=fname(i1-11:i1+2)
  ntrminutes=ntrseconds/60
  print*,'a ',c2file,ntrminutes,dialFreq
  write(18) c2file,ntrminutes,dialFreq,c0(1:45000)
  close(18)

  return
end subroutine savec2
