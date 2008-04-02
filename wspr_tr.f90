program wspr_tr

#ifdef CVF
  use dfport
#else
  integer unlink
#endif

! Logical units:
!  10  wspr_tr.in
!  11  
!  12
!  13  ALL_MEPT.TXT
!  14  decoded.txt

  character cjunk*1
  character*74 line
  character*17 message
  real*8 tsec
  logical idle,receiving,transmitting,decoding
  integer istat(13)
  integer soundinit,soundexit
  include 'acom1.f90'
  data nsec0/9999999/,itr/0/
  data idle/.false./,receiving/.false./,transmitting/.false./,decoding/.false./

  nargs=iargc()
  if(nargs.gt.0) then
     print*,'Usage: wspr_tr <args> ...'
     go to 999
  endif

  ierr=unlink('abort')
  open(13,file='ALL_MEPT.TXT',status='unknown',access='append')
  open(14,file='decoded.txt',status='unknown')
  end file 14
  rewind 14

  is10=-9999999
  ierr=soundinit()
  call random_seed

20 ierr=stat('abort',istat)
  if(ierr.eq.0) go to 999
  ierr=stat('wspr_tr.in',istat)
  if(istat(10).gt.is10) then
     open(10,file='wspr_tr.in',status='old')
     read(10,*) cjunk
     read(10,*) f0,ftx,nport,callsign,grid,ndbm,pctx,idsec,ndevin,ndevout,nsave
     read(10,*) infile
     close(10)
     nrx=1
     if(pctx.gt.50.0) nrx=0
     rxavg=1.0
     if(pctx.gt.0.0) rxavg=100.0/pctx - 1.0
     rr=3.0
     if(pctx.ge.40.0) rr=1.5                    !soft step?
     ierr=stat('wspr_tr.in',istat)
     is10=istat(10)
!     write(*,3007)  f0,ftx,nport,callsign,grid,ndbm,pctx,idsec,ndevin,  &
!          ndevout,nsave
!3007 format(2f11.6,i3,1x,a6,1x,a4,i4,f6.1,4i3)
     idle=.false.
     if(pctx.lt.0.0) then
        idle=.true.
        call msleep(100)
        go to 20
     endif
  endif

  call getutc(cdate,utctime,ihr,imin,sec,tsec)
  nsec=tsec
  if(nsec.lt.nsec0) then
     write(*,1028) f0+1400.d-6,f0+1600.d-6
     write(13,1028) f0+1400.d-6,f0+1600.d-6
1028 format(/' Search range:',f11.6,' to',f11.6,' MHz'//                &
             ' Date   UTC Sync dB    DT     Freq    Message'/           &
             '------------------------------------------------------')
  endif

  nsec0=nsec
  if(ndevin.lt.0) go to 30                       !Reading data from a file?
  ns120=mod(nsec,120)
!  if(mod(nsec,10).eq.0) write(*,3001) ns120,nrx,nrxdone,ndecdone,ntxdone,  &
!       receiving,decoding,transmitting
!3001 format(5i3,3l3)
  if(ns120.eq.0 .and. (.not.transmitting) .and. (.not.receiving)) go to 30

  if(nrxdone.gt.0) then
     receiving=.false.
     nrxdone=0
     decoding=.true.
     call startdec
  endif

  if(ndecdone.gt.0) then
     rewind 14
     do i=1,99
        read(14,1022,end=24) line
1022    format(a74)
        if(line(1:4).eq.'$EOF') go to 24
        write(*,1022) line
     enddo
24   ndecdone=0
     rewind 14
     line='$EOF'
     write(14,1022) line
     rewind 14
     decoding=.false.
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
     write(*,1030) cdate(3:8),utctime(1:4),ftx,message
     write(13,1030) cdate(3:8),utctime(1:4),ftx,message
1030 format(a6,1x,a4,14x,f11.6,2x,'Transmitting ',a17)
     call starttx
  else
     receiving=.true.
     call startrx
     nrx=nrx-1
  endif
  go to 20

999 ierr=soundexit()
  ierr=unlink('abort')
end program wspr_tr
