!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    packgrid.f90
! Description:  
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
subroutine packgrid(grid,ng,text)

  parameter (NGBASE=180*180)
  character*4 grid
  logical text

  text=.false.
  if(grid.eq.'    ') go to 90                 !Blank grid is OK

! Test for numerical signal report, etc.
  if(grid(1:1).eq.'-') then
     n=10*(ichar(grid(2:2))-48) + ichar(grid(3:3)) - 48
     ng=NGBASE+1+n
     go to 100
  else if(grid(1:2).eq.'R-') then
     n=10*(ichar(grid(3:3))-48) + ichar(grid(4:4)) - 48
     if(n.eq.0) go to 90
     ng=NGBASE+31+n
     go to 100
  else if(grid(1:2).eq.'RO') then
     ng=NGBASE+62
     go to 100
  else if(grid(1:3).eq.'RRR') then
     ng=NGBASE+63
     go to 100
  else if(grid(1:2).eq.'73') then
     ng=NGBASE+64
     go to 100
  endif

  if(grid(1:1).lt.'A' .or. grid(1:1).gt.'R') text=.true.
  if(grid(2:2).lt.'A' .or. grid(2:2).gt.'R') text=.true.
  if(grid(3:3).lt.'0' .or. grid(3:3).gt.'9') text=.true.
  if(grid(4:4).lt.'0' .or. grid(4:4).gt.'9') text=.true.
  if(text) go to 100

  call grid2deg(grid//'mm',dlong,dlat)
  long=dlong
  lat=dlat+ 90.0
  ng=((long+180)/2)*180 + lat
  go to 100

90 ng=NGBASE + 1

100 return
end subroutine packgrid

