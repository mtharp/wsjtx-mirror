!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    getfile.f90
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
subroutine getfile(fname,len)
!f2py threadsafe

  character*(*) fname
  include 'acom1.f90'
  integer*1 hdr(44),n1
  integer*2 nfmt2,nchan2,nbitsam2,nbytesam2
  character*4 ariff,awave,afmt,adata
  common/hdr/ariff,lenfile,awave,afmt,lenfmt,nfmt2,nchan2, &
     nsamrate,nbytesec,nbytesam2,nbitsam2,adata,ndata,d2
  equivalence (ariff,hdr),(n1,n4),(d1,d2)

1 if(ndecoding.eq.0) go to 2
  call msleep(100)
  go to 1

!2 ndecoding=1
2  do i=len,1,-1
     if(fname(i:i).eq.'/' .or. fname(i:i).eq.'\\') go to 10
  enddo
  i=0
10  continue
  call cs_lock('getfile')
  open(10,file=fname,access='stream',status='old')
  read(10) hdr
  npts=114*12000
  if(ntrminutes.eq.15) npts=890*12000
  read(10) (iwave(i),i=1,npts)
  close(10)
  n4=1
  if (n1.eq.1) goto 8                     !skip byteswap if little endian
  do i=1,npts
     i4 = iwave(i)
     iwave(i) = ishft(iand(i4,255),8) +  iand(ishft(i4,-8),255)
  enddo    
8 call getrms(iwave,npts,ave,rms)
  ndecdone=0                              !??? ### ???
  ndiskdat=1
  outfile=fname
  nrxdone=1
  call cs_unlock

  return
end subroutine getfile
