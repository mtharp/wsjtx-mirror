subroutine rx

! Receive WSPR signals for one 2-minute sequence.

  integer time

  integer soundin
  include 'acom1.f90'

  if(ncal.eq.1) npts=65536
  call cs_lock('rx')
  nsec1=time()
  nfhopok=0                                !Don't hop! 
  f0a=f0                                   !Save rx frequency at start
  call cs_unlock
  kwave=0
  if(ntrminutes.eq.2) then
     npts=114*12000
     ierr=soundin(ndevin,48000,kwave,4*npts,iqmode)
  else
     npts=890*12000
     ierr=soundin(ndevin,12000,kwave,npts,iqmode)
  endif
  call cs_lock('rx')
  f0a=f0
  rxtime2=rxtime
  nfhopok=1                                !Data acquisition done, can hop 
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif
  call cs_unlock

  if(ntrminutes.eq.2) then
     if(iqmode.eq.1) then
        call iqdemod(kwave,4*npts,nfiq,nbfo,iqrx,iqrxapp,gain,phase,iwave)
     else
        call loggit('Start downsampling')
        call fil1(kwave,4*npts,iwave,n2)       !Filter and downsample
        npts=n2
     endif
  else
     iwave=kwave
  endif

  call getrms(iwave,npts,ave,rms)           !### is this needed any more??
  call cs_lock('rx')
  nrxdone=1
  if(ncal.eq.1) ncal=2
  call cs_unlock
  call loggit('Rx done')

  return
end subroutine rx

