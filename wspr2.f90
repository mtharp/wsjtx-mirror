subroutine wspr2

! Logical units:
!  12  Audio data in *.wav file
!  13  ALL_WSPR.TXT
!  14  decoded.txt
!  16  pixmap.dat
!  17  audio_caps
!  18  test.snr

  character message*24,cdbm*4
  real*8 tsec
  include 'acom1.f90'
  character linetx*51,dectxt*80
  integer nt(9)
  common/acom2/ntune2,linetx
  common/patience/npatience
  data receiving/.false./,transmitting/.false./
  data ns1200/-999/,nrxnormal/0/

  call cs_init
  dectxt=appdir(:nappdir)//'/decoded.txt'

  call cs_lock('wspr2')
  open(14,file=dectxt,status='unknown')
  write(14,1002)
1002 format('$EOF')
  call flush(14)
  rewind 14
  call cs_unlock

  npatience=1
  call random_seed
  nrx=1

20 call cs_lock('wspr2')
  call getutc(cdate,utctime,tsec)
  nsec=tsec
  ns120=mod(nsec,120)
  rxavg=1.0
  if(pctx.gt.0.0) rxavg=100.0/pctx - 1.0
  call cs_unlock

  if(nrxdone.gt.0) then

     call cs_lock('wspr2')
     receiving=.false.
     nrxdone=0
     ndecoding=1
     thisfile=outfile
     call cs_unlock

     if((nrxnormal.eq.1 .and. ncal.eq.0) .or.                          &
        (nrxnormal.eq.0 .and. ncal.eq.2) .or.                          &
        ndiskdat.eq.1) then
        call startdec
     endif
  endif

  call cs_lock('wspr2')
  if(ntxdone.gt.0) then
     transmitting=.false.
     ntxdone=0
     ntr=0
  endif
  if(ns120.ge.114 .and. ntune.eq.0) then
     transmitting=.false.
     receiving=.false.
     ntr=0
  endif
  if(pctx.lt.1.0) ntune=0
  call cs_unlock

  if (ntune.eq.1 .and. ndevsok.eq.1.and. (.not.transmitting) .and.   &
       (.not.receiving) .and. pctx.ge.1.0) then

! Test transmission of length pctx seconds.
     call cs_lock('wspr2')
     nsectx=mod(nsec,86400)
     ntune2=ntune
     transmitting=.true.
     call cs_unlock

     call starttx
  endif

  if (ncal.eq.1 .and. ndevsok.eq.1.and. (.not.transmitting) .and.   &
       (.not.receiving)) then

! Execute one receive sequence
     call cs_lock('wspr2')
     receiving=.true.
     rxtime=utctime(1:4)
     nrxnormal=0
     call cs_unlock

     call startrx
  endif

  if(ns120.eq.0 .and. (.not.transmitting) .and. (.not.receiving) .and. &
       (idle.eq.0)) go to 30
  call chklevel(kwave,iqmode+1,NZ/2,nsec1,xdb1,xdb2)
  call msleep(200)
  go to 20

30 outfile=cdate(3:8)//'_'//utctime(1:4)//'.'//'wav'
  if(pctx.eq.0.0) nrx=1

  if(nrx.eq.0 .and. ntr.ne.-1) then

     call cs_lock('wspr2')
     transmitting=.true.
     call random_number(x)
     if(pctx.lt.50.0) then
        nrx=nint(rxavg + 3.0*(x-0.5))
     else
        nrx=0
        if(x.lt.rxavg) nrx=1
     endif
     write(cdbm,'(i4)') ndbm
     message=callsign//grid//cdbm
     call msgtrim(message,msglen)
     write(linetx,1030) cdate(3:8),utctime(1:4),ftx
1030 format(a6,1x,a4,14x,f11.6,2x,'Transmitting ')
     ntr=-1
     nsectx=mod(nsec,86400)
     ntxdone=0
     call cs_unlock

     call gmtime2(nt,tsec0)
     if(ndevsok.eq.1) call starttx

  else
     receiving=.true.
     rxtime=utctime(1:4)
     ntr=1
     if(ndevsok.eq.1) then
        nrxnormal=1
        call startrx
     endif
     nrx=nrx-1
  endif
  go to 20

  return
end subroutine wspr2
