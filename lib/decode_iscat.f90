subroutine decode_iscat(nutc,id2,ndat0,newdat,minsync,t0,t1,line)

  integer*2 id2(ndat0)
  real dat(30*12000)
  complex cdat(262145)
  real psavg(450)
  logical pick
  character*6 cfile6
  character*80 line
  save cdat,npts

  write(cfile6,'(i6.6)') nutc

  if(newdat.eq.1) then
     ndat=ndat0
     call wav11(id2,ndat,dat)

     ndat=min(ndat,30*11025)
     call ana932(dat,ndat,cdat,npts)          !Make downsampled analytic signal
  endif

! Now cdat() is the downsampled analytic signal.  
! New sample rate = fsample = BW = 11025 * (9/32) = 3100.78125 Hz
! NB: npts, nsps, etc., are all reduced by 9/32

  ntol=400
  nfreeze=1
  mousedf=0
  mousebutton=0
  mode4=2
  nafc=0
  ndebug=0
  t2=0.
  ia=1
  ib=npts
  dt=1.0/12000.0 * (32.0/9.0)
  if(t0.gt.0.0) then
     ia=t0/dt + 1.
     ib=t1/dt
     pick=.true.
  endif
  jz=ib-ia+1

  call iscat(cdat(ia),jz,3,40,t2,pick,cfile6,minsync,ntol,NFreeze,    &
       MouseDF,mousebutton,mode4,nafc,ndebug,psavg,npkept,line)

end subroutine decode_iscat
