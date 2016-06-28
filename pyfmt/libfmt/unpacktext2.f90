!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    unpacktext2.f90
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
subroutine unpacktext2(n1,ng,msg)

  character*22 msg
  real*8 dn
  character*41 c
  data c/'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ +./?'/

  msg='                      '
  dn=32768.d0*n1 + ng
  do i=8,1,-1
     j=mod(dn,41.d0)
     msg(i:i)=c(j+1:j+1)
     dn=dn/41.d0
  enddo

  return
end subroutine unpacktext2
