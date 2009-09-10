subroutine qinit(nb1,ns1,ns2,m0,ncode,minmet,nray,txtime,   &
     snrdb,iters,icos)

! Get parameters from command line

  character arg*12,abc*1
! Golumb rulers:
  integer igol(10,10)
! Costas arrays:
  integer icos(10)
  integer icos4(4)
  integer icos5(5)
  integer icos6(6)
  integer icos7(7)
  integer icos8(8)
  integer icos10(10)
  data icos4/0,1,3,2/
  data icos5/0,2,3,1,4/
  data icos6/0,1,4,3,5,2/
  data icos7/2,5,6,0,4,1,3/
  data icos8/3,6,2,4,5,0,7,1/
  data icos10/0,1,3,7,4,9,8,6,2,5/
  data igol/0,0,0,0,0,0,0,0,0,0,        & !1
            0,0,0,0,0,0,0,0,0,0,        & !2
            0,1,3,0,0,0,0,0,0,0,        & !3
            0,1,4,6,0,0,0,0,0,0,        & !4
            0,1,4,9,11,0,0,0,0,0,       & !5
            0,1,4,10,12,17,0,0,0,0,     & !6
            0,1,4,10,18,23,25,0,0,0,    & !7
            0,1,4,9,15,22,32,34,0,0,    & !8
            0,1,5,12,25,27,35,41,44,0,  & !9
            0,1,6,10,23,26,34,41,53,55/   !10

  nargs=iargc()
  if(nargs.ne.11) then
!                          1   2   3  4   5    6   7   8  9  10   11
     print*,'Usage: quest nb1 ns1 ns2 m ncode min nRay A tm EsNo iters'
     print*,'             78   3   6  6 6313 1000  1   A 47  0   100'
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
  read(arg,*) minmet      !Minimum final metric deemed acceptable
  call getarg(7,arg)
  read(arg,*) nray        ! 0=AWGN  1=Rayleigh
  call getarg(8,abc)     !Submode A B C ...
  call getarg(9,arg)
  read(arg,*) txtime      !Duration of transmission (s)
  call getarg(10,arg)
  read(arg,*) snrdb       !EsNo
  call getarg(11,arg)
  read(arg,*) iters       !Iterations per snr level

  n=(nb1+m0-1)/m0
  nb1=n*m0

  if(ns2.ge.4 .and. ns2.le.10 .and. ns2.ne.9) then
! Copy the requested Costas array.
     do i=1,ns2
        if(ns2.eq.4) icos(i)=icos4(i)
        if(ns2.eq.5) icos(i)=icos5(i)
        if(ns2.eq.6) icos(i)=icos6(i)
        if(ns2.eq.7) icos(i)=icos7(i)
        if(ns2.eq.8) icos(i)=icos8(i)
        if(ns2.eq.10) icos(i)=icos10(i)
     enddo
  else if(ns2.le.-3 .and. ns2.ge.-10) then
     do i=1,-ns2
        icos(i)=igol(i,-ns2)
     enddo
  else
     print*,'Unsupported ns2:',ns2
     stop
  endif

  return
end subroutine qinit
