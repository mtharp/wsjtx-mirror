subroutine rx

!  Receive and decode MEPT_JT signals for one 2-minute sequence.

#ifdef CVF
  use dfport
#endif

  integer*1 hdr(44)
  integer soundin
  logical first
  include 'acom1.f90'
  data first/.true./
  save first

  npts=114*12000
  if(ndevin.ge.0) then
     ierr=unlink('abort')
     ierr=soundin(iwave,npts)
     call getrms(iwave,npts,ave,rms)
  else

#ifdef CVF
     open(12,file=infile,form='binary',status='unknown')
#else
     open(12,file=infile,access='stream',status='unknown')
#endif

     read(12) hdr
     read(12) (iwave(i),i=1,114*12000)
     close(12)
     call getrms(iwave,npts,ave,rms)
  endif

  nrxdone=1

  return
end subroutine rx

