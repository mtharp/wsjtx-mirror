subroutine decoder(ntrSeconds,c0)

! Decoder for JT9.  Can run stand-alone, reading data from *.wav files;
! or as the back end of wsjt-x, with data placed in a shared memory region.

! NB: For unknown reason, ***MUST*** be compiled by g95 with -O0 !!!

  parameter (NMAX=1800*12000)        !Total sample intervals per 30 minutes
  parameter (NDMAX=1800*1500)        !Sample intervals at 1500 Hz rate
  parameter (NSMAX=22000)            !Max length of saved spectra
  character*22 msg
  real*4 ccfred(NSMAX)
  integer*1 i1SoftSymbols(207)
  integer*2 id2
  complex c0(NDMAX)
  common/jt9com/ss(184,NSMAX),savg(NSMAX),id2(NMAX),nutc,ndiskdat,    &
       ntr,nfqso,nagain,newdat,npts8,nfb,ntol,kin
  logical first
  data first/.true./
  save

  ntrMinutes=ntrSeconds/60
  newdat=1

  nsps=0
  if(ntrMinutes.eq.1) then
     nsps=6912
     df3=1500.0/2048.0
  else if(ntrMinutes.eq.2) then
     nsps=15360
     df3=1500.0/2048.0
  else if(ntrMinutes.eq.5) then
     nsps=40960
     df3=1500.0/6144.0
  else if(ntrMinutes.eq.10) then
     nsps=82944
     df3=1500.0/12288.0
  else if(ntrMinutes.eq.30) then
     nsps=252000
     df3=1500.0/32768.0
  endif
  if(nsps.eq.0) stop 'Error: bad TRperiod'    !Better: return an error code###

! Now do the decoding
  kstep=nsps/2
  tstep=kstep/12000.0

! Get sync, approx freq
  call sync9(ss,tstep,df3,ntol,nfqso,sync,snr,fpk0,ccfred)
  call spec9(c0,npts8,nsps,fpk0,fpk,xdt,i1SoftSymbols)
  call decode9(i1SoftSymbols,msg)

  nsync=sync
  nsnr=nint(snr)
  width=0.0
  open(13,file='decoded.txt',status='unknown')
  rewind 13
  write(13,1010) nutc,nsync,nsnr,xdt,1000.0+fpk,width,msg
1010 format(i4.4,i4,i5,f6.1,f8.2,f6.2,3x,a22)
  call flush(13)
  close(13)
  if(first) then
     open(14,file='wsjtx_rx.log',status='unknown',position='append')
     first=.false.
  endif
  write(14,1010) nutc,nsync,nsnr,xdt,1000.0+fpk,width,msg
  call flush(14)

  return
end subroutine decoder
