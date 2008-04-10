subroutine wspr2

#ifdef CVF
  use dfport
#endif

! Logical units:
!  10  wspr_tr.in
!  11  Transmitting/Receiving and UTC
!  12  Audio data in *.wav file
!  13  ALL_MEPT.TXT
!  14  decoded.txt

  character*17 message
  real*8 tsec
  logical idle,receiving,transmitting,decoding,gui,cmnd
  integer soundinit,soundexit
  integer*1 hdr(44)
  include 'acom1.f90'
  data idle/.true./,receiving/.false./,transmitting/.false./
  data decoding/.false./

#ifdef CVF
  open(11,file='txrxtime.txt',status='unknown',share='denynone')
  open(14,file='decoded.txt',status='unknown',share='denynone')
#else
  open(11,file='txrxtime.txt',status='unknown')
  open(14,file='decoded.txt',status='unknown')
#endif
  write(11,1000) 
1000 format('Idle')
  call flush(11)
  write(14,1002)
1002 format('$EOF')
  call flush(14)
  rewind 14

  ierr=soundinit()
  call random_seed
  nrx=1

20 continue

!  if(pctx.gt.50.0) nrx=0

  pctx=0.                                    !### temporary ###
  rxavg=1.0
  if(pctx.gt.0.0) rxavg=100.0/pctx - 1.0
  rr=3.0
  if(pctx.ge.40.0) rr=1.5                    !soft step?
  idle=.false.
  if(pctx.lt.0.0) then
     idle=.true.
     call msleep(100)
     go to 20
  endif

  if(idle .and. infile(1:4).eq.'none') then
     call msleep(100)
     go to 20
  endif

  call getutc(cdate,utctime,tsec)
  nsec=tsec

!  Reading data from a file?
!  if(infile(1:4).ne.'none' .and. (.not.transmitting) .and. & 
!       (.not.receiving)) then
!#ifdef CVF
!     open(12,file=infile,form='binary',status='old')
!#else
!     open(12,file=infile,access='stream',status='old')
!#endif
!     npts=114*12000
!     read(12) hdr
!     read(12) (iwave(i),i=1,npts)
!     close(12)
!     call getrms(iwave,npts,ave,rms)
!     rewind 11
!     write(11,1029) 
!1029 format('Idle')
!     outfile=infile
!     call decode
!     infile='none'
!     idle=.true.
!     go to 20
!  endif

  ns120=mod(nsec,120)
  if(ns120.eq.0 .and. (.not.transmitting) .and. (.not.receiving)) go to 30

  if(nrxdone.gt.0) then
     receiving=.false.
     nrxdone=0
     decoding=.true.
     call startdec
  endif

!  if(ndecdone.gt.0) then
!     ndecdone=0
!     decoding=.false.
!  endif

  if(ntxdone.gt.0) then
     transmitting=.false.
     ntxdone=0
  endif

  call msleep(1000)
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
!     if(.not.gui) write(*,1030) cdate(3:8),utctime(1:4),ftx,message
     write(13,1030) cdate(3:8),utctime(1:4),ftx,message
1030 format(a6,1x,a4,14x,f11.6,2x,'Transmitting ',a17)
     rewind 11
     write(11,1040) 'Transmitting',utctime(1:2)//':'//utctime(3:4)
1040 format(a12,1x,a5)
     call starttx
  else
     receiving=.true.
     rewind 11
     write(11,1040) 'Receiving   ',utctime(1:2)//':'//utctime(3:4)
     call startrx
     nrx=nrx-1
  endif
  go to 20

  return
end subroutine wspr2
