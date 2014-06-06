!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    write_wav.f90
! Description:  Write a wavefile to logical unit lu
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
subroutine write_wav(lu,idat,ntot,nfsample,nchan)

! Write a wavefile to logical unit lu.

  integer*2 idat(ntot)
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  integer*1 hdr(44)
  common/hdr/ariff,nchunk,awave,afmt,lenfmt,nfmt2,nchan2,nsamrate,   &
       nbytesec,nbytesam2,nbitsam2,adata,ndata
  equivalence (hdr,ariff)

! Generate header
  ariff='RIFF'
  awave='WAVE'
  afmt='fmt '
  adata='data'
  lenfmt=16                             !Rest of this sub-chunk is 16 bytes long
  nfmt2=1                               !PCM = 1
  nchan2=nchan                          !1=mono, 2=stereo
  nbitsam2=16                           !Bits per sample
  nsamrate=nfsample                     !Sample rate
  nbytesec=nfsample*nchan2*nbitsam2/8   !Bytes per second
  nbytesam2=nchan2*nbitsam2/8           !Block-align               
  ndata=ntot*nbitsam2/8
  nbytes=ndata+44
  nchunk=nbytes-8

  write(lu) hdr
  write(lu) idat

  return
end subroutine write_wav
