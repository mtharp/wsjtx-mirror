!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    encode232.f90
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
subroutine encode232(dat,nbytes,symbol,maxsym)

! Convolutional encoder for a K=32, r=1/2 code.

  integer*1 dat(nbytes)             !User data, packed 8 bits per byte
  integer*1 symbol(maxsym)          !Channel symbols, one bit per byte
  integer*1 i1
  include 'conv232.f90'

  nstate=0
  k=0
  do j=1,nbytes
     do i=7,0,-1
        i1=dat(j)
        i4=i1
        if (i4.lt.0) i4=i4+256
        nstate=ior(ishft(nstate,1),iand(ishft(i4,-i),1))
        n=iand(nstate,npoly1)
        n=ieor(n,ishft(n,-16))
        k=k+1
        symbol(k)=partab(iand(ieor(n,ishft(n,-8)),255))
        n=iand(nstate,npoly2)
        n=ieor(n,ishft(n,-16))
        k=k+1
        symbol(k)=partab(iand(ieor(n,ishft(n,-8)),255))
     enddo
  enddo

  return
end subroutine encode232
