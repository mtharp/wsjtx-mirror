!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    packtext2.f90
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
subroutine packtext2(msg,n1,ng)

  character*8 msg
  real*8 dn
  character*41 c
  data c/'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ +./?'/

  dn=0.
  do i=1,8
     do j=1,41
        if(msg(i:i).eq.c(j:j)) go to 10
     enddo
     j=37
10   j=j-1                                !Codes should start at zero
     dn=41.d0*dn + j
  enddo

  ng=mod(dn,32768.d0)
  n1=(dn-ng)/32768.d0

  return
end subroutine packtext2
