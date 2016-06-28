!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    averms.f90
! Description:
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
subroutine averms(x,npts,ave,rms,xmax)

  real x(npts)

  s=0.
  xmax=0.
  do i=1,npts
     s=s + x(i)
     xmax=max(xmax,abs(x(i)))
  enddo
  ave=s/npts

  sq=0.
  do i=1,npts
     sq=sq + (x(i)-ave)**2
  enddo
  rms=sqrt(sq/(npts-1))
  
  return
end subroutine averms
