subroutine rx

!  Receive and decode MEPT_JT signals for one 2-minute sequence.

#ifdef CVF
  use dfport
#else
  integer time
#endif

  integer soundin
  include 'acom1.f90'

  npts=114*12000
  if(ncal.eq.1) npts=65536
  nsec1=time()
  ierr=soundin(ndevin,kwave,4*npts)
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif
  call fil1(kwave,4*npts,iwave,n2)
  npts=n2
  nsec2=time()
  call getrms(iwave,npts,ave,rms)          !### is this needed any more??
  nrxdone=1

  return
end subroutine rx

