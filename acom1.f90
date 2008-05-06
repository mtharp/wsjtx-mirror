  parameter (NMAX=120*12000)                          !Max length of waveform
  real*8 f0,ftx
  logical ltest
  integer nreceiving
  integer ntransmitting
  character*80 infile,outfile
  character cdate*8,utctime*10,rxtime*4
  character callsign*6,grid*4,ctxmsg*22
  integer*2 iwave
  common/acom1/ f0,ftx,rms,pctx,nsec,ndevin,ndevout,nsave,nrxdone,      &
       ndbm,nport,ndec,ndecdone,ntxdone,nreceiving,ntransmitting,       &
       ndiskdat,ndecoding,ntr,ndebug,idevin,idevout,idsec,nsectx,       &
       nreply,ntxfirst,nqso,ntest,ltest,iwave(NMAX),                    &
       infile,outfile,cdate,utctime,callsign,grid,rxtime,ctxmsg
