!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    thnix.f90
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
subroutine cs_init
  character*12 csub0
  integer*8 mtx
  common/mtxcom/mtx,ltrace,mtxstate,csub0
  ltrace=0
  mtxstate=0
  csub0='**unlocked**'
  call fthread_mutex_init(mtx)
  return
end subroutine cs_init

subroutine cs_destroy
  character*12 csub0
  integer*8 mtx
  common/mtxcom/mtx,ltrace,mtxstate,csub0
  call fthread_mutex_destroy(mtx)
  return
end subroutine cs_destroy

subroutine th_create(sub)
  call fthread_create(sub,id)
  return
end subroutine th_create

subroutine th_exit
  call fthread_exit
  return
end subroutine th_exit

subroutine cs_lock(csub)
  character*(*) csub
  character*12 csub0
  integer fthread_mutex_lock,fthread_mutex_trylock
  integer*8 mtx
  common/mtxcom/mtx,ltrace,mtxstate,csub0
  n=fthread_mutex_trylock(mtx)
  if(n.ne.0) then
! Another thread has already locked the mutex
     n=fthread_mutex_lock(mtx)
     iz=index(csub0,' ')
     if(ltrace.ge.1) print*,'"',csub,'" requested mutex when "',   &
          csub0(:iz-1),'" owned it.'
  endif
  mtxstate=1
  csub0=csub
  if(ltrace.ge.3) print*,'Mutex locked by ',csub
  return
end subroutine cs_lock

subroutine cs_unlock
  character*12 csub0
  integer*8 mtx
  common/mtxcom/mtx,ltrace,mtxstate,csub0
  if(ltrace.ge.3) print*,'Mutex unlocked,',ltrace,mtx,mtxstate,csub0
  mtxstate=0
  call fthread_mutex_unlock(mtx)
  return
end subroutine cs_unlock
