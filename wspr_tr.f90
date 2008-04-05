program wspr_tr

#ifdef CVF
  use dfport
#else
  integer unlink
#endif

! Logical units:
!  10  wspr_tr.in
!  11  Transmitting/Receiving and UTC
!  12
!  13  ALL_MEPT.TXT
!  14  decoded.txt

  character cjunk*1
  character*74 line
  character*17 message
  character*12 arg
  real*8 tsec
  logical idle,receiving,transmitting,decoding,gui,cmnd
  integer istat(13)
  integer soundinit,soundexit
  integer*1 hdr(44)
  include 'acom1.f90'
  data nsec0/9999999/,itr/0/
  data idle/.false./,receiving/.false./,transmitting/.false./
  data decoding/.false./,gui/.false./,cmnd/.false./

  nargs=iargc()
  if(nargs.ne.1 .and. nargs.ne.12) then
     print*,'Usage: wspr_tr f0 ftx port call grid dBm pctx dsec in out save "infile"'
     print*,'       wspr_tr --gui'
     go to 999
  endif 

  if(nargs.eq.1) gui=.true.
  if(nargs.eq.12) then
     call getparams(f0,ftx,nport,callsign,grid,ndbm,    &
                           pctx,idsec,ndevin,ndevout,nsave,infile)
     print*,infile
     cmnd=.true.
  endif

 ierr=unlink('abort')
!  open(11,file='txrxtime.txt',status='unknown',share='denynone')
  open(11,file='txrxtime.txt',status='unknown')
  write(11,1000) 
1000 format('Idle')
!  open(13,file='ALL_MEPT.TXT',status='unknown',position='append',share='denynone')
  open(13,file='ALL_MEPT.TXT',status='unknown',position='append')
!  open(14,file='decoded.txt',status='unknown',share='denynone')
  open(14,file='decoded.txt',status='unknown')
  write(14,1002)
1002 format('$EOF')
  rewind 14

  is10=-9999999
  ierr=soundinit()
  call random_seed
  nrx=1

20 ierr=stat('abort',istat)
  if(ierr.eq.0) go to 999
  if(.not.cmnd) then
     ierr=stat('wspr_tr.in',istat)
     if(istat(10).gt.is10) then
!        open(10,file='wspr_tr.in',status='old',share='denynone')
        open(10,file='wspr_tr.in',status='old')
        read(10,*) cjunk
        read(10,*) f0,ftx,nport,callsign,grid,ndbm,pctx,idsec,          &
             ndevin,ndevout,nsave
        read(10,*) infile
        close(10)
        if(pctx.gt.50.0) nrx=0
        ierr=stat('wspr_tr.in',istat)
        is10=istat(10)
     endif
  endif
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
  if(nsec.lt.nsec0 .and. (.not.gui)) then
     write(*,1028) 
     write(13,1028)
1028 format(/' Date   UTC Sync dB    DT     Freq    Message'/           &
             '------------------------------------------------------')
  endif
  nsec0=nsec

!  Reading data from a file?
  if(infile(1:4).ne.'none' .and. (.not.transmitting) .and. & 
       (.not.receiving)) then
#ifdef CVF
     open(12,file=infile,form='binary',status='old')
#else
     open(12,file=infile,access='stream',status='old')
#endif
     npts=114*12000
     read(12) hdr
     read(12) (iwave(i),i=1,npts)
     close(12)
     call getrms(iwave,npts,ave,rms)
     rewind 11
     write(11,1029) 
1029 format('Idle')
     outfile=infile
     call decode
     infile='none'
     idle=.true.
     go to 20
  endif

  ns120=mod(nsec,120)
  if(ns120.eq.0 .and. (.not.transmitting) .and. (.not.receiving)) go to 30

  if(nrxdone.gt.0) then
     receiving=.false.
     nrxdone=0
     decoding=.true.
     call startdec
  endif

  if(ndecdone.gt.0) then
     if(.not.gui) then
        rewind 14
        do i=1,99
           read(14,1022,end=24) line
1022       format(a74)
           if(line(1:4).eq.'$EOF') go to 24
           write(*,1022) line
        enddo
24        rewind 14
        line='$EOF'
        write(14,1022) line
        rewind 14
     endif
     ndecdone=0
     decoding=.false.
     if(cmnd) go to 999
  endif

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
     if(.not.gui) write(*,1030) cdate(3:8),utctime(1:4),ftx,message
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

999 ierr=soundexit()
  ierr=unlink('abort')
end program wspr_tr
