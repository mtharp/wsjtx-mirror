  parameter (NMAX=120*12000)                          !Max length of waveform
  real*8 f0,ftx
  logical ltest
  integer nreceiving
  integer ntransmitting
  integer mtx1
  character*80 infile,outfile,pttport,thisfile
  character cdate*8,utctime*10,rxtime*4
  character cmd*60,pttmode*3,cmtx*12
  character callsign*6,grid*4,ctxmsg*22,sending*22
  integer*2 iwave
  common/acom1/ f0,ftx,rms,pctx,nsec,ndevin,ndevout,nsave,nrxdone,      &
       ndbm,nport,ndec,ndecdone,ntxdone,nreceiving,ntransmitting,mtx1,  &
       ndiskdat,ndecoding,ntr,ndebug,idevin,idevout,idsec,nsectx,       &
       ntxfirst,ntest,ncat,ltest,iwave(NMAX),nsec1,nsec2,rms1,xdb1,     &
       infile,outfile,pttport,cdate,utctime,callsign,grid,rxtime,       &
       ctxmsg,sending,thisfile,cmd,cmtx,pttmode
