!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    read_wav.f90
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
subroutine read_wav(lu,idat,npts,nfsample,nchan)

! Write a wavefile to logical unit lu.

  integer*2 idat(*)
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  integer*1 hdr(44)
  common/hdr/ariff,nchunk,awave,afmt,lenfmt,nfmt2,nchan2,nsamrate,   &
       nbytesec,nbytesam2,nbitsam2,adata,ndata
  equivalence (hdr,ariff)

  read(lu) hdr
  npts=ndata/(nchan2*nbitsam2/8)
  nfsample=nsamrate
  nchan=nchan2
  read(lu) (idat(i),i=1,npts*nchan)

  return
end subroutine read_wav
