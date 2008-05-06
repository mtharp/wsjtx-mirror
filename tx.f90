subroutine tx

!  Make one transmission in the MEPT_JT mode.

#ifdef CVF
  use dfport
#else
  integer time
#endif

  parameter (NMAX2=120*12000)
  character message*22,call1*12,cdbm*3
  character*22 msg2
  integer*2 jwave(NMAX2)
  integer soundout,ptt
  include 'acom1.f90'
  common/bcom/ntransmitted

  if(nqso.eq.0) then
     call1=callsign
     if(nport.gt.0) ierr=ptt(nport,junk,1,iptt)
     write(cdbm,'(i3)'),ndbm
     if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
     if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
     do i=6,1,-1
        if(call1(i:i).ne.' ') go to 10
     enddo

10   iz=i
     message=call1(1:iz)//' '//grid//' '//cdbm
  else
     message=ctxmsg
  endif

  ntxdf=nint(1.e6*(ftx-f0)) - 1500
  ctxmsg=message
  snr=99.0
  if(ntest.eq.1) snr=-26.0
  call genmept(message,ntxdf,snr,nreply,nsectx,msg2,jwave)
  ctxmsg=msg2
  if(nport.gt.0) ierr=ptt(nport,junk,1,iptt)
  npts=114*12000
  ierr=soundout(idevout,jwave,npts)
  if(nport.gt.0) ierr=ptt(nport,junk,0,iptt)
  ntransmitted=1
  ntxdone=1

  return
end subroutine tx
