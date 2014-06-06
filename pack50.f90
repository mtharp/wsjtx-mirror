!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    pack50.f90
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
subroutine pack50(n1,n2,dat)

  integer*1 dat(11),i1

  i1=iand(ishft(n1,-20),255)                !8 bits
  dat(1)=i1
  i1=iand(ishft(n1,-12),255)                 !8 bits
  dat(2)=i1
  i1=iand(ishft(n1, -4),255)                 !8 bits
  dat(3)=i1
  i1=16*iand(n1,15)+iand(ishft(n2,-18),15)   !4+4 bits
  dat(4)=i1
  i1=iand(ishft(n2,-10),255)                 !8 bits
  dat(5)=i1
  i1=iand(ishft(n2, -2),255)                 !8 bits
  dat(6)=i1
  i1=64*iand(n2,3)                           !2 bits
  dat(7)=i1
  dat(8)=0
  dat(9)=0
  dat(10)=0
  dat(11)=0

  return
end subroutine pack50

