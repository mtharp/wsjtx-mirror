!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    slope.f90
! Description:  
!
! Copyright (C) 2001-2014 Joseph Taylor, K1JT
! License: GNU GPL v3
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
subroutine slope(y,npts,xpk)

! Remove best-fit slope from data in y(i).  When fitting the straight line,
! ignore the peak around xpk +/- 2.

  real y(npts)
  real x(100)

  do i=1,npts
     x(i)=i
  enddo

  sumw=0.
  sumx=0.
  sumy=0.
  sumx2=0.
  sumxy=0.
  sumy2=0.

  do i=1,npts
     if(abs(i-xpk).gt.2.0) then
        sumw=sumw + 1.0
        sumx=sumx + x(i)
        sumy=sumy + y(i)
        sumx2=sumx2 + x(i)**2
        sumxy=sumxy + x(i)*y(i)
        sumy2=sumy2 + y(i)**2
     endif
  enddo

  delta=sumw*sumx2 - sumx**2
  a=(sumx2*sumy - sumx*sumxy) / delta
  b=(sumw*sumxy - sumx*sumy) / delta

  do i=1,npts
     y(i)=y(i)-(a + b*x(i))
  enddo

  return
end subroutine slope

