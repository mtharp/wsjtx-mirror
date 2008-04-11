subroutine decode

!  Decode MEPT_JT signals for one 2-minute sequence.

#ifdef CVF
  use dfport
#else
  integer time
#endif

  include 'acom1.f90'

  minsync=1
  nsec=time()
  ndec=0
  call mept162(outfile,f0,minsync,iwave,NMAX,rms,nsec,.false.,ndec)
  if(nsave.gt.0 .and. ndevin.ge.0) then
     outfile='save/'//outfile
     npts=114*12000
     call wfile5(iwave,npts,12000,outfile)
  endif

  if(ndec.ne.0) then
     call flush(14)
     rewind 14
     ndecdone=1
  endif

  return
end subroutine decode
