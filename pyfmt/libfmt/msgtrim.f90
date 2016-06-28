!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    msgtrim.f90
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
subroutine msgtrim(msg,msglen)

  character*24 msg

! Remove leading blanks
  do i=1,24
     if(msg(1:1).ne.' ') go to 2
     msg=msg(2:)
  enddo
  go to 800                                  !Error return

2 do i=24,1,-1
     if(msg(i:i).ne.' ') go to 3
  enddo
  go to 800
3 iz=i

! Collapse multiple blanks to one
  ib2=index(msg,'  ')
  if(ib2.eq.0 .or. ib2.eq.iz+1) go to 10
  msg=msg(:ib2-1)//msg(ib2+1:)
  iz=iz-1
  go to 2

! Convert letters to upper case
10 do i=1,22
     if(msg(i:i).ge.'a' .and. msg(i:i).le.'z')                      &
          msg(i:i)= char(ichar(msg(i:i))+ichar('A')-ichar('a'))
  enddo

  do i=24,1,-1
     if(msg(i:i).ne.' ') go to 20
  enddo
  go to 800                                  !Error return

20  msglen=i
  go to 999

800 continue
!  print*,'Error in msgtrim: ',msg

999 return
end subroutine msgtrim
