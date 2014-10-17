!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    phasetx.f90
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
subroutine phasetx(id2,npts,txbal,txpha)

  integer*2 id2(2,npts)

  pha=txpha/57.2957795
  xbal=10.0**(0.005*txbal)
  if(xbal.gt.1.0) then
     b1=1.0
     b2=1.0/xbal
  else
     b1=xbal
     b2=1.0
  endif
  do i=1,npts
     x=id2(1,i)
     y=id2(2,i)
     amp=sqrt(x*x+y*y)
     phi=atan2(y,x)
     id2(1,i)=nint(b1*amp*cos(phi))
     id2(2,i)=nint(b2*amp*sin(phi+pha))
  enddo

  return
end subroutine phasetx
