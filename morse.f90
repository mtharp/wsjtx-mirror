!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    morse.f90
! Description:  Convert ASCII message to a Morse code bit string.
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
subroutine morse(msg,idat,n)

! Convert ascii message to a Morse code bit string.
!    Dash = 3 dots
!    Space between dots, dashes = 1 dot
!    Space between letters = 3 dots
!    Space between words = 7 dots

  character*22 msg
  integer*1 idat(460)
  integer*1 ic(21,38)
  data ic/                                         &
       1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,20, &
       1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,0,18, &
       1,0,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0,16, &
       1,0,1,0,1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,14, &
       1,0,1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,12, &
       1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10, &
       1,1,1,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,12, &
       1,1,1,0,1,1,1,0,1,0,1,0,1,0,0,0,0,0,0,0,14, &
       1,1,1,0,1,1,1,0,1,1,1,0,1,0,1,0,0,0,0,0,16, &
       1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,0,0,0,18, &
       1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 6, &
       1,1,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10, &
       1,1,1,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,12, &
       1,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8, &
       1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 2, &
       1,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10, &
       1,1,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10, &
       1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8, &
       1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 4, &
       1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,14, &
       1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,10, &
       1,0,1,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,10, &
       1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8, &
       1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 6, &
       1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,12, &
       1,0,1,1,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,12, &
       1,1,1,0,1,1,1,0,1,0,1,1,1,0,0,0,0,0,0,0,14, &
       1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8, &
       1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 6, &
       1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 4, &
       1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0, 8, &
       1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,10, &
       1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,10, &
       1,1,1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,12, &
       1,1,1,0,1,0,1,1,1,0,1,1,1,0,0,0,0,0,0,0,14, &
       1,1,1,0,1,1,1,0,1,0,1,0,0,0,0,0,0,0,0,0,12, &
       1,1,1,0,1,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,14, &
       0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 2/   !Incremental word space
  save

! Find length of message
  do i=22,1,-1
     if(msg(i:i).ne.' ') go to 1
  enddo
1 msglen=i

  n=0
  do k=1,msglen
     jj=ichar(msg(k:k))
     if(jj.ge.97 .and. jj.le.122) jj=jj-32  !Convert lower to upper case
     if(jj.ge.48 .and. jj.le.57) j=jj-48    !Numbers
     if(jj.ge.65 .and. jj.le.90) j=jj-55    !Letters
     if(jj.eq.47) j=36                      !Slash (/)
     if(jj.eq.32) j=37                      !Word space
     j=j+1

! Insert this character
     nmax=ic(21,j)
     do i=1,nmax
        n=n+1
        idat(n)=ic(i,j)
     enddo

! Insert character space of 2 dit lengths:
     n=n+1
     idat(n)=0
     n=n+1
     idat(n)=0
  enddo

! Insert word space at end of message
  do j=1,4
     n=n+1
     idat(n)=0
  enddo

  return
end subroutine morse
