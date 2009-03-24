subroutine qinit(nb1,ns1,ns2,m0,ncode,limit,nray,txtime,   &
     snrdb,iters,icos)

! Get parameters from command line

  character arg*12
! Costas arrays:
  integer icos(10)
  integer icos4(4)
  integer icos5(5)
  integer icos6(6)
  integer icos8(8)
  integer icos10(10)
  data icos4/0,1,3,2/
  data icos5/0,2,3,1,4/
  data icos6/0,1,4,3,5,2/
  data icos8/3,6,2,4,5,0,7,1/
  data icos10/0,1,3,7,4,9,8,6,2,5/

  nargs=iargc()
  if(nargs.ne.10) then
!                          1   2   3  4   5    6    7   8  9    10 
     print*,'Usage: quest nb1 ns1 ns2 m ncode lim nRay tm EsNo iters'
     print*,'             75   3   8  3  416 1000  1   47  0   100'
     stop
  endif

  call getarg(1,arg)
  read(arg,*) nb1         !Bits in user message
  call getarg(2,arg)
  read(arg,*) ns1         !Sync blocks
  call getarg(3,arg)
  read(arg,*) ns2         !Size of sync block
  call getarg(4,arg)
  read(arg,*) m0          !ntones = 2**m0
  call getarg(5,arg)
  read(arg,*) ncode       !414 ==> K=14, r=1/4
  call getarg(6,arg)
  read(arg,*) limit      !Minimum acceptable metric, or timeout limit
  call getarg(7,arg)
  read(arg,*) nray        ! 0=AWGN  1=Rayleigh
  call getarg(8,arg)
  read(arg,*) txtime      !Duration of transmission (s)
  call getarg(9,arg)
  read(arg,*) snrdb       !EsNo
  call getarg(10,arg)
  read(arg,*) iters       !Iterations per snr level

  n=(nb1+m0-1)/m0
  nb1=n*m0

! Copy the requested Costas array.
  do i=1,ns2
     if(ns2.eq.4) icos(i)=icos4(i)
     if(ns2.eq.5) icos(i)=icos5(i)
     if(ns2.eq.6) icos(i)=icos6(i)
     if(ns2.eq.8) icos(i)=icos8(i)
     if(ns2.eq.10) icos(i)=icos10(i)
  enddo

  return
end subroutine qinit
