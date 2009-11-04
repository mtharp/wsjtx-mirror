subroutine wspr2

#ifdef CVF
  use dfport
#endif

! Logical units:
!  12  Audio data in *.wav file
!  13  ALL_MEPT.TXT
!  14  decoded.txt
!  16  pixmap.dat
!  17  audio_caps
!  18  test.snr

  character message*24,cdbm*4
  real*8 tsec
  include 'acom1.f90'
  character linetx*51
  common/acom2/ntune2,linetx
  common/patience/npatience
  data receiving/.false./,transmitting/.false./
  data decoding/.false./,ns1200/-999/

  call cs_init
  call cs_lock('wspr2')
#ifdef CVF
  open(14,file='decoded.txt',status='unknown',share='denynone')
#else
  open(14,file='decoded.txt',status='unknown')
#endif
  write(14,1002)
1002 format('$EOF')
  call flush(14)
  rewind 14
  call cs_unlock

  npatience=1
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
     thisfile=outfile
     if(ncal.eq.1) ncal=2
     call startdec
  endif

  if(ntxdone.gt.0) then
     transmitting=.false.
     ntxdone=0
  endif

  if(ns120.ge.114 .and. ntune.eq.0) then
     transmitting=.false.
     receiving=.false.
     ntr=0
  endif

  if(pctx.lt.1.0) ntune=0
  if (ntune.eq.1 .and. ndevsok.eq.1.and. (.not.transmitting) .and.   &
       (.not.receiving) .and. pctx.ge.1.0) then
! Test transmission of length pctx seconds.
     nsectx=mod(nsec,86400)
     ntune2=ntune
     transmitting=.true.
     call starttx
  endif

  if (ncal.eq.1 .and. ndevsok.eq.1.and. (.not.transmitting) .and.   &
       (.not.receiving)) then
! Execute one receive sequence
     receiving=.true.
     rxtime=utctime(1:4)
     call startrx
  endif

  if(ns120.eq.0 .and. (.not.transmitting) .and. (.not.receiving) .and. &
       (idle.eq.0)) go to 30

  call chklevel
  call msleep(200)
  go to 20

30 outfile=cdate(3:8)//'_'//utctime(1:4)//'.'//'wav'
  if(pctx.eq.0.0) nrx=1
  if(nrx.eq.0) then
     transmitting=.true.
     call random_number(x)
     nrx=nint(rxavg + rr*(x-0.5))
     call cs_lock('wspr2')
     write(cdbm,'(i4)') ndbm
     message=callsign//grid//cdbm
     call msgtrim(message,msglen)
     write(linetx,1030) cdate(3:8),utctime(1:4),ftx
1030 format(a6,1x,a4,14x,f11.6,2x,'Transmitting ')
     call cs_unlock
     ntr=-1
     nsectx=mod(nsec,86400)
     if(ndevsok.eq.1) call starttx

  else
     receiving=.true.
     rxtime=utctime(1:4)
     ntr=1
     if(ndevsok.eq.1) call startrx
     nrx=nrx-1
  endif
  go to 20

  return
end subroutine wspr2
