!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    packcall.f90
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
subroutine packcall(callsign,ncall,text)

! Pack a valid callsign into a 28-bit integer.

  parameter (NBASE=37*36*10*27*27*27)
  character callsign*6,c*1,tmp*6,digit*10
  logical text
  data digit/'0123456789'/

  text=.false.

! Work-around for Swaziland prefix:
  if(callsign(1:4).eq.'3DA0') callsign='3D0'//callsign(5:6)

  if(callsign(1:3).eq.'CQ ') then
     ncall=NBASE + 1
     if(callsign(4:4).ge.'0' .and. callsign(4:4).le.'9' .and.       &
          callsign(5:5).ge.'0' .and. callsign(5:5).le.'9' .and.     &
          callsign(6:6).ge.'0' .and. callsign(6:6).le.'9') then
        nfreq=100*(ichar(callsign(4:4))-48) +                       &
             10*(ichar(callsign(5:5))-48) +                         &
             ichar(callsign(6:6))-48
        ncall=NBASE + 3 + nfreq
     endif
     return
  else if(callsign(1:4).eq.'QRZ ') then
     ncall=NBASE + 2
     return
  endif

  tmp='      '
  if(callsign(3:3).ge.'0' .and. callsign(3:3).le.'9') then
     tmp=callsign
  else if(callsign(2:2).ge.'0' .and. callsign(2:2).le.'9') then
     if(callsign(6:6).ne.' ') then
        text=.true.
        return
     endif
     tmp=' '//callsign
  else
     text=.true.
     return
  endif

  do i=1,6
     c=tmp(i:i)
     if(c.ge.'a' .and. c.le.'z')                             &
          tmp(i:i)=char(ichar(c)-ichar('a')+ichar('A'))
  enddo

  n1=0
  if((tmp(1:1).ge.'A'.and.tmp(1:1).le.'Z').or.tmp(1:1).eq.' ') n1=1
  if(tmp(1:1).ge.'0' .and. tmp(1:1).le.'9') n1=1
  n2=0
  if(tmp(2:2).ge.'A' .and. tmp(2:2).le.'Z') n2=1
  if(tmp(2:2).ge.'0' .and. tmp(2:2).le.'9') n2=1
  n3=0
  if(tmp(3:3).ge.'0' .and. tmp(3:3).le.'9') n3=1
  n4=0
  if((tmp(4:4).ge.'A'.and.tmp(4:4).le.'Z').or.tmp(4:4).eq.' ') n4=1
  n5=0
  if((tmp(5:5).ge.'A'.and.tmp(5:5).le.'Z').or.tmp(5:5).eq.' ') n5=1
  n6=0
  if((tmp(6:6).ge.'A'.and.tmp(6:6).le.'Z').or.tmp(6:6).eq.' ') n6=1

  if(n1+n2+n3+n4+n5+n6 .ne. 6) then
     text=.true.
     return 
  endif

  ncall=nchar(tmp(1:1))
  ncall=36*ncall+nchar(tmp(2:2))
  ncall=10*ncall+nchar(tmp(3:3))
  ncall=27*ncall+nchar(tmp(4:4))-10
  ncall=27*ncall+nchar(tmp(5:5))-10
  ncall=27*ncall+nchar(tmp(6:6))-10

  return
end subroutine packcall
