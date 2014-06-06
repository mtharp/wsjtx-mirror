!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    fold1pps.f90
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
subroutine fold1pps(x,npts,ip1,ip2,prof,p,pk,ipk)

  parameter (NFSMAX=48000)
  real x(npts)
  real proftmp(NFSMAX+5),prof(NFSMAX+5)
  real*8 p,ptmp

  pk=0.
  do ip=ip1,ip2
     call ffa(x,npts,npts,ip,proftmp,ptmp,pktmp,ipktmp)
     if(abs(pktmp).gt.abs(pk)) then
        p=ptmp
        pk=pktmp
        ipk=ipktmp
        prof(:ip)=proftmp(:ip)
     endif
  enddo
  ip=p
  if(pk.lt.0.0) then
     prof(:ip)=-prof(:ip)
  endif

  return
end subroutine fold1pps
