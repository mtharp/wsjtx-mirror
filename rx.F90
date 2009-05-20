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
  nsec1=time()
  ierr=soundin(idevin,iwave,npts)
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif
  nsec2=time()
  call getrms(iwave,npts,ave,rms)
  nrxdone=1

  return
end subroutine rx

