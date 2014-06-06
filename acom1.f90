!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    acom1.f90
! Description:
!
! Copyright (C) 2001-2014 Joseph Taylor, K1JT
! License: GNU GPL v3+
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
  parameter (NMAX=120*12000)                          !Max length of waveform
  parameter (NZ=2*120*48000)
  real*8 f0,f0a,f0b,ftx,tsec0
  logical ltest,receiving,transmitting
  character*80 infile,outfile,pttport,thisfile
  character cdate*8,utctime*10,rxtime*4,catport*12
  character pttmode*3,appdir*80,chs*40
  character callsign*12,grid*4,grid6*6,ctxmsg*22,sending*22
  integer*2 iwave,kwave
  common/acom1/ f0,f0a,f0b,ftx,tsec0,rms,pctx,igrid6,nsec,ndevin,      &
       nfhopping,nfhopok,iband,ncoord,ntrminutes,                      &
       ndevout,nsave,nrxdone,ndbm,nport,ndec,ndecdone,ntxdone,         &
       idint,ndiskdat,ndecoding,ntr,nbaud,ndatabits,nstopbits,         &
       receiving,transmitting,nrig,nappdir,iqmode,iqrx,iqtx,nfiq,      &
       ndebug,idevin,idevout,nsectx,nbfo,iqrxapp,                      &
       ntxdb,txbal,txpha,iwrite,newdat,iqrxadj,gain,phase,reject,      &
       ntxfirst,ntest,ncat,ltest,iwave(NMAX),kwave(NZ),idle,ntune,     &
       ntxnext,nstoptx,ncal,ndevsok,nsec1,nsec2,xdb1,xdb2,             &
       infile,outfile,pttport,cdate,utctime,callsign,grid,grid6,       &
       rxtime,ctxmsg,sending,thisfile,pttmode,catport,appdir,chs
