!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    gencwid.f90
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
subroutine gencwid(msg,wpm0,freqcw,iwave,nwave)

  parameter (NMAX=5*48000)
  character msg*22,msg2*22
  integer*2 iwave(NMAX)

  integer*1 idat(460)
  real*8 dt,t,twopi,pha,dpha,tdit
  data twopi/6.283185307d0/

  do i=1,22
     if(msg(i:i).eq.' ') go to 10
  enddo
10 iz=i-1
  msg2=msg(1:iz)//'                      '
  call morse(msg2,idat,ndits) !Encode part 1 of msg
  nwave=4.5*48000
  dt=1.d0/48000.d0
  wpm=1.2*ndits/(nwave*dt)
  if(wpm.lt.wpm0) wpm=wpm0
  tdit=1.2d0/wpm                   !Key-down dit time, seconds
  nwave=ndits*tdit/dt
  pha=0.
  dpha=twopi*freqcw*dt
  t=0.d0
  s=0.
  u=wpm/(48000.0*0.03)
  do i=1,nwave
     t=t+dt
     pha=pha+dpha
     j=t/tdit + 1
     s=s + u*(idat(j)-s)
     iwave(i)=nint(s*32767.d0*sin(pha))
  enddo

  return
end subroutine gencwid

