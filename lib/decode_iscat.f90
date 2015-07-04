subroutine decode_iscat(nutc,id2,ndat0,newdat,minsync,npick,t0,t1,line)

  integer*2 id2(ndat0)
  real dat(30*12000)
  complex cdat(262145)
  complex cdat2(262145)
  real psavg(450)
  logical pick
  character*6 cfile6
  character*80 line
  save cdat,cdat2,npts

  if(newdat.eq.1) then
     cdat2=cdat
     ndat=ndat0
     call wav11(id2,ndat,dat)
     ndat=min(ndat,30*11025)
     call ana932(dat,ndat,cdat,npts)          !Make downsampled analytic signal
  endif

! Now cdat() is the downsampled analytic signal.  
! New sample rate = fsample = BW = 11025 * (9/32) = 3100.78125 Hz
! NB: npts, nsps, etc., are all reduced by 9/32

  write(cfile6,'(i6.6)') nutc
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
  dt=1.0/11025.0 * (32.0/9.0)
  pick=.false.
  if(npick.gt.0) then
     pick=.true.
     ia=t0/dt + 1.
     ib=t1/dt + 1.
  endif
  jz=ib-ia+1
  if(npick.eq.2) then
     call iscat(cdat2(ia),jz,3,40,t2,pick,cfile6,minsync,ntol,NFreeze,    &
          MouseDF,mousebutton,mode4,nafc,ndebug,psavg,npkept,line)
  else
     call iscat(cdat(ia),jz,3,40,t2,pick,cfile6,minsync,ntol,NFreeze,     &
          MouseDF,mousebutton,mode4,nafc,ndebug,psavg,npkept,line)
  endif

end subroutine decode_iscat
