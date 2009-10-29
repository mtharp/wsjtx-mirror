  parameter (NMAX=120*12000)                          !Max length of waveform
  real*8 f0,ftx
  logical ltest,nreceiving,ntransmitting
  character*80 infile,outfile,pttport,thisfile
  character cdate*8,utctime*10,rxtime*4
  character cmd*60,pttmode*3
  character callsign*12,grid*4,grid6*6,ctxmsg*22,sending*22
  integer*2 iwave
  common/acom1/ f0,ftx,rms,pctx,igrid6,nsec,ndevin,ndevout,nsave,       &
       nrxdone,ndbm,nport,ndec,ndecdone,ntxdone,receiving,idint,        &
       transmitting,ndiskdat,ndecoding,ntr,ndebug,idevin,idevout,       &
       idsec,nsectx,nbfo,ntxfirst,ntest,ncat,ltest,iwave(NMAX),         &
       idle,ntune,ndevsok,nsec1,nsec2,rms1,xdb1,infile,outfile,pttport, &
       cdate,utctime,callsign,grid,grid6,rxtime,ctxmsg,sending,         &
       thisfile,cmd,pttmode
