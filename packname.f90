!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    packname.f90
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
subroutine packname(name,len,n1,n2)

  character*9 name
  real*8 dn

  dn=0
  do i=1,len
     n=ichar(name(i:i))
     if(n.ge.97 .and. n.le.122) n=n-32
     dn=27*dn + n-64
  enddo
  if(len.lt.9) then
     do i=len+1,9
        dn=27*dn
     enddo
  endif

  n2=mod(dn,32768.d0)
  dn=dn/32768.d0
  n1=dn

  return
end subroutine packname
