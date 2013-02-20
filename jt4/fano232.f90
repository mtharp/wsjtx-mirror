subroutine fano232(symbol,sym,nadd,nmet,amp,iknown,imsg,nbits,mettab,    &
     ndelta,maxcycles,dat,ncycles,metric,ierr)

! Sequential decoder for K=32, r=1/2 convolutional code using 
! the Fano algorithm.  Translated from C routine for same purpose
! written by Phil Karn, KA9Q.

  parameter (MAXBITS=103)
  parameter (MAXBYTES=(MAXBITS+7)/8)
  integer*1 symbol(0:2*MAXBITS-1)  !Soft symbols (as unsigned i*1)
  real sym(0:1,0:205)
  integer imsg(72)
  logical iknown(72)
  integer*1 dat(MAXBYTES)          !Decoded user data, 8 bits per byte
  integer mettab(0:255,0:1)        !Metric table

! These were the "node" structure in Karn's C code:
  integer nstate(0:MAXBITS-1)      !Encoder state of next node
  integer gamma(0:MAXBITS-1)       !Cumulative metric to this node
  integer metrics(0:3,0:MAXBITS-1) !Metrics indexed by all possible Tx syms
  integer tm(0:1,0:MAXBITS-1)      !Sorted metrics for current hypotheses
  integer ii(0:MAXBITS-1)          !Current branch being tested

  logical noback
  include 'conv232.f90'            !Polynomials defined here

! Compute all possible branch metrics for each symbol pair.
! This is the only place we actually look at the raw input symbols
  i4a=0
  i4b=0
  do np=0,nbits-1
     j=2*np
 !    if(nmet.eq.0) then
        i4a=symbol(j)
        i4b=symbol(j+1)
        if (i4a.lt.0) i4a=i4a+256
        if (i4b.lt.0) i4b=i4b+256
        metrics(0,np) = mettab(i4a,0) + mettab(i4b,0)
        metrics(1,np) = mettab(i4a,0) + mettab(i4b,1)
        metrics(2,np) = mettab(i4a,1) + mettab(i4b,0)
        metrics(3,np) = mettab(i4a,1) + mettab(i4b,1)
 !    else

        n=min(2*nadd,18)                                     !### limit ??
        call getmu(sym(0,j),sym(1,j),n,amp,mu0j0,mu1j0)
        call getmu(sym(0,j+1),sym(1,j+1),n,amp,mu0j1,mu1j1)
        m0 = mu0j0 + mu0j1
        m1 = mu0j0 + mu1j1
        m2 = mu1j0 + mu0j1
        m3 = mu1j0 + mu1j1

     write(72,3101) np,metrics(0:3,np),m0,m1,m2,m3
3101 format(i3,4i6,4x,4i6)
        if(nmet.ne.0) then
           metrics(0,np) = m0
           metrics(1,np) = m1
           metrics(2,np) = m2
           metrics(3,np) = m3
        endif
  enddo

  np=0
  nstate(np)=0

  n=iand(nstate(np),npoly1)                  !Compute and sort branch metrics 
  n=ieor(n,ishft(n,-16))                     !from the root node
  lsym=partab(iand(ieor(n,ishft(n,-8)),255))
  n=iand(nstate(np),npoly2)
  n=ieor(n,ishft(n,-16))
  lsym=lsym+lsym+partab(iand(ieor(n,ishft(n,-8)),255))
  m0=metrics(lsym,np)
  m1=metrics(ieor(3,lsym),np)
  if(m0.gt.m1) then
     tm(0,np)=m0                             !0-branch has better metric
     tm(1,np)=m1
  else
     tm(0,np)=m1                             !1-branch is better
     tm(1,np)=m0
     nstate(np)=nstate(np) + 1               !Set low bit
  endif

  ii(np)=0                                   !Start with best branch
  gamma(np)=0
  nt=0

  do i=1,nbits*maxcycles                     !Start the Fano decoder
!     write(71,3001) i,np,nstate(np),gamma(np),tm(0:1,np),ii(np)
!3001 format(i9,i4,1x,b32.32,i5,2i5,i2)
     ibit=iand(nstate(np),1)
     ierr=0
     if(np.le.71 .and. ibit.ne.imsg(np+1)) ierr=1
!     write(71,3001) i,np,ibit,ierr,gamma(np),tm(0:1,np),ii(np)
!3001 format(i9,i4,2i3,i5,2i5,i3)
     ngamma=gamma(np) + tm(ii(np),np)        !Look forward
     if(np.le.71 .and. iknown(np+1)) then
        if(ierr.eq.0) then
           ngamma=ngamma + 10
        else
           ngamma=ngamma - 20
        endif
     endif

     if(ngamma.ge.nt) then
! Node is acceptable.  If first time visiting this node, tighten threshold:
        if(gamma(np).lt.(nt+ndelta)) nt=nt + ndelta * ((ngamma-nt)/ndelta)
        gamma(np+1)=ngamma                   !Move forward
        nstate(np+1)=ishft(nstate(np),1)
        np=np+1
        if(np.eq.nbits-1) go to 100          !We're done!

        n=iand(nstate(np),npoly1)
        n=ieor(n,ishft(n,-16))
        lsym=partab(iand(ieor(n,ishft(n,-8)),255))
        n=iand(nstate(np),npoly2)
        n=ieor(n,ishft(n,-16))
        lsym=lsym+lsym+partab(iand(ieor(n,ishft(n,-8)),255))
            
        if(np.ge.nbits-31) then
           tm(0,np)=metrics(lsym,np)      !We're in the tail, now all zeros
           tm(1,np)=0                     !Added for plots: not used
        else
           m0=metrics(lsym,np)
           m1=metrics(ieor(3,lsym),np)
           if(m0.gt.m1) then
              tm(0,np)=m0                 !0-branch has better metric
              tm(1,np)=m1
           else
              tm(0,np)=m1                 !1-branch is better
              tm(1,np)=m0
              nstate(np)=nstate(np) + 1   !Set low bit
           endif
        endif
        ii(np)=0                          !Start with best branch
     else
        do while(.true.)
           noback=.false.                 !Threshold violated, can't go forward
           if(np.eq.0) noback=.true.
           if(np.gt.0) then
              if(gamma(np-1).lt.nt) noback=.true.
           endif

           if(noback) then               !Can't back up, either
              nt=nt-ndelta               !Relax threshold and look forward again
              if(ii(np).ne.0) then
                 ii(np)=0
                 nstate(np)=ieor(nstate(np),1)
              endif
              exit
           endif

           np=np-1                       !Back up
           if(np.lt.(nbits-31) .and. ii(np).ne.1) then
              ii(np)=ii(np)+1            !Search the next best branch
              nstate(np)=ieor(nstate(np),1)
              exit
           endif
        enddo
     endif
  enddo
  i=nbits*maxcycles
  
100 metric=gamma(np)                       !Final path metric
  nbytes=(nbits+7)/8                       !Copy decoded data to user's buffer
  np=7
  do j=1,nbytes-1
     i4a=nstate(np)
     dat(j)=i4a
     np=np+8
  enddo
  dat(nbytes)=0
  ncycles=i+1
  ierr=0
  if(i.ge.maxcycles*nbits) ierr=-1

  return
end subroutine fano232
