!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    wqencode.f90
! Description:  Parse and encode a WSPR message
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
subroutine wqencode(msg,ntype,data0)

!  Parse and encode a WSPR message.

  parameter (MASK15=32767)
  character*22 msg
  character*12 call1,call2
  character grid4*4,grid6*6
  logical lbad1,lbad2
  integer*1 data0(11)
  integer nu(0:9)
  data nu/0,-1,1,0,-1,2,1,0,-1,1/

  call cs_lock('wqencode')
! Standard WSPR message (types 0 3 7 10 13 17 ... 60)
  i1=index(msg,' ')
  i2=index(msg,'/')
  i3=index(msg,'<')
  call1=msg(:i1-1)
  if(i1.lt.3 .or. i1.gt.7 .or. i2.gt.0 .or. i3.gt.0) go to 10
  grid4=msg(i1+1:i1+4)
  call packcall(call1,n1,lbad1)
  call packgrid(grid4,ng,lbad2)
  if(lbad1 .or. lbad2) go to 10
  ndbm=0
  read(msg(i1+5:),*) ndbm
  if(ndbm.lt.0) ndbm=0
  if(ndbm.gt.60) ndbm=60
  ndbm=ndbm+nu(mod(ndbm,10))
  n2=128*ng + (ndbm+64)
  call pack50(n1,n2,data0)
  ntype=ndbm
  go to 900

10 if(i2.ge.2 .and. i3.lt.1) then
     call packpfx(call1,n1,ng,nadd)
     ndbm=0
     read(msg(i1+1:),*) ndbm
     if(ndbm.lt.0) ndbm=0
     if(ndbm.gt.60) ndbm=60
     ndbm=ndbm+nu(mod(ndbm,10))
     ntype=ndbm + 1 + nadd
     n2=128*ng + ntype + 64
     call pack50(n1,n2,data0)
  else if(i3.eq.1) then
     i4=index(msg,'>')
     call1=msg(2:i4-1)
     call hash(call1,i4-2,ih)
     grid6=msg(i1+1:i1+6)
     call2=grid6(2:6)//grid6(1:1)//'      '
     call packcall(call2,n1,lbad1)
     ndbm=0
     read(msg(i1+8:),*) ndbm
     if(ndbm.lt.0) ndbm=0
     if(ndbm.gt.60) ndbm=60
     ndbm=ndbm+nu(mod(ndbm,10))
     ntype=-(ndbm+1)
     n2=128*ih + ntype + 64
     call pack50(n1,n2,data0)
  endif
  go to 900

900 continue
  call cs_unlock
  return
end subroutine wqencode
