!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    getrms.f90
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
subroutine getrms(iwave,npts,ave,rms)

  integer*2 iwave(npts)
  real*8 sq

  s=0.
  do i=1,npts
     s=s + iwave(i)
  enddo
  ave=s/npts
  sq=0.
  do i=1,npts
     sq=sq + (iwave(i)-ave)**2
  enddo
  rms=sqrt(sq/npts)
  fac=3000.0/rms
  do i=1,npts
     n=nint(fac*(iwave(i)-ave))
     if(n.gt.32767) n=32767
     if(n.lt.-32767) n=-32767
     iwave(i)=n
  enddo

  return
end subroutine getrms
