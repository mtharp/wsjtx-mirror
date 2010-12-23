subroutine wspr2

! Logical units:
!  12  Audio data in *.wav file
!  13  ALL_WSPR.TXT
!  14  decoded.txt
!  16  pixmap.dat
!  17  audio_caps
!  18  test.snr
!  19  wspr.log

  character message*24,cdbm*4
  real*8 tsec,tsec1
  include 'acom1.f90'
  character linetx*40,dectxt*80,logfile*80
  integer nt(9)
  integer iclock(12)
  integer ib(14)
  common/acom2/ntune2,linetx
  common/patience/npatience
  data receiving/.false./,transmitting/.false./
  data nrxnormal/0/,ireset/1/
  data ib/500,160,80,60,40,30,20,17,15,12,10,6,4,2/
  save ireset

  call cs_init
  dectxt=appdir(:nappdir)//'/decoded.txt'

  call cs_lock('wspr2')
  open(14,file=dectxt,status='unknown')
  write(14,1002)
1002 format('$EOF')
  call flush(14)
  rewind 14
  logfile=appdir(:nappdir)//'/wspr.log'
  open(19,file=logfile,status='unknown',position='append')
  call cs_unlock

  npatience=1
  call system_clock(iclock(1))
  call random_seed(PUT=iclock)
  nrx=1
  nfhopping=0 ! hopping scheduling disabled
  nfhopok=0   ! not a good time to hop

10 call cs_lock('wspr2')
  call getutc(cdate,utctime,tsec)
  nsec=tsec
  ns120=mod(nsec,120)
  rxavg=1.0
  if(pctx.gt.0.0) rxavg=100.0/pctx - 1.0
  call cs_unlock
!  if(transmitting .and. nstoptx.eq.1) then
!     call killtx
!     nstoptx=0
!     transmitting=.false.
!     go to 20
!  endif

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
        call cs_lock('wspr2')
        call gmtime2(nt,tsec1)
        t120=mod(tsec1,120.d0)
        write(19,1031) cdate(3:8),utctime(1:4),t120,'Dec ',iband,ib(iband)
1031    format(a6,1x,a4,f7.2,2x,a4,2i4,2x,a22)
        call flush(19)
        call cs_unlock
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

  if (ntune.ne.0 .and. ndevsok.eq.1.and. (.not.transmitting) .and.   &
       (.not.receiving) .and. pctx.ge.1.0) then

! Test transmission of length pctx seconds.
     call cs_lock('wspr2')
     nsectx=mod(nsec,86400)
     ntune2=ntune
     transmitting=.true.
     call gmtime2(nt,tsec1)
     t120=mod(tsec1,120.d0)
     write(19,1031) cdate(3:8),utctime(1:4),t120,'Test',iband,ib(iband)
     call flush(19)
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
     call gmtime2(nt,tsec1)
     t120=mod(tsec1,120.d0)
     write(19,1031) cdate(3:8),utctime(1:4),t120,'Cal ',iband,ib(iband)
     call flush(19)
     call cs_unlock
     call startrx
  endif

  if(ns120.eq.0 .and. (.not.transmitting) .and. (.not.receiving) .and. &
       (idle.eq.0)) go to 30
  if(receiving) then
     call chklevel(kwave,iqmode+1,NZ/2,nsec1,xdb1,xdb2,iwrite)
     if(iqmode.eq.1 .and. iqrxadj.eq.1) then
        call speciq(kwave,NZ/2,iwrite,iqrx,nfiq,ireset,gain,phase,reject)
     else
        ireset=1
     endif
  endif

20 call msleep(200)
  go to 10

30 outfile=cdate(3:8)//'_'//utctime(1:4)//'.'//'wav'

! Frequency hopping scheduling; overrides normal scheduling
  if (nfhopping.eq.1) then
     if (pctx.eq.0.0) then
        nrx=1
     else
        if(ncoord.eq.0) then
           call random_number(x)
           if (100*x .lt. pctx) then
              ntxnext=1
           else
              nrx=1
           endif
        else
           call rxtxcoord(nsec,pctx,nrx,ntxnext)
        endif
     endif
  else
     if(pctx.eq.0.0) nrx=1
  endif

  if(transmitting .or. receiving) go to 10

  if(pctx.gt.0.0 .and. (ntxnext.eq.1 .or. (nrx.eq.0 .and. ntr.ne.-1))) then

     call cs_lock('wspr2')
     ntune2=ntune
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
1030 format(a6,1x,a4,f11.6,2x,'Transmitting on ')
     ntr=-1
     nsectx=mod(nsec,86400)
     ntxdone=0
     ntxnext=0
     call cs_unlock

     if(ndevsok.eq.1) then
        call cs_lock('wspr2')
        call gmtime2(nt,tsec0)
        t120=mod(tsec0,120.d0)
        write(19,1031) cdate(3:8),utctime(1:4),t120,'Tx  ',iband,ib(iband),  &
             message
        call flush(19)
        call cs_unlock
        call starttx
     endif

  else
     receiving=.true.
     rxtime=utctime(1:4)
     ntr=1
     if(ndevsok.eq.1) then
        nrxnormal=1
        call cs_lock('wspr2')
        call gmtime2(nt,tsec1)
        t120=mod(tsec1,120.d0)
        write(19,1031) cdate(3:8),utctime(1:4),t120,'Rx  ',iband,ib(iband)
        call flush(19)
        call cs_unlock
        call startrx
     endif
     nrx=nrx-1
  endif
  go to 10

  return
end subroutine wspr2
