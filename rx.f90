subroutine rx

!  Receive and decode MEPT_JT signals for one 2-minute sequence.

  integer soundin
  include 'acom1.f90'

  npts=114*12000
  ierr=soundin(iwave,npts)
  call getrms(iwave,npts,ave,rms)
  nrxdone=1

  return
end subroutine rx

