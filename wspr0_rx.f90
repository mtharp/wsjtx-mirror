!-------------------------------------------------------------------------------
!
! This file is part of the WSPR0 application, Command-Line WSPR0
!
! File Name:    wspr0_rx.f90
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
subroutine wspr0_rx(ntrminutes,nrxtx,nfiles,f0)

  parameter (NMAX=900*12000)                          !Max length of waveform
  integer*2 iwave(NMAX)                               !Generated waveform
  integer*1 i1
  integer*1 hdr(44)
  integer npr3(162)
  integer soundin
  real*8 f0
  character*80 infile,appdir,thisfile
  character*6 cfile6,cdate*8,utctime*10
  equivalence(i1,i4)
  data appdir/'.'/,nappdir/1/,minsync/1/,nbfo/1500/
  data npr3/                                          &
      1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0,        &
      0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1,        &
      0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1,        &
      1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1,        &
      0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0,        &
      0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1,        &
      0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1,        &
      0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0,        &
      0,0/

  data nsec0/999999/
  save

  nargs=iargc()
  if(nrxtx.eq.1) ifile1=nargs-nfiles+1
  npts=(60*ntrminutes-6)*12000
  nz=60*ntrminutes*12000

  if(nfiles.ge.1) then
     do ifile=ifile1,nargs
        call getarg(ifile,infile)
        open(10,file=infile,access='stream',status='old')
        read(10) hdr
        read(10) (iwave(i),i=1,npts)
        close(10)
        cfile6=infile
        i1=index(infile,'.')
        if(i1.ge.2) then
           i0=max(1,i1-4)
           cfile6=infile(i0:i1-1)
        endif
        call getrms(iwave,npts,ave,rms)
        call mept162(infile,appdir,nappdir,f0,1,iwave,nz,nbfo,ierr)
     enddo
  else
20   nsec=time()
     isec=mod(nsec,86400)
!     ih=isec/3600
!     im=(isec-ih*3600)/60
!     is=mod(isec,60)
     is120=mod(isec,120)
     if(is120.eq.0) then
        call getutc(cdate,utctime,tsec)
        thisfile=cdate(3:8)//'_'//utctime(1:4)//'.'//'wav'
        ierr=soundin(-1,12000,iwave,114*12000,0)
!        npts=114*12000
        call getrms(iwave,npts,ave,rms)
        call mept162(thisfile,appdir,nappdir,f0,1,iwave,nz,nbfo,ierr)
        if(nrxtx.ne.1) go to 999
     endif
     call msleep(100)
     go to 20
  endif
      
999 return
end subroutine wspr0_rx
