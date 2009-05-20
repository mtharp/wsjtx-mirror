subroutine decode

!  Decode MEPT_JT signals for one 2-minute sequence.

#ifdef CVF
  use dfport
#endif
  character*80 savefile

  include 'acom1.f90'

  minsync=1
  ndec=0
  print*,'A'
  call mept162(thisfile,f0,minsync,iwave,NMAX,ndec,ierr,mtx1,cmtx)
  print*,'B'
  if(nsave.gt.0 .and. ndiskdat.eq.0 .and. ierr.eq.0) then
     savefile='save/'//outfile
     npts=114*12000
     call fthread_mutex_lock(mtx1)
     cmtx='decode'
     call wfile5(iwave,npts,12000,savefile)
     cmtx=''
     call fthread_mutex_unlock(mtx1)
  endif

  print*,'C'
  call fthread_mutex_lock(mtx1)
  cmtx='decode'
!  if(ndec.eq.0) then
!     write(14,1100)
!1100 format('$EOF')
!  endif
  call flush(14)
  rewind 14
  cmtx=''
  call fthread_mutex_unlock(mtx1)
  print*,'D'

  ndecdone=1
  ndiskdat=0
  ndecoding=0

  return
end subroutine decode
