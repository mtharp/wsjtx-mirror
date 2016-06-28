!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    set.f90
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
subroutine set(a,y,n)
  real y(n)
  do i=1,n
     y(i)=a
  enddo
  return
end subroutine set

subroutine move(x,y,n)
  real x(n),y(n)
  do i=1,n
     y(i)=x(i)
  enddo
  return
end subroutine move

subroutine zero(x,n)
  real x(n)
  do i=1,n
     x(i)=0.0
  enddo
  return
end subroutine zero

subroutine add(a,b,c,n)
  real a(n),b(n),c(n)
  do i=1,n
     c(i)=a(i)+b(i)
  enddo
  return
end subroutine add
