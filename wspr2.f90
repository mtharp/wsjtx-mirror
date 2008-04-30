subroutine wspr2

#ifdef CVF
  use dfport
#endif

! Logical units:
!  12  Audio data in *.wav file
!  13  ALL_MEPT.TXT
!  14  decoded.txt
!  16  pixmap.dat

  character*17 message
  real*8 tsec
  logical idle,receiving,transmitting,decoding,gui,cmnd
  integer nchin(0:20),nchout(0:20)
  include 'acom1.f90'
  data idle/.true./,receiving/.false./,transmitting/.false./
  data decoding/.false./,ns1200/-999/

#ifdef CVF
  open(14,file='decoded.txt',status='unknown',share='denynone')
#else
  open(14,file='decoded.txt',status='unknown')
#endif
  write(14,1002)
1002 format('$EOF')
  call flush(14)
  rewind 14

  idevin=ndevin
  idevout=ndevout

  call padevsub(numdevs,ndefin,ndefout,nchin,nchout)
  write(*,1003) idevin,idevout
1003 format(/'User requested devices:  Input =',i2,'   Output =',i2)
  write(*,1004) ndefin,ndefout
1004 format( 'Default devices:         Input =',i2,'   Output =',i2)
  if(idevin.lt.0 .or. idevin.ge.numdevs) idevin=ndefin
  if(idevout.lt.0 .or. idevout.ge.numdevs) idevout=ndefout
  if(idevin.eq.0 .and. idevout.eq.0) then
     idevin=ndefin
     idevout=ndefout
  endif
  write(*,1005) idevin,idevout
1005 format( 'Will open devices:       Input =',i2,'   Output =',i2)
  write(*,1006)
1006 format(66('*'))
  call random_seed
  nrx=1

20 call getutc(cdate,utctime,tsec)
  tsec=tsec+0.1*idsec
  nsec=tsec
  ns120=mod(nsec,120)
  if(pctx.gt.50.0) nrx=0
  rxavg=1.0
  if(pctx.gt.0.0) rxavg=100.0/pctx - 1.0
  rr=3.0
  if(pctx.ge.40.0) rr=1.5                    !soft step?

  if(nrxdone.gt.0) then
     receiving=.false.
     nrxdone=0
     decoding=.true.
     call startdec
  endif

  if(ntxdone.gt.0) then
     transmitting=.false.
     ntxdone=0
  endif

  idle=.false.
  if(pctx.lt.0.0) idle=.true.

  if(ns120.ge.114) then
     transmitting=.false.
     receiving=.false.
     ntr=0
  endif

  if(ns120.eq.0 .and. (.not.transmitting) .and. (.not.receiving) .and. &
       (.not.idle)) go to 30

  call msleep(100)
  go to 20

30 outfile=cdate(3:8)//'_'//utctime(1:4)//'.'//'wav'
  if(pctx.eq.0.0) nrx=1
  if(nrx.eq.0) then
     call random_number(x)
     nrx=nint(rxavg + rr*(x-0.5))
     transmitting=.true.
     write(message(13:16),'(i4)') ndbm
     message(1:12)='"'//callsign//' '//grid
     message(17:17)='"'
     do i=1,4
        i1=index(message,'  ')
        message=message(:i1)//message(i1+2:)
     enddo

#ifdef CVF
     open(13,file='ALL_MEPT.TXT',status='unknown',                   &
          position='append',share='denynone')
#else
     open(13,file='ALL_MEPT.TXT',status='unknown',position='append')
#endif

     write(13,1030) cdate(3:8),utctime(1:4),ftx,message
1030 format(a6,1x,a4,14x,f11.6,2x,'Transmitting ',a17)
     close(13)

     ntr=-1
     nsectx=mod(nsec,86400)
     call starttx

  else
     receiving=.true.
     rxtime=utctime(1:4)
     ntr=1
     call startrx
     nrx=nrx-1
  endif
  go to 20

  return
end subroutine wspr2
