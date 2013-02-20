subroutine fano232r(sym,nadd,amp,iknown,imsg,nbits,ndelta,maxcycles,   &
     dat,ncycles,metric,ierr)

! Sequential decoder for K=32, r=1/2 convolutional code using 
! the Fano algorithm.  Translated from C routine by Phil Karn, KA9Q.

  parameter (MAXBITS=103)
  parameter (MAXBYTES=(MAXBITS+7)/8)
  real*4  sym(0:1,0:205)
  real*4  symr(0:1,0:205)
  integer imsg(72)
  logical iknown(72)
  integer*1 dat(MAXBYTES)          !Decoded user data, 8 bits per byte

! These were the "node" structure in Karn's C code:
  integer nstate(0:MAXBITS-1)      !Encoder state of next node
  integer gamma(0:MAXBITS-1)       !Cumulative metric to this node
  integer metrics(0:3,0:MAXBITS-1) !Metric increments indexed by Tx/Rx syms
  integer tm(0:1,0:MAXBITS-1)      !Sorted metrics for current hypotheses
  integer ii(0:MAXBITS-1)          !Current branch being tested (0 or 1)

  logical noback
  include 'conv232.f90'            !Polynomials defined here

  symr(0:1,0:205)=sym(0:1,205:0:-1)    !Get sym in reverse order
  npoly1r=0
  npoly2r=0
  do i=0,31                                           !Make bit-reversed polys
     if(btest(npoly1,i)) npoly1r=ibset(npoly1r,31-i)
     if(btest(npoly2,i)) npoly2r=ibset(npoly2r,31-i)
  enddo

! Compute all possible branch metrics for each symbol pair.
! This is the only place we actually look at the raw input symbols
  do k=0,nbits-1
     j=2*k
     n=2*nadd
     call getmu(symr(0,j),symr(1,j),n,amp,mu0j0,mu1j0)        !POLY1
     call getmu(symr(0,j+1),symr(1,j+1),n,amp,mu0j1,mu1j1)    !POLY2
     metrics(0,k)=mu0j0 + mu0j1   !Tx=0, Rx=0  (### ??? ###)
     metrics(1,k)=mu0j0 + mu1j1   !Tx=0, Rx=1
     metrics(2,k)=mu1j0 + mu0j1   !Tx=1, Rx=0
     metrics(3,k)=mu1j0 + mu1j1   !Tx=1, Rx=1
  enddo

  k=0
  nstate(k)=0

  n=iand(nstate(k),npoly1r)                   !Compute and sort branch metrics 
  n=ieor(n,ishft(n,-16))                     !from the root node
  lsym=partab(iand(ieor(n,ishft(n,-8)),255))
  n=iand(nstate(k),npoly2r)
  n=ieor(n,ishft(n,-16))
  lsym=lsym+lsym+partab(iand(ieor(n,ishft(n,-8)),255))
  m0=metrics(lsym,k)
  m1=metrics(ieor(3,lsym),k)
  if(m0.gt.m1) then
     tm(0,k)=m0                             !0-branch has better metric
     tm(1,k)=m1
  else
     tm(0,k)=m1                             !1-branch is better
     tm(1,k)=m0
     nstate(k)=nstate(k) + 1                !Set low bit
  endif

  ii(k)=0                                   !Start with best branch
  gamma(k)=0
  nt=0

  do i=1,nbits*maxcycles                    !Start the Fano decoder
!     write(71,3001) i,k,nstate(k),gamma(k),tm(0:1,k),ii(k)
!3001 format(i9,i4,1x,b32.32,i5,2i5,i2)
!     write(71,3001) i,k,ibit,ierr,gamma(k),tm(0:1,k),ii(k)
!3001 format(i9,i4,2i3,i5,2i5,i3)
     ngamma=gamma(k) + tm(ii(k),k)          !Look forward

     if(k.le.71 .and. iknown(k+1)) then     !Account for "known" bits
        ibit=iand(nstate(k),1)              !Present bit value
        if(k.le.71 .and. ibit.eq.imsg(k+1)) then
           ngamma=ngamma + 12               !Present bit is correct
        else
           ngamma=ngamma - 24               !Present bit is wrong
        endif
     endif

     if(ngamma.ge.nt) then
! Node is acceptable.  If first time visiting this node, tighten threshold:
        if(gamma(k).lt.(nt+ndelta)) nt=nt + ndelta * ((ngamma-nt)/ndelta)
        gamma(k+1)=ngamma                  !Move forward
        nstate(k+1)=ishft(nstate(k),1)
        k=k+1
        if(k.eq.nbits-1) go to 100         !We're done!

        n=iand(nstate(k),npoly1r)
        n=ieor(n,ishft(n,-16))
        lsym=partab(iand(ieor(n,ishft(n,-8)),255))
        n=iand(nstate(k),npoly2r)
        n=ieor(n,ishft(n,-16))
        lsym=lsym+lsym+partab(iand(ieor(n,ishft(n,-8)),255))
            
        if(k.ge.nbits-31) then
           tm(0,k)=metrics(lsym,k)         !We're in the tail, now all zeros
           tm(1,k)=0                       !Added for plots: not used
        else
           m0=metrics(lsym,k)
           m1=metrics(ieor(3,lsym),k)
           if(m0.gt.m1) then
              tm(0,k)=m0                   !0-branch has better metric
              tm(1,k)=m1
           else
              tm(0,k)=m1                   !1-branch is better
              tm(1,k)=m0
              nstate(k)=nstate(k) + 1      !Set low bit
           endif
        endif
        ii(k)=0                            !Start with best branch
     else
        do while(.true.)
           noback=.false.                  !Threshold violated, can't go forward
           if(k.eq.0) noback=.true.
           if(k.gt.0) then
              if(gamma(k-1).lt.nt) noback=.true.
           endif

           if(noback) then               !Can't back up, either
              nt=nt-ndelta               !Relax threshold and look forward again
              if(ii(k).ne.0) then
                 ii(k)=0
                 nstate(k)=ieor(nstate(k),1)
              endif
              exit
           endif

           k=k-1                         !Back up
           if(k.lt.(nbits-31) .and. ii(k).ne.1) then
              ii(k)=ii(k)+1              !Search the next best branch
              nstate(k)=ieor(nstate(k),1)
              exit
           endif
        enddo
     endif
  enddo
  i=nbits*maxcycles
  
100 metric=gamma(k)                      !Final path metric
  nbytes=(nbits+7)/8                     !Copy decoded data to user's buffer
  k=7
  do j=1,nbytes-1
     i4a=nstate(k)
     dat(j)=i4a
     k=k+8
  enddo
  dat(nbytes)=0
  ncycles=i+1
  ierr=0
  if(i.ge.maxcycles*nbits) ierr=-1

  return
end subroutine fano232r
