!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    packprop.f90
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
subroutine packprop(k,muf,ccur,cxp,n1)

! Pack propagation indicators into a 21-bit number.

! k      k-index, 0-9; 10="N/A"
! muf    muf, 2-60 MHz; 0=N/A, 1="none", 61=">60 MHz"
! ccur   up to two current events, each indicated by single
!        or double letter.
! cxp    zero or one expected event, indicated by single or
!        double letter

  character ccur*4,cxp*2

  j=ichar(ccur(1:1))-64
  if(j.lt.0) j=0
  n1=j
  do i=2,4
     if(ccur(i:i).eq.' ') go to 10
     if(ccur(i:i).eq.ccur(i-1:i-1)) then
        n1=n1+26
     else
        j=ichar(ccur(i:i))-64
        if(j.lt.0) j=0
        n1=53*n1 + j
     endif
  enddo

10 j=ichar(cxp(1:1))-64
  if(j.lt.0) j=0
  if(cxp(2:2).eq.cxp(1:1)) j=j+26
  n1=53*n1 + j
  n1=11*n1 + k
  n1=62*n1 + muf

  return
end subroutine packprop
