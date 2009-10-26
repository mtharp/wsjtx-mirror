subroutine tx

!  Make one transmission in the MEPT_JT mode.

#ifdef CVF
  use dfport
  use dflib
#else
  integer system
#endif

  parameter (NMAX2=120*12000)
  character message*22,call1*12,cdbm*3
  character*22 msg0,msg1,msg2,cwmsg
  character cmnd*60
  integer*2 jwave(NMAX2)
  integer*2 icwid(48000)
  integer soundout,ptt
  include 'acom1.f90'
  common/bcom/ntransmitted
  data ntx/0/,ns0/0/
  save ntx,ns0

  cmnd=cmd
  ierr=0
  call1=callsign
  i0=index(cmnd,'@')
  if(pttmode.eq.'CAT') then
     cmnd(i0:)='T 1'
#ifdef CVF
     iret=runqq('rigctl.exe',cmnd(8:))
#else
     iret=system(cmnd)
#endif
  else
     if(nport.gt.0) ierr=ptt(nport,pttport,1,iptt)
  endif

  write(cdbm,'(i3)'),ndbm
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)
  if(cdbm(1:1).eq.' ') cdbm=cdbm(2:)

  ntx=1-ntx
  i1=index(call1,' ')
  i2=index(call1,'/')
  if(i2.gt.0 .or. igrid6.ne.0) then
! WSPR_2 message, in two parts
     if(i2.le.0) then
        msg1=call1(1:i1)//grid//' '//cdbm
     else
        msg1=call1(:i1)//cdbm
     endif
     msg0='<'//call1(:i1-1)//'> '//grid6//' '//cdbm
     if(ntx.eq.1) message=msg1
     if(ntx.eq.0) message=msg0
  else
! Normal WSPR message
     message=call1(1:i1)//grid//' '//cdbm
  endif
  ntxdf=nint(1.e6*(ftx-f0)) - 1500
  ctxmsg=message
  snr=99.0
  if(ntest.eq.1) snr=-26.0
  call genmept(message,ntxdf,snr,msg2,jwave)

  npts=114*12000
  if(nsec.lt.ns0) ns0=nsec
  if(idint.ne.0 .and. (nsec-ns0)/60.ge.idint) then
!  Generate and insert the CW ID.
     wpm=25.
     freqcw=1500.0 + ntxdf
     cwmsg=call1(:i1)//'                      '
     icwid=0
     call gencwid(cwmsg,wpm,freqcw,icwid,ncwid)
     k0=114*12000
     k1=115*12000
     jwave(k0:k1)=0
     jwave(k1+1:k1+48000)=icwid
     npts=k1+48000
     ns0=nsec
  endif

  sending=msg2
  ierr=soundout(ndevout,jwave,npts)
  if(ierr.ne.0) then
     print*,'Error in soundout',ierr
     stop
  endif

  if(pttmode.eq.'CAT') then
     cmnd(i0:)='T 0'
#ifdef CVF
     iret=runqq('rigctl.exe',cmnd(8:))
#else
     iret=system(cmnd)
#endif
  else
     if(nport.gt.0) ierr=ptt(nport,pttport,0,iptt)
  endif

  ntransmitted=1
  ntxdone=1

  return
end subroutine tx
