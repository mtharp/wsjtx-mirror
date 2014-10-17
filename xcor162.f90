!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    xcor162.f90
! Description:  Computes ccf of a row of s2 and the pseudo-random array pr3.
!               Returns peak of the CCF and the lag at which peak occurs.
!
! Copyright (C) 2001-2014 Joseph Taylor, K1JT
! License: GPL-3
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
subroutine xcor162(s2,ipk,nsteps,nsym,lag1,lag2,ccf,ccf0,lagpk)

!  Computes ccf of a row of s2 and the pseudo-random array pr3.  Returns
!  peak of the CCF and the lag at which peak occurs.  

  parameter (NFFT=512)
  parameter (NH=NFFT/2)
  parameter (NSMAX=352)
  real s2(-NH:NH,NSMAX)
  real a(NSMAX)
  real ccf(-5:540)
  logical first
  data first/.true./
  integer npr3(162)
  real pr3(162)
  data npr3/                                                              &
       & 1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,                         &
       & 0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,                         &
       & 0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,                         &
       & 1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,                         &
       & 0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,                         &
       & 0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,                         &
       & 0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,                         &
       & 0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,                         &
       & 0,0/
  save

  if(first) then
     nsym=162
     do i=1,nsym
        pr3(i)=2*npr3(i)-1
     enddo
     first=.false.
  endif

  n=2
  method=2
  do j=1,nsteps
     if(method.eq.1) then
        a(j)=0.5*(s2(ipk+n,j) + s2(ipk+3*n,j) -                      &
             &       s2(ipk  ,j) - s2(ipk+2*n,j))
     else
        a(j)=max(s2(ipk+n,j),s2(ipk+3*n,j)) -                        &
             &          max(s2(ipk  ,j),s2(ipk+2*n,j))
     endif
  enddo

  ccfmax=0.
  do lag=lag1,lag2
     x=0.
     do i=1,nsym
        j=2*i-1+lag
        if(j.ge.1 .and. j.le.nsteps) x=x+a(j)*pr3(i)
     enddo
     ccf(lag)=2*x                        !The 2 is for plotting scale
     if(ccf(lag).gt.ccfmax) then
        ccfmax=ccf(lag)
        lagpk=lag
     endif
  enddo
  ccf0=ccfmax

  return
end subroutine xcor162
