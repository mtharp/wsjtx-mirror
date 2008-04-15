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
  nsec2=time()
  if(ndebug.ne.0) then
     write(*,1010) mod(nsec1,120),mod(nsec2,120),nsec2-nsec1
1010 format('Rx: '3i5)
  endif
  call getrms(iwave,npts,ave,rms)
  nrxdone=1

  return
end subroutine rx

