subroutine ft8b(dd0,newdat,nfqso,ndepth,lsubtract,iaptype,icand,sync0,f1,xdt,   &
     apsym,nharderrors,dmin,nbadcrc,iap,ipass,iera,message,xsnr)

  use timer_module, only: timer
  include 'ft8_params.f90'
  parameter(NRECENT=10,NP2=2812)
  character message*22,msgsent*22
  character*12 recent_calls(NRECENT)
  real a(5)
  real s1(0:7,ND),s2(0:7,NN)
  real ps(0:7)
  real rxdata(3*ND),llr(3*ND),llr0(3*ND),llrap(3*ND)           !Soft symbols
  real dd0(15*12000)
  integer*1 decoded(KK),apmask(3*ND),cw(3*ND)
  integer*1 msgbits(KK)
  integer apsym(KK),rr73(11),cq(28)
  integer itone(NN)
  complex cd0(3200)
  complex ctwk(32)
  complex csymb(32)
  logical newdat,lsubtract
  data rr73/-1,1,1,1,1,1,1,-1,1,1,-1/
  data cq/1,1,1,1,1,-1,1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,1,1,-1,-1,-1,1,1,-1,-1,1/
  max_iterations=30
  norder=2
  nharderrors=-1
  fs2=12000.0/NDOWN
  dt2=1.0/fs2
  twopi=8.0*atan(1.0)
  delfbest=0.
  ibest=0

  call timer('ft8_down',0)
  call ft8_downsample(dd0,newdat,f1,cd0)   !Mix f1 to baseband and downsample
  call timer('ft8_down',1)

  i0=nint(xdt*fs2)                         !Initial guess for start of signal
  smax=0.0
  do idt=i0-8,i0+8                       !Search over +/- one quarter symbol
     call sync8d(cd0,idt,ctwk,0,sync)
     if(sync.gt.smax) then
        smax=sync
        ibest=idt
     endif
  enddo
  xdt2=ibest*dt2                           !Improved estimate for DT

! Now peak up in frequency
  i0=nint(xdt2*fs2)
  smax=0.0
  do ifr=-5,5                              !Search over +/- 2.5 Hz
    delf=ifr*0.5
    dphi=twopi*delf*dt2
    phi=0.0
    do i=1,32
      ctwk(i)=cmplx(cos(phi),sin(phi))
      phi=mod(phi+dphi,twopi)
    enddo
   call sync8d(cd0,i0,ctwk,1,sync)
    if( sync .gt. smax ) then
      smax=sync
      delfbest=delf
    endif
  enddo
  a=0.0
  a(1)=-delfbest
  call twkfreq1(cd0,NP2,fs2,a,cd0)
  xdt=xdt2
  f1=f1+delfbest                           !Improved estimate of DF

  call sync8d(cd0,i0,ctwk,2,sync)

  j=0
  do k=1,NN
    i1=ibest+(k-1)*32
    csymb=cmplx(0.0,0.0)
    if( i1.ge.1 .and. i1+31 .le. NP2 ) csymb=cd0(i1:i1+31)
    call four2a(csymb,32,1,-1,1)
    s2(0:7,k)=abs(csymb(1:8))
  enddo  
  j=0
  do k=1,NN
    if(k.le.7) cycle
    if(k.ge.37 .and. k.le.43) cycle
    if(k.gt.72) cycle
    j=j+1
    s1(0:7,j)=s2(0:7,k)
  enddo  

  do j=1,ND
     ps=s1(0:7,j)
     where (ps.gt.0.0) ps=log(ps)
     r1=max(ps(1),ps(3),ps(5),ps(7))-max(ps(0),ps(2),ps(4),ps(6))
     r2=max(ps(2),ps(3),ps(6),ps(7))-max(ps(0),ps(1),ps(4),ps(5))
     r4=max(ps(4),ps(5),ps(6),ps(7))-max(ps(0),ps(1),ps(2),ps(3))
     rxdata(3*j-2)=r4
     rxdata(3*j-1)=r2
     rxdata(3*j)=r1
  enddo

  rxav=sum(rxdata)/(3.0*ND)
  rx2av=sum(rxdata*rxdata)/(3.0*ND)
  var=rx2av-rxav*rxav
  if( var .gt. 0.0 ) then
     rxsig=sqrt(var)
  else
     rxsig=sqrt(rx2av)
  endif
  rxdata=rxdata/rxsig
  ss=0.84
  llr=2.0*rxdata/(ss*ss)
  llr0=llr
  apmag=4.0
!  nera=1
!  nera=3
  nap=0
!  if(ndepth.eq.3) nap=2  

  do iap=0,nap                            !### Temporary ###
     nera=1
     if(iap.eq.0) nera=3
     do iera=1,nera
        llr=llr0
        nblank=0
        if(nera.eq.3 .and. iera.eq.1) nblank=48
        if(nera.eq.3 .and. iera.eq.2) nblank=24
        if(nera.eq.3 .and. iera.eq.3) nblank=0
        if(nblank.gt.0) llr(1:nblank)=0.
        if(iap.eq.0) then
           apmask=0
           apmask(160:162)=1
           llrap=llr
           llrap(160:162)=apmag*apsym(73:75)/ss
        endif
        if(iaptype.eq.1) then
           if(iap.eq.1) then   ! look for plain CQ
              apmask=0
              apmask(88:115)=1   ! plain CQ 
              apmask(144)=1      ! not free text
              apmask(160:162)=1  ! 3 extra bits
              llrap=llr
              llrap(88:115)=apmag*cq/ss
              llrap(144)=-apmag/ss
              llrap(160:162)=apmag*apsym(73:75)/ss
           endif
           if(iap.eq.2) then   ! look for mycall
              apmask=0
              apmask(88:115)=1   ! mycall
              apmask(144)=1      ! not free text
              apmask(160:162)=1  ! 3 extra bits
              llrap=llr
              llrap(88:115)=apmag*apsym(1:28)/ss
              llrap(144)=-apmag/ss
              llrap(160:162)=apmag*apsym(73:75)/ss
           endif
        endif
        if(iaptype.eq.2) then
           if(iap.eq.1) then   ! look for mycall, dxcall
              apmask=0
              apmask(88:115)=1   ! mycall
              apmask(116:143)=1  ! hiscall
              apmask(144)=1      ! not free text
              apmask(160:162)=1  ! 3 extra bits
              llrap=llr
              llrap(88:143)=apmag*apsym(1:56)/ss
              llrap(144)=-apmag/ss
              llrap(160:162)=apmag*apsym(73:75)/ss
           endif
           if(iap.eq.2) then   ! look mycall, dxcall, RRR/73
              apmask=0
              apmask(88:115)=1   ! mycall
              apmask(116:143)=1  ! hiscall
              apmask(144:154)=1  ! RRR or 73 
              apmask(160:162)=1  ! 3 extra bits
              llrap=llr
              llrap(88:143)=apmag*apsym(1:56)/ss
              llrap(144:154)=apmag*rr73/ss
              llrap(160:162)=apmag*apsym(73:75)/ss
           endif
        endif

        cw=0
        call timer('bpd174  ',0)
        call bpdecode174(llrap,apmask,max_iterations,decoded,cw,nharderrors,  &
             niterations)
        call timer('bpd174  ',1)
        dmin=0.0
        if(ndepth.eq.3 .and. nharderrors.lt.0) then
           if(iaptype.eq.1) norder=2
           if(iaptype.eq.2 .and. abs(nfqso-f1).lt.10.0) then
             norder=3
           else
             norder=1
           endif
           call timer('osd174  ',0)
           call osd174(llrap,apmask,norder,decoded,cw,nharderrors,dmin)
           call timer('osd174  ',1)
        endif
        nbadcrc=1
        message='                      '
        xsnr=-99.0
        if(count(cw.eq.0).eq.174) cycle           !Reject the all-zero codeword
!    if( nharderrors.ge.0 .and. dmin.le.30.0 .and. nharderrors .lt. 30) then
!***  These thresholds should probably be dependent on nap
        if( nharderrors.ge.0 .and. dmin.le.50.0 .and. nharderrors .lt. 50) then
           call chkcrc12a(decoded,nbadcrc)
        else
           nharderrors=-1
           cycle 
        endif
        if(nbadcrc.eq.0) then
           call extractmessage174(decoded,message,ncrcflag,recent_calls,nrecent)
           call genft8(message,msgsent,msgbits,itone)
           if(lsubtract) call subtractft8(dd0,itone,f1,xdt2)
           xsig=0.0
           xnoi=0.0
           do i=1,79
              xsig=xsig+s2(itone(i),i)**2
              ios=mod(itone(i)+4,7)
              xnoi=xnoi+s2(ios,i)**2
           enddo
           xsnr=0.001
           if(xnoi.gt.0 .and. xnoi.lt.xsig) xsnr=xsig/xnoi-1.0
           xsnr=10.0*log10(xsnr)-27.0
           if(xsnr .lt. -24.0) xsnr=-24.0
           return
        endif
     enddo
  enddo
 
  return
end subroutine ft8b
