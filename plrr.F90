program plrr

!  Pseudo-Linrad "Receive" program

  integer*1 userx_no,iusb
  integer*2 nblock,nblock0
  integer*2 id(2,348)
  real*8 center_freq
  logical first
  common/plrscom/center_freq,msec,fselect,iptr,nblock,userx_no,iusb,buf4(348)
  equivalence (id,buf4)
  data first/.true./

  call setup_rsocket(0)
  ns0=-99
  nlost=0
  k=0

10 call recv_pkt(center_freq)

  lost=nblock-nblock0-1
  if(lost.ne.0 .and. .not.first) then
     nb=nblock
     if(nb.lt.0) nb=nb+65536
     nb0=nblock0
     if(nb0.lt.0) nb0=nb0+65536
     print*,'Lost packets:',nb,nb0,lost
     first=.false.
     nlost=nlost+lost
  endif
  nblock0=nblock
  ns=mod(msec/1000,60)
  if(ns.ne.ns0) then
     sumi=0.
     sumq=0.
     sqi=0.
     sqq=0.
     do i=1,348
        xi=id(1,i)
        xq=id(2,i)
        sumi=sumi + xi
        sumq=sumq + xq
        sqi=sqi + xi*xi
        sqq=sqq + xq*xq
        k=k+1
        write(52,4001) k,id(1,i),id(2,i)
4001    format(3i10)
     enddo
     avei=sumi/348.
     aveq=sumq/348.
     rmsi=sqrt(sqi/348.)
     rmsq=sqrt(sqq/348.)
     write(*,1010) ns,center_freq,0.001*msec,sec_midn(),nlost,  &
          avei,aveq,rmsi,rmsq
1010 format(i3,f10.3,f10.3,f10.3,i5,4f8.1)
     ns0=ns
  endif

  go to 10

end program plrr

! To compile: % gfortran -o plrr plrr.f90 sec_midn.F90 plrr_subs.c
