!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    spec162.f90
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
subroutine spec162(c2,jz,appdir,nappdir)

  parameter(NX=500,NY=160)
  complex c2(65536)
  complex c(0:255)
  character*80 appdir,pixmap
  real s(120,0:255)
  real ss(0:255)
  real w(0:255)
  real savg(0:255)
  integer*2 a(NX,NY)
  common/bcom/ntransmitted
  common/fftcom/c       !This keeps the absolute address of c() constant

  nfft=256
  twopi=6.2831853
  pi=0.5*twopi
  do i=0,nfft-1
     w(i)=sin(i*pi/nfft)
  enddo

  nadd=9
  s=0.
  save=0.
  istep=nfft/2
  nsteps=(jz-nfft)/(nadd*istep)
  pixmap=appdir(:nappdir)//'/pixmap.dat'

  call cs_lock('spec162')
  open(16,file=pixmap,access='stream',status='unknown',err=1)
  read(16,end=1) a
  go to 2
1 a=0.

2 nmove=nsteps+1
  call cs_unlock

  do j=1,NY                 !Move waterfall left
     do i=1,NX-nmove
        a(i,j)=a(i+nmove,j)
     enddo
     a(NX-nmove+1,j)=255*ntransmitted
  enddo
  ntransmitted=0

  i0=-istep+1
  k=0
  do n=1,nsteps
     k=k+1
     ss=0.
     do m=1,nadd
        i0=i0+istep
        do i=0,nfft-1
           c(i)=w(i)*c2(i0+i)
        enddo
        call four2a(c,nfft,1,-1,1)
        do i=0,nfft-1
           sq=real(c(i))**2 + imag(c(i))**2
           ss(i)=ss(i) + sq
           savg(i)=savg(i) + sq
        enddo
     enddo
     call flat3(ss,256,nadd)
     do i=0,nfft-1
        s(k,i)=ss(i)
     enddo
  enddo
  kz=k

  gain=40
  offset=-90.
  fac=20.0/nadd

  do k=1,kz
     j=k-kz+NX
     do i=-80,-1
        x=fac*s(k,i+nfft)
        n=0
        if(x.gt.0.0) n=gain*log10(x) + offset
        n=min(252,max(0,n))
        a(j,NY-i-80)=n
     enddo
     do i=0,79
        x=fac*s(k,i)
        n=0
        if(x.gt.0.0) n=gain*log10(x) + offset
        n=min(252,max(0,n))
        a(j,NY-i-80)=n
     enddo
  enddo

  call cs_lock('spec162')
  rewind 16
  write(16) a
  close(16)
  call cs_unlock

  return
end subroutine spec162
