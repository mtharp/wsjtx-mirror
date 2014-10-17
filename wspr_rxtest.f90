!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propagation Reporter
!
! File Name:    wspr_rxtest.f90
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
program wspr_rxtest

  character arg*8
  include 'acom1.f90'

  nargs=iargc()
  if(nargs.ne.1 .and. nargs.ne.5) then
     print*,'Usage: wspr_rxtest infile [...]'
     print*,'       wspr_rxtest selftest txdf fdot snr iters'
     go to 999
  endif

  call getarg(1,arg)
  if(arg.eq.'selftest') then
     call getarg(2,arg)
     read(arg,*) ntxdf
     call getarg(3,arg)
     read(arg,*) fdot
     call getarg(4,arg)
     read(arg,*) snrdb
     call getarg(5,arg)
     read(arg,*) iters
     do iter=1,iters
!###        call genmept('K1JT        ','FN20',30,ntxdf,snrdb,iwave)
        call decode
     enddo
     go to 999

  else
     ltest=.true.
     do ifile=1,nargs
        call getarg(ifile,infile)
        len=80
        call getfile(infile,80)
        call decode
     enddo
  endif

999 end program wspr_rxtest

subroutine msleep(n)
  return
end subroutine msleep
