subroutine tx

!  Make one transmission in the MEPT_JT mode.

#ifdef CVF
  use dfport
#endif

  parameter (NMAX2=120*12000)
  character message*22,call1*12,cdbm*3
  character*22 msg2
  integer*2 jwave(NMAX2)
  integer soundout,ptt
  include 'acom1.f90'
  common/bcom/ntransmitted

  call1=callsign
  ierr=ptt(nport,pttport,1,iptt)
  if(ierr.ne.0) then
     print*,'Error using PTT port',ierr
     stop
  endif
  write(cdbm,'(i3)'),ndbm
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  do i=6,1,-1
     if(call1(i:i).ne.' ') go to 10
  enddo

10 iz=i
  message=call1(1:iz)//' '//grid//' '//cdbm

  ntxdf=nint(1.e6*(ftx-f0)) - 1500
  ctxmsg=message
  snr=99.0
  if(ntest.eq.1) snr=-26.0
  call genmept(message,ntxdf,snr,msg2,jwave)
  sending=msg2
  ierr=ptt(nport,pttport,1,iptt)
  if(ierr.ne.0) then
     print*,'Error using PTT port',ierr
     stop
  endif
  npts=114*12000
  ierr=soundout(idevout,jwave,npts)
  if(ierr.ne.0) then
     print*,'Error in soundout',ierr
     stop
  endif
  ierr=ptt(nport,pttport,0,iptt)
  if(ierr.ne.0) then
     print*,'Error using PTT port',ierr
     stop
  endif
  ntransmitted=1
  ntxdone=1

  return
end subroutine tx
