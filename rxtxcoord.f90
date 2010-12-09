subroutine rxtxcoord(ns0,pctx,nrx,ntxnext)

! Determine Rx or Tx in coordinated hopping mode.

  integer tx(10,6)    !T/R array for 2 hours: 10 bands, 6 time slots per band
  real r(6)           !Random numbers
  integer ii(1)
  data nsec0/-10000000/
  save nsec0,tx
  
  nsec=(ns0+10)/120
  nsec=nsec*120
  if(abs(nsec-nsec0).gt.7200 - 10) then
! At startup and whenever 2 hours have elapsed, compute new Rx/Tx pattern
     nsec0=nsec                       !Save time when new array is computed
     tx=0                             !Clear the tx array
     do j=1,10                        !Loop over all 10 bands
        call random_number(r)
        do i=1,6,2                    !Select one each of 3 pairs of the 
           if(r(i).gt.r(i+1)) then    !  6 slots for Tx
              tx(j,i)=1
              r(i+1)=0.
           else
              tx(j,i+1)=1
              r(i)=0.
           endif
        enddo

        if(pctx.lt.50.0) then         !If pctx < 50, we may kill one Tx slot
           ii=maxloc(r)
           i=ii(1)
           call random_number(rr)
           rrtest=(50.0-pctx)/16.667
           if(rr.lt.rrtest) then
              tx(j,i)=0
              r(i)=0.
           endif
        endif

        if(pctx.lt.33.333) then       !If pctx < 33, may kill another
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

! We now have 1 to 3 Tx periods per band in the 2-hour interval.

  endif

  iband=mod(nsec/120,10) + 1
  iseq=mod((nsec-nsec0)/1200,6) + 1
  if(iseq.lt.1) iseq=1
  if(tx(iband,iseq).eq.1) then
     ntxnext=1
  else
     nrx=1
  endif

  return
end subroutine rxtxcoord
