program simjt4

  parameter (NMAX=100)
  real*4 sym(0:1,206)
  real*8 sum0,sum1,sumcycles
  character arg*12,c72*72
  character*22 msg,decoded
  integer icode(206)
  integer imsg(72)
  logical iknown(72)
  integer*1 data1(13)                   !Decoded data (8-bit bytes)
  integer   data4a(9)                   !Decoded data (8-bit bytes)
  integer   data4(12)                   !Decoded data (6-bit bytes)
  common/pspncom/ps(0:NMAX),pn(0:NMAX),scale
  common/jt4com1/imsg6(12)

  nargs=iargc()
  if(nargs.ne.8) then
     print*,'Usage: simjt4 nadd scale ndelta limit known snr amp iters'
     print*,'               1    10.0   30   10000   0    0   3   100'
     go to 999
  endif

  call getarg(1,arg)
  read(arg,*) nadd
  call getarg(2,arg)
  read(arg,*) scale
  call getarg(3,arg)
  read(arg,*) ndelta
  call getarg(4,arg)
  read(arg,*) limit
  call getarg(5,arg)
  read(arg,*) known
  call getarg(6,arg)
  read(arg,*) snrdb
  call getarg(7,arg)
  read(arg,*) amp
  call getarg(8,arg)
  read(arg,*) iters

  iknown=.false.
  xi=1.0
  do i=1,known
     iknown(int(xi))=.true.
     xi=xi + 72.0/known
  enddo     

  do i=0,NMAX
     read(13,*) x,pn(i),ps(i)
     if(pn(i).eq.0.0) pn(i)=1.e-6
     if(ps(i).eq.0.0) ps(i)=1.e-6
  enddo

  write(*,1010) 
1010 format(/                                                              &
  '  EsNo  EbNo  db65    false    fcopy  cycles    ber    ave0    ave1    time'/  &
  '----------------------------------------------------------------------------')

  msg='CQ K1JT FN20'
  call encode4(msg,icode)
  write(c72,1002) imsg6
1002 format(12b6.6)
  read(c72,1004) imsg
1004 format(72i1)

  rate=72.0/206.0
  nbits=72+31
  maxlim=0

  idb1=10 - nint(1.62*int(log(float(nadd))/log(2.0)))
  idb2=-20
  if(snrdb.ne.0.0) idb2=idb1
  do idb=idb1,idb2,-1
     EsNo=idb
     if(snrdb.ne.0.0) EsNo=snrdb
     EbNo=EsNo - 10.0*log10(rate)
     db65=EsNo - 10.0*log10(2500.0/(nadd*11025.0/2520.0))
     sig=sqrt(10.0**(0.1*EsNo))                !Signal level

     ngood=0
     nfalse=0
     nbadbit=0
     sumcycles=0.d0
     sum0=0.d0
     sum1=0.d0
     ttotal=0.

     do iter=1,iters
        do j=1,206                            !Simulate received 2-FSK symbols
           s0=0.
           s1=0.
           do n=1,nadd
              x=0.707107*gran()
              y=0.707107*gran()
              s0=s0 + x**2 + y**2
              x=0.707107*gran()
              y=0.707107*gran()
              s1=s1 + (x+sig)**2 + y**2
           enddo
           s0=s0/nadd
           s1=s1/nadd
           sum0=sum0 + min(s0,s1)
           sum1=sum1 + max(s0,s1)
           if(icode(j).eq.1) then
              sym(0,j)=s0
              sym(1,j)=s1
           else
              sym(0,j)=s1
              sym(1,j)=s0
           endif
        enddo

        nb=0
        do j=1,206
           if(icode(j).eq.1 .and. sym(1,j).lt.sym(0,j)) nb=nb+1
           if(icode(j).eq.0 .and. sym(1,j).ge.sym(0,j)) nb=nb+1
        enddo
        call interleave4a(sym,-1)

        call cpu_time(t0)
        call fano232(sym,nadd,amp,iknown,imsg,nbits,ndelta,limit,    &
             data1,ncycles,metric,ncount)
        call cpu_time(t1)
        ttotal=ttotal + (t1-t0)

        nAvgCycles=ncycles/nbits
        maxlim=max(maxlim,nAvgCycles)
        sumcycles=sumcycles+nAvgCycles
        if(ncount.eq.0) then
           do i=1,9
              i4=data1(i)
              if(i4.lt.0) i4=i4+256
              data4a(i)=i4
           enddo
           write(c72,1100) (data4a(i),i=1,9)
1100       format(9b8.8)
           read(c72,1102) data4
1102       format(12b6)
           call unpackmsg(data4,decoded)
           if(decoded.ne.msg) then
              nfalse=nfalse+1
           else
              ngood=ngood+1
              nbadbit=nbadbit+nb
           endif
        endif
     enddo

     fgood=float(ngood)/iters
     ffalse=float(nfalse)/iters
     avecycles=sumcycles/iters
     ber=nbadbit/((ngood+1)*206.0)
     ave0=sum0/(iters*206.d0)
     ave1=sum1/(iters*206.d0)
     tavg=ttotal/iters
     write(*,1020)  EsNo,EbNo,db65,ffalse,fgood,nint(avecycles),  &
          ber,ave0,ave1,tavg
1020 format(3f6.1,2f9.4,i7,4f8.3)
     if(fgood.eq.0) exit
  enddo

999 end program simjt4
