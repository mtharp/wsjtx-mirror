subroutine tx

!  Make one transmission of a WSPR message, or an unmodulated "Tune" sequence.

  integer system

  parameter (NMAX2=2*120*48000)
  parameter (NMAX3=4.5*48000)
  character message*22,message0*22,call1*12,cdbm*3
  character*22 msg0,msg1,cwmsg
  character crig*6,cbaud*6,cdata*1,cstop*1,chs*8
  character cmnd*120,snrfile*80
  integer*2 jwave,icwid,id2
  integer soundout,ptt,nt(9)
  real*8 tsec1,tsec2
  include 'acom1.f90'
  common/bcom/ntransmitted
  common/dcom/jwave(NMAX2),icwid(NMAX3),id2(NMAX2)
  data ntx/0/,ns0/0/
  data message0/'dummy'/,ntxdf0/-999/,ntune0/-999/,snr0/-999.0/
  data iqmode0/-999/,iqtx0/-999/
  save ntx,ns0,message0,ntxdf0,ntune0,snr0,iqmode0,iqtx0

  ierr=0
  call1=callsign
  call cs_lock('tx')
  if(pttmode.eq.'CAT') then
     if(nrig.eq.901) then
        cmnd='CMDSR -T 1'
     else
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
     endif

     iret=system(cmnd)
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
  if(iqmode.ne.0) then
     ntxdf=ntxdf + nfiq
  endif
  ctxmsg=message
  snr=99.0
  snrfile=appdir(:nappdir)//'/test.snr'

  call cs_lock('tx')
  open(18,file=snrfile,status='old',err=10)
  read(18,*,err=10,end=10) snr
10 close(18)
  call cs_unlock
  call gmtime2(nt,tsec1)

  newgen=0
  if(message.ne.message0 .or. ntxdf.ne.ntxdf0 .or.                    &
       ntune.ne.ntune0 .or. snr.ne.snr0 .or. iqmode.ne.iqmode0 .or.   &
       iqtx.ne.iqtx0) then
     message0=message
     ntxdf0=ntxdf
     ntune0=ntune
     snr0=snr
     iqmode0=iqmode
     iqtx0=iqtx
     call genwspr(message,ntxdf,ntune,snr,iqmode,iqtx,   &
       appdir,nappdir,sending,jwave)
     newgen=1
  endif

  npts=114*48000
  if(nsec.lt.ns0) ns0=nsec

  if(idint.ne.0 .and. (nsec-ns0)/60.ge.idint .and. iqmode.eq.0) then
!  Generate and insert the CW ID.
     wpm=25.
     freqcw=1500.0 + ntxdf
     cwmsg=call1(:i1)//'                      '
     icwid=0
     call gencwid(cwmsg,wpm,freqcw,icwid,ncwid)
     k0=112*48000
     k1=k0+12000
     k2=k1+4.5*48000
     jwave(k0:k1)=0
     jwave(k1+1:k2)=icwid
     jwave(k2:)=0
     npts=k2
     ns0=nsec
  endif

  fac=10.0**(0.05*ntxdb)
  if(ntune.eq.0) then
20   call gmtime2(nt,tsec2)
     tdiff=tsec2-tsec0
     if(tdiff.lt.0.9) then
        call msleep(100)
        go to 20
     endif

     if(newgen.eq.1) then
        istart=48000*(tsec2-tsec0)
        istart=istart*(iqmode+1)+1           !istart must be odd if iqmode=1
        if(istart.lt.1) istart=1
        npts=npts-istart
        j=istart-1
        do i=1,npts*(iqmode+1)
           j=j+1
           id2(i)=fac*jwave(j)
        enddo
     endif

     if(iqmode.eq.1) then
        call phasetx(id2,npts,fac,txbal,txpha)
     endif

     ierr=soundout(ndevout,id2,npts,iqmode)

  else
     istart=2*48000 +1
     if(pctx.lt.100.0) then
        npts=48000*pctx
        j=istart-1
        do i=1,npts*(iqmode+1)
           j=j+1
           id2(i)=fac*jwave(j)
        enddo
        ierr=soundout(ndevout,id2,npts,iqmode)
     else
        npts=24*4096
        do irpt=1,100
           fac=10.0**(0.05*ntxdb)
           j=istart-1
           do i=1,npts*(iqmode+1)
              j=j+1
              id2(i)=fac*jwave(j)
           enddo
           if(iqmode.eq.1) call phasetx(id2,npts,fac,txbal,txpha)
           ierr=soundout(ndevout,id2,npts,iqmode)
        enddo
     endif
     ntune=0
  endif
  if(ierr.ne.0) then
     print*,'Error in soundout',ierr
     stop
  endif

  if(pttmode.eq.'CAT') then
     if(nrig.eq.901) then
        cmnd='CMDSR -T 0'
     else
        cmnd='rigctl '//'-m'//crig//' -r'//catport//' -s'//cbaud//           &
             ' -C data_bits='//cdata//' -C stop_bits='//cstop//              &
             ' -C serial_handshake='//chs//' T 0'
     endif
     call cs_lock('tx')
     iret=system(cmnd)
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
