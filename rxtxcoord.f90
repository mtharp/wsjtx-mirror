!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    rxtxcoord.f90
! Description:  Determine Rx or Tx in coordinated hopping mode
!
! Copyright (C) 2001-2014 Joseph Taylor, K1JT
! License: GPL-3+
!
! This program is free software; you can redistribute it and/or modify it under
! the terms of the GNU General Public License as published by the Free Software
! Foundation; either version 3 of the License, or (at your option) any later
! version.
!
! This program is distributed in the hope that it will be useful, but WITHOUT
! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
! FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
! details.
!
! You should have received a copy of the GNU General Public License along with
! this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
! Street, Fifth Floor, Boston, MA 02110-1301, USA.
!
!-------------------------------------------------------------------------------
subroutine rxtxcoord(ns0,pctx,nrx,ntxnext)

! Determine Rx or Tx in coordinated hopping mode.

  integer tx(10,6)    !T/R array for 2 hours: 10 bands, 6 time slots
  real r(6)           !Random numbers
  integer ii(1)
  data n2hr0/-999/
  save n2hr0,tx
  
  nsec=(ns0+10)/120                   !Round up to start of next 2-min slot
  nsec=nsec*120
  n2hr=nsec/7200                      !2-hour slot number

  if(n2hr.ne.n2hr0) then
! Compute a new Rx/Tx pattern for this 2-hour interval
     n2hr0=n2hr                       !Mark this one as done
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
  iseq=mod(nsec/1200,6) + 1
  if(iseq.lt.1) iseq=1
  if(tx(iband,iseq).eq.1) then
     ntxnext=1
  else
     nrx=1
  endif

  return
end subroutine rxtxcoord
