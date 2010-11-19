subroutine recvpkt(iarg)

! Receive timf2 packets from Linrad and stuff data into array dd().
! (This routine runs in a background thread and will never return.)

  parameter (NSZ=2*60*96000)
  integer*1 userx_no,iusb
  integer*2 nblock,nblock0
  logical synced
  real*8 center_freq,d8,buf8(174)
  common/plrscom/center_freq,msec,fqso,iptr,nblock,userx_no,iusb,buf4(348)
  include 'datcom.f90'
  include 'gcom1.f90'
  include 'gcom2.f90'
  integer*2 id(2,NSMAX,2),jd(2)
  real*4 xd(2)
  equivalence (jd,d4)
  equivalence (xd,d8)
  equivalence (buf4,buf8)
  data nblock0/0/,kb/1/,ns00/99/
  data sqave/0.0/,u/0.002/,rxnoise/0.0/,pctblank/0.0/,kbuf/1/,lost_tot/0/
  data multicast0/-99/
  save

1 continue
  call cs_lock('recvpkt')
  call setup_rsocket(multicast)     !Open socket for multicast/unicast data
  call cs_unlock
  k=0
  kk=0
  kxp=0
  kb=1
  nsec0=-999
  fcenter=144.130d0                 !Default (startup) frequency)
  multicast0=multicast
  ntx=0
  synced=.false.

10 if(multicast.ne.multicast0) go to 1
  call recv_pkt(center_freq)
  if(userx_no.gt.0) then
     ifloat=0
     iz=348
  else
     ifloat=1
     iz=174
  endif

! Should receive a new packet every 348/95238.1 = 0.003654 s (i*2 data)
!                        ...  every 174/95238.1 = 0.001827 s (r*4 data)

  nsec=mod(Tsec,86400.d0)           !Time according to MAP65
  nseclr=msec/1000                  !Time according to Linrad
  if(lauto+monitoring.ne.0) fcenter=center_freq

! Reset buffer pointers at start of minute.
  ns=mod(nsec,60)
  
!  if(ns.ne.ns00) print*,ns00,ns,kb,k,synced
  if(ns.lt.ns00 .and. (lauto+monitoring.ne.0)) then
     if(ntx.eq.0) kb=3-kb
     k=(kb-1)*60*96000
     kxp=k
     ndone1=0
     ndone2=0
     lost_tot=0
     synced=.true.
     ntx=0
     nblock0=nblock-1
!     print*,'new minute:',ns00,ns,kb,k,synced
  endif
  ns00=ns

  if(transmitting.eq.1) ntx=1

! Test for buffer full
  if((kb.eq.1 .and. (k+iz).gt.NSMAX) .or.                          &
       (kb.eq.2 .and. (k+iz).gt.2*NSMAX)) go to 20

! Check for lost packets
  lost=nblock-nblock0-1
  if(lost.ne.0) then
     nb=nblock
     if(nb.lt.0) nb=nb+65536
     nb0=nblock0
     if(nb0.lt.0) nb0=nb0+65536
     lost_tot=lost_tot + lost               ! Insert zeros for the lost data.
!###
!     do i=1,iz*lost
!        k=k+1
!        d4(k)=0.
!     enddo
!###
  endif
  nblock0=nblock

  tdiff=mod(0.001d0*msec,60.d0)-mod(Tsec,60.d0)
  if(tdiff.lt.-30.) tdiff=tdiff+60.
  if(tdiff.gt.30.) tdiff=tdiff-60.

! Move data into Rx buffer and compute average signal level.
! Each r*4 word of buf4 and d4 is one sample, I and Q
  sq=0.
  do i=1,iz
     k=k+1
     k2=k
     n=1
     if(k.gt.NSMAX) then
        k2=k2-NSMAX
        n=2
     endif
     if(ifloat.eq.0) then
        d4=buf4(i)
        x1=jd(1)
        x2=jd(2)
        dd(1,k2,n)=x1
        dd(2,k2,n)=x2
        sq=sq + x1*x1 + x2*x2
     else
        d8=buf8(i)
        x1=xd(1)
        x2=xd(2)
        dd(1,k2,n)=x1
        dd(2,k2,n)=x2
        sq=sq + x1*x1 + x2*x2
     endif
  enddo

  sq=sq/(2.0*iz)
  sqave=sqave + u*(sq-sqave)
  rxnoise=10.0*log10(sqave) - 20.0           !Target rms=10, sqave=100
  kxp=k

20 if(nsec.ne.nsec0) then
     nsec0=nsec
     mutch=nseclr/3600
     mutcm=mod(nseclr/60,60)
     mutc=100*mutch + mutcm

!### Temporary!
!     write(*,4100) center_freq,fadd,nfcal,mutc
!4100 format(2f12.6,2i10)
!###

! If we have not transmitted in this minute, see if it's time to start FFTs
     if(ntx.eq.0 .and. lauto+monitoring.ne.0) then
        if(ns.ge.nt1 .and. ndone1.eq.0 .and. synced) then
           nutc=mutc
           if(lauto+monitoring.ne.0) fcenter=center_freq
           kbuf=kb
           kk=k
           ndiskdat=0
           ndone1=1
        endif

! See if it's time to start the full decoding procedure.
        nhsym=(k-(kbuf-1)*60*96000)/17691.3949
        if(ndone1.eq.1 .and. nhsym.ge.279 .and.ndone2.eq.0) then
           kk=k
           nlost=lost_tot                         ! Save stats for printout
           ndone2=1
        endif
     endif

  endif
  go to 10

end subroutine recvpkt
