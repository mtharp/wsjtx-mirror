  parameter (NMAX=120*12000)                          !Max length of waveform
  parameter (NZ=120*48000)
  real*8 f0,ftx,fcal,calfac
  logical ltest,receiving,transmitting
  character*80 infile,outfile,pttport,thisfile
  character cdate*8,utctime*10,rxtime*4,catport*12
  character pttmode*3
  character callsign*12,grid*4,grid6*6,ctxmsg*22,sending*22
  integer*2 iwave,kwave
  common/acom1/ f0,ftx,fcal,calfac,rms,pctx,igrid6,nsec,ndevin,        &
       ndevout,nsave,nrxdone,ndbm,nport,ndec,ndecdone,ntxdone,         &
       idint,ndiskdat,ndecoding,ntr,nbaud,ndatabits,nstopbits,         &
       receiving,transmitting,nrig,                                    &
       nhandshake,ndebug,idevin,idevout,idsec,nsectx,nbfo,             &
       ntxfirst,ntest,ncat,ltest,iwave(NMAX),kwave(NZ),idle,ntune,     &
       ncal,ndevsok,nsec1,nsec2,rms1,xdb1,infile,outfile,pttport,      &
       cdate,utctime,callsign,grid,grid6,rxtime,ctxmsg,sending,        &
       thisfile,pttmode,catport
