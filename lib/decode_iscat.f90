subroutine decode_iscat(id2,ndat0,newdat,minsync,ix,iy,line)

  integer*2 id2(ndat0)
  real dat(30*12000)
  complex cdat(262145)
  real psavg(450)
  logical pick
  character*6 cfile6
  character*80 line

  print*,ndat0,newdat,minsync,ix,iy

  ndat=ndat0
  call wav11(id2,ndat,dat)

  t2=0.
!  if(pick) t2=(istart+0.5*ndat)/11025.0 + 0.5           !### +0.5 is empirical
  ndat=min(ndat,30*11025)
  call ana932(dat,ndat,cdat,npts)          !Make downsampled analytic signal

! Now cdat() is the downsampled analytic signal.  
! New sample rate = fsample = BW = 11025 * (9/32) = 3100.78125 Hz
! NB: npts, nsps, etc., are all reduced by 9/32

  cfile6='1234  '
  MinSigdB=0
  ntol=400
  nfreeze=1
  mousedf=0
  mousebutton=0
  mode4=2
  nafc=0
  ndebug=0
  t2=0.
  pick=.false.

  call iscat(cdat,npts,3,40,t2,pick,cfile6,MinSigdB,ntol,NFreeze,    &
       MouseDF,mousebutton,mode4,nafc,ndebug,psavg,npkept,line)

end subroutine decode_iscat
