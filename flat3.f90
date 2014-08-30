!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    flat3.f90
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
subroutine flat3(ss0,n,nsum)

  parameter (NZ=256)
  real ss0(NZ)
  real ss(NZ)
  real ref(NZ)
  real tmp(NZ)

  ss(1:128)=ss0(129:256)
  ss(129:256)=ss0(1:128)
!  call move(ss0,ss(129),128)
!  call move(ss0(129),ss,128)

  nsmo=20
  base=50*(float(nsum)**1.5)
  ia=nsmo+1
  ib=n-nsmo-1
  do i=ia,ib
     call pctile(ss(i-nsmo),tmp,2*nsmo+1,35,ref(i))
  enddo
  do i=ia,ib
     ss(i)=base*ss(i)/ref(i)
  enddo

  ss0(1:128)=ss(129:256)
  ss0(129:256)=ss(1:128)
!  call move(ss(129),ss0,128)
!  call move(ss,ss0(129),128)

  return
end subroutine flat3
