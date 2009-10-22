subroutine decode

!  Decode MEPT_JT signals for one 2-minute sequence.

#ifdef CVF
  use dfport
#endif
  character*80 savefile

  include 'acom1.f90'

  minsync=1
  ndec=0
  t0=secnds(0.)
  call mept162(thisfile,f0,minsync,iwave,NMAX,ndec,nbfo,ierr)
  t1=secnds(t0)
  print*,'Decoding time:',t1
  if(nsave.gt.0 .and. ndiskdat.eq.0 .and. ierr.eq.0) then
     savefile='save/'//outfile
     npts=114*12000
     call wfile5(iwave,npts,12000,savefile)
  endif

  if(ndec.eq.0) then
     write(14,1100)
1100 format('$EOF')
  endif
  call flush(14)
  rewind 14
  ndecdone=1
  ndiskdat=0
  ndecoding=0

  return
end subroutine decode
