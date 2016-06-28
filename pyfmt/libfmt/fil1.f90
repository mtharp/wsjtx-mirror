!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    fil1.f90
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
subroutine fil1(id1,n1,id2,n2)

! FIR lowpass filter designed using ScopeFIR

! fsample     = 48000 Hz
! Ntaps       = 37
! fc          = 3000  Hz
! fstop       = 6000  Hz
! Ripple      = 1     dB
! Stop Atten  = 60    dB
! fout        = 12000 Hz

  parameter (NTAPS=37)
  parameter (NH=NTAPS/2)
  parameter (NDOWN=4)             !Downsample ratio
  integer*2 id1(n1)
  integer*2 id2(*)

! Filter coefficients:
  real a(-NH:NH)
  data a/                                                                 &
        0.001377395235, 0.002852158900, 0.004767882543, 0.006240206517,   &
        0.006191755970, 0.003553573051,-0.002243564850,-0.010770446408,   &
       -0.020288158399,-0.027822309390,-0.029710933359,-0.022547471263,   &
       -0.004298056801, 0.024769757851, 0.061669077060, 0.101014185634,   &
        0.136070596894, 0.160295785231, 0.168947734090, 0.160295785231,   &
        0.136070596894, 0.101014185634, 0.061669077060, 0.024769757851,   &
       -0.004298056801,-0.022547471263,-0.029710933359,-0.027822309390,   &
       -0.020288158399,-0.010770446408,-0.002243564850, 0.003553573051,   &
        0.006191755970, 0.006240206517, 0.004767882543, 0.002852158900,   &
        0.001377395235/

  n2=(n1-NTAPS+NDOWN)/NDOWN
  k0=NH-NDOWN+1

! Loop over all output samples
  do i=1,n2
     s=0.
     k=k0 + NDOWN*i
     do j=-NH,NH
        s=s + id1(j+k)*a(j)
     enddo
     id2(i)=nint(s)
  enddo

  return
end subroutine fil1
