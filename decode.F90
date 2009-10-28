subroutine decode

!  Decode MEPT_JT signals for one 2-minute sequence.

#ifdef CVF
  use dfport
#endif
  character*80 savefile
  integer*2 jwave(114*12000)

  include 'acom1.f90'

  minsync=1
  if(nsave.gt.0 .and. ndiskdat.eq.0) jwave=iwave

  call mept162(thisfile,f0,minsync,iwave,NMAX,nbfo,ierr)
  if(nsave.gt.0 .and. ndiskdat.eq.0 .and. ierr.eq.0) then
     savefile='save/'//thisfile
     npts=114*12000
     call wfile5(jwave,npts,12000,savefile)
  endif
  write(14,1100)
1100 format('$EOF')
  call flush(14)
  rewind 14
  ndecdone=1
  ndiskdat=0
  ndecoding=0

  return
end subroutine decode
