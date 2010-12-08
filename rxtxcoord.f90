subroutine rxtxcoord(nsec,iband,pctx,nrx,ntxnext)

! Determine Rx or Tx in coordinated hopping mode.

  integer tx(10,6)
  real r(6)
  integer ii(1)
  data nsec0/-1/
  save nsec0,tx
  
  if(nsec-nsec0.gt.2*3600) then
! At startup and whenever 2 hours have elapsed, compute new Rx/Tx pattern
     nsec0=nsec
     tx=0
     do j=1,10
        call random_number(r)
        do i=1,6,2
           if(r(i).gt.r(i+1)) then
              tx(j,i)=1
              r(i+1)=0.
           else
              tx(j,i+1)=1
              r(i)=0.
           endif
        enddo

        if(pctx.lt.50.0) then
           ii=maxloc(r)
           i=ii(1)
           call random_number(rr)
           rrtest=(50.0-pctx)/16.667
           if(rr.lt.rrtest) then
              tx(j,i)=0
              r(i)=0.
           endif
        endif

        if(pctx.lt.33.333) then
           ii=maxloc(r)
           i=ii(1)
           call random_number(rr)
           rrtest=(33.333-pctx)/16.667
           if(rr.lt.rrtest) then
              tx(j,i)=0
              r(i)=0.
           endif
        endif
     enddo
  endif

  iseq=mod((nsec-nsec0)/120,6) + 1
  ib=mod(iband+8,10) + 1
  if(tx(ib,iseq).eq.1) then
     ntxnext=1
  else
     nrx=1
  endif

  return
end subroutine rxtxcoord
