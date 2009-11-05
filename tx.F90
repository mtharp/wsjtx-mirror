subroutine tx

!  Make one transmission in the MEPT_JT mode.

#ifdef CVF
  use dfport
  use dflib
#else
  integer system
#endif

  parameter (NMAX2=120*48000)
  parameter (NMAX3=5*48000)
  character message*22,call1*12,cdbm*3
  character*22 msg0,msg1,msg2,cwmsg
  character crig*6,cbaud*6,cdata*1,cstop*1,chs*8
  character cmnd*120,snrfile*80
  integer*2 jwave,icwid
  integer soundout,ptt
  include 'acom1.f90'
  common/bcom/ntransmitted
  common/dcom/jwave(NMAX2),icwid(NMAX3)
  data ntx/0/,ns0/0/
  save ntx,ns0

  ierr=0
  call1=callsign
  call cs_lock('tx')
  if(pttmode.eq.'CAT') then
     write(crig,'(i6)') nrig
     write(cbaud,'(i6)') nbaud
     write(cdata,'(i1)') ndatabits
     write(cstop,'(i1)') nstopbits
     chs='None'
     if(nhandshake.eq.1) chs='XONXOFF'
     if(nhandshake.eq.2) chs='Hardware'
     cmnd='rigctl '//'-m'//crig//' -r'//catport//' -s'//cbaud//           &
          ' -C data_bits='//cdata//' -C stop_bits='//cstop//              &
          ' -C serial_handshake='//chs//' T 1'

! Example rigctl command:
! rigctl -m 1608 -r /dev/ttyUSB0 -s 57600 -C data_bits=8 -C stop_bits=1 \
!   -C serial_handshake=Hardware T 1
#ifdef CVF
     iret=runqq('rigctl.exe',cmnd(8:))
#else
     iret=system(cmnd)
#endif
     if(iret.ne.0) then
        print*,'Error executing rigctl command to set Tx mode:'
        print*,cmnd
     endif
  else
     if(nport.gt.0 .or. pttport(1:4).eq.'/dev') ierr=ptt(nport,pttport,1,iptt)
  endif

  write(cdbm,'(i3)'),ndbm
  call cs_unlock
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
  
  snrfile=appdir(:nappdir)//'/test.snr'
  open(18,file=snrfile,status='old',err=10)
  read(18,*,err=10,end=10) snr
  close(18)

10 call genwspr(message,ntxdf,snr,appdir,nappdir,msg2,jwave)
  npts=114*48000
  if(nsec.lt.ns0) ns0=nsec
  if(idint.ne.0 .and. (nsec-ns0)/60.ge.idint) then
!  Generate and insert the CW ID.
     wpm=25.
     freqcw=1500.0 + ntxdf
     cwmsg=call1(:i1)//'                      '
     icwid=0
     call gencwid(cwmsg,wpm,freqcw,icwid,ncwid)
     k0=113*48000
     k1=k0+24000
     k2=k1+5*48000
     jwave(k0:k1)=0
     jwave(k1+1:k2)=icwid
     jwave(k2:)=0
!     print*,'C',k0/48000.,k1/48000.,k2/48000.
     npts=k2
     ns0=nsec
  endif

  sending=msg2
  if(ntune.eq.0) then
     ierr=soundout(ndevout,jwave(48000),npts)
  else
     npts=48000*pctx
     ierr=soundout(ndevout,jwave(2*48000),npts)
     ntune=0
  endif
  if(ierr.ne.0) then
     print*,'Error in soundout',ierr
     stop
  endif

  if(pttmode.eq.'CAT') then
     cmnd='rigctl '//'-m'//crig//' -r'//catport//' -s'//cbaud//           &
          ' -C data_bits='//cdata//' -C stop_bits='//cstop//              &
          ' -C serial_handshake='//chs//' T 0'
     call cs_lock('tx')
#ifdef CVF
     iret=runqq('rigctl.exe',cmnd(8:))
#else
     iret=system(cmnd)
#endif
     if(iret.ne.0) then
        print*,'Error executing rigctl command to set Rx mode:'
        print*,cmnd
     endif
     call cs_unlock
  else
     if(nport.gt.0 .or. pttport(1:4).eq.'/dev') ierr=ptt(nport,pttport,0,iptt)
  endif

  ntransmitted=1
  ntxdone=1

  return
end subroutine tx
