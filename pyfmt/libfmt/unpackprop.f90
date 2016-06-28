!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    unpackprop.f90
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
subroutine unpackprop(n1,k,muf,ccur,cxp)

  character ccur*4,cxp*2

  muf=mod(n1,62)
  n1=n1/62

  k=mod(n1,11)
  n1=n1/11

  j=mod(n1,53)
  n1=n1/53
  if(j.eq.0) cxp='*'
  if(j.ge.1 .and. j.le.26) cxp=char(64+j)
  if(j.gt.26) cxp=char(64+j-26)//char(64+j-26)

  j=mod(n1,53)
  n1=n1/53
  if(j.eq.0) ccur(2:2)='*'
  if(j.ge.1 .and. j.le.26) ccur(2:2)=char(64+j)
  if(j.gt.26) ccur(2:3)=char(64+j-26)//char(64+j-26)
  j=n1
  if(j.eq.0) ccur(1:1)='*'
  if(j.ge.1 .and. j.le.26) ccur(1:1)=char(64+j)
  if(j.gt.26) ccur=char(64+j-26)//char(64+j-26)//ccur(2:3)

  return
end subroutine unpackprop
