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
  call mept162(outfile,f0,minsync,iwave,NMAX,rms,nsec,.false.)
  if(nsave.gt.0 .and. ndevin.ge.0) then
     outfile='save/'//outfile
     call wfile5(iwave,npts,12000,outfile)
  endif

  call flush(14)
  rewind 14
  ndecdone=1

  return
end subroutine decode
