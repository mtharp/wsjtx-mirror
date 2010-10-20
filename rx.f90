subroutine rx

!  Receive and decode MEPT_JT signals for one 2-minute sequence.

  integer time

  integer soundin
  include 'acom1.f90'

  npts=114*12000
  if(ncal.eq.1) npts=65536
  nsec1=time()
  f0a=f0                                   !Save rx frequency at start
  ierr=soundin(ndevin,kwave,4*npts,iqmode)
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif

  call cs_lock('rx_a')
  write(*,3001) iqmode,gain,57.2957795*phase,reject
3001 format('Rx: ',i3,2f9.6,f8.2)
  call cs_unlock

  if(iqmode.eq.1) then
     call iqdemod(kwave,4*npts,nfiq,iqrx,iqrxapp,gain,phase,iwave)
  else
     call fil1(kwave,4*npts,iwave,n2)         !Filter and downsample
     npts=n2
  endif
  nsec2=time()
  call getrms(iwave,npts,ave,rms)          !### is this needed any more??
  call cs_lock('rx')
  nrxdone=1
  if(ncal.eq.1) ncal=2
  call cs_unlock

  return
end subroutine rx

