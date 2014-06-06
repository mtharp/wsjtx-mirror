!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    wfile5.f90
! Description:  Write a wavefile to disk
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
subroutine wfile5(iwave,nmax,nfsample,outfile)

! Write a wavefile to disk.

  integer*1 n4 
  integer*2 iwave(nmax)
  character*80 outfile

  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  integer*1 hdr(44)
  integer*2 iswap_short
  common/hdr/ariff,nchunk,awave,afmt,lenfmt,nfmt2,nchan2,         &
       nsamrate,nbytesec,nbytesam2,nbitsam2,adata,ndata
  equivalence (hdr,ariff),(nfmt2,n4)

! Generate the header
  ariff='RIFF'
  awave='WAVE'
  afmt='fmt '
  adata='data'
  lenfmt=16                             !Rest of this sub-chunk is 16 bytes long
  nfmt2=1                               !PCM = 1
  nchan2=1                              !1=mono, 2=stereo
  nbitsam2=16                           !Bits per sample
  nsamrate=nfsample
  nbytesec=nfsample*nchan2*nbitsam2/8   !Bytes per second
  nbytesam2=nchan2*nbitsam2/8           !Block-align               
  ndata=nmax*nchan2*nbitsam2/8
  nbytes=ndata+44
  nchunk=nbytes-8

  call cs_lock('wfile5')
  open(12,file=outfile,access='stream',status='unknown')
  if (n4.ne.nfmt2) then
     call change_endian                  !Change hdr to little-endian
     do i=1,nmax
        iwave(i) = iswap_short(iwave(i))!Change data to little-endian
     enddo
  endif
  write(12) hdr
  write(12) iwave
  close(12)
  call cs_unlock

  return
end subroutine wfile5

subroutine change_endian

  integer*1 hdr(44)
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  integer*2 iswap_short
  character*4 ariff,awave,afmt,adata
  common/hdr/ariff,nchunk,awave,afmt,lenfmt,nfmt2,nchan2,        &
       nsamrate,nbytesec,nbytesam2,nbitsam2,adata,ndata
  equivalence (ariff,hdr)

  nchunk = iswap_int(nchunk)
  lenfmt = iswap_int(lenfmt)
  nfmt2 = iswap_short(nfmt2)
  nchan2 = iswap_short(nchan2)
  nsamrate = iswap_int(nsamrate)
  nbytesec = iswap_int(nbytesec)
  nbytesam2 = iswap_short(nbytesam2)
  nbitsam2 = iswap_short(nbitsam2)
  ndata = iswap_int(ndata)

  return
end subroutine change_endian

integer function iswap_int(idat)

  itemp1 = ior(ishft(idat,24), iand(ishft(idat,8), z'00ff0000'))
  itemp0 = ior(iand(ishft(idat,-8), z'0000ff00'),                   &
       iand(ishft(idat,-24),z'000000ff'))
  iswap_int = ior(itemp1,itemp0)
      
end function iswap_int

integer*2 function iswap_short(idat)

  integer*2 idat,m2
  data m2/255/

  iswap_short = ior(ishft(idat,8), iand(ishft(idat,-8), m2))

end function iswap_short

