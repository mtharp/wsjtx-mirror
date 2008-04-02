  parameter (NMAX=120*12000)                          !Max length of waveform
  real*8 f0,ftx
  character*80 infile,outfile
  character cdate*8,utctime*10
  character callsign*6,grid*4
  integer*2 iwave
  common/acom/ f0,ftx,rms,nsec,ndevin,ndevout,nsave,nrxdone,ndbm,      &
       ndecdone,ntxdone,iwave(NMAX),infile,outfile,cdate,utctime,      &
       callsign,grid
