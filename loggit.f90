!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    loggit.f90
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
subroutine loggit(msg)
  character*(*) msg
  character*20 m20
  real*8 tsec1,trseconds
  integer nt(9)
  include 'acom1.f90'

  call cs_lock('loggit')
  call gmtime2(nt,tsec1)
  trseconds=60*ntrminutes
  sectr=mod(tsec1,trseconds)
  m20=msg//'                    '
  write(19,1000) cdate(3:8),utctime(1:2),utctime(3:4),utctime(5:10),sectr,m20
1000 format(a6,1x,a2,':',a2,':',a5,f8.2,2x,a20)
  call flush(19)
  call cs_unlock

  return
end subroutine loggit
