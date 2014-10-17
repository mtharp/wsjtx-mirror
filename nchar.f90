!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    nchar.f90
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
function nchar(c)

! Convert ASCII number, letter, or space to 0-36 for callsign packing.

  character c*1
  data n/0/                            !Silence compiler warning

  if(c.ge.'0' .and. c.le.'9') then
     n=ichar(c)-ichar('0')
  else if(c.ge.'A' .and. c.le.'Z') then
     n=ichar(c)-ichar('A') + 10
  else if(c.ge.'a' .and. c.le.'z') then
     n=ichar(c)-ichar('a') + 10
  else if(c.ge.' ') then
     n=36
  else
     Print*,'Invalid character in callsign ',c,' ',ichar(c)
     stop
  endif
  nchar=n

  return
end function nchar
