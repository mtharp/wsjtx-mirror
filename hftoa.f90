!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    hftoa.f90
! Description:  Record soundcard data for HF Time-of-Arrival
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
program hftoa

! Record soundcard data for HF Time-of-Arrival project.

  parameter (NMAX=300*48000)                 !Max length of data
  integer*2 id1(NMAX)                        !Raw data, 48 kHz
  integer*2 id2(NMAX/4)                      !Downsampled data, 12 kHz
  character arg*12                           !Command-line arg
  character label*7                          !Label for filename
  character cdate*8                          !CCYYMMDD
  character ctime*10                         !HHMMSS.SSS
  character start_time*4                     !Requested start time (HHMM)
  character outfile*40                       !Output filename
  character cmnd*120                         !Command to set rig frequency
  character*4 mode
  character*6 mycall,mygrid
  real*8 fkhz,tsec
  integer soundin

  nargs=iargc()
  if(nargs.ne.1 .and. nargs.ne.4) then
     print*,'Usage:   hftoa <f_kHz> <mode> <nsec> <tstart>'
     print*,'Example: hftoa   3990    AM     300    2100'
     go to 999
  endif

  call getarg(1,arg)
  if(arg(:2).eq.'-v') then
     print*,'Version 1.00'
     go to 999
  else
     read(arg,*) fkhz                     !Rx frequency (kHz)
     call getarg(2,mode)                  !Rx mode, e.g. AM, USB, LSB
     call getarg(3,arg)
     read(arg,*) nsec                     !Duration of recording (s)
     call getarg(4,arg)
     read(arg,*) start_time               !Start time (HHMM)
  endif

  nfsample=48000
  ndown=4

  open(10,file='fmt.ini',status='old',err=910)
  read(10,'(a120)') cmnd              !Get rigctl command to set frequency
  read(10,*) ndevin
  read(10,*) mycall
  read(10,*) mygrid
  close(10)

  if(cmnd(:6).eq.'rigctl') then
     nHz=nint(1000.d0*fkhz)
     i1=index(cmnd,' F ')
     write(cmnd(i1+2:),*) nHz                   !Insert desired frequency
     iret=system(cmnd)                          !Set Rx frequency
     if(iret.ne.0) then
        print*,'Error executing rigctl command to set frequency:'
        print*,cmnd
        go to 999
     endif

     if(mode.eq.'am  ') mode='AM  '
     if(mode.eq.'usb ') mode='USB '
     if(mode.eq.'lsb ') mode='LSB '
     cmnd(i1+1:)='M '//mode//' 0'
     iret=system(cmnd)                          !Set Rx mode
     if(iret.ne.0) then
        print*,'Error executing rigctl command to set Rx mode:'
        print*,cmnd
        go to 999
     endif
  endif

  nchan=1

  call soundinit                             !Initialize Portaudio

  call getutc(cdate,ctime,tsec)
  if(start_time(1:1).ne.'-') then
     do while (ctime(1:4).ne.start_time)
        call getutc(cdate,ctime,tsec)
        call msleep(100)
     enddo
  endif

  label=mycall
  label(7:7)=' '
  i1=index(label,' ')
  outfile=label(1:i1-1)//'_'//cdate(3:8)//'_'//ctime(:6)//'.wav'
  open(12,file=outfile,access='stream',status='unknown')
  write(*,1010) cdate,ctime
1010 format('UTC start time: ',a8,1x,a10)

  npts=nfsample*nsec
  ierr=soundin(ndevin,nfsample,id1,npts,nchan-1)   !Get audio data
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif

  if(ndown.eq.4) then
     call fil1(id1,npts,id2,ntot)                     !Downsample by 1/4
     nfsample=nfsample/4
  endif

  call write_wav(12,id2,ntot,nfsample,nchan)          !Write wav file to disk
  write(12) tsec,fkhz,mycall,mygrid,mode,ctime,cdate  !Append header info

  sum=0.
  xmax1=0.
  do i=1,ntot
     x=id2(i)
     sum=sum + x
     xmax1=max(xmax1,abs(x))
  enddo
  ave1=sum/ntot
  sq=0.
  do i=1,ntot
     x=id2(i)-ave1
     sq=sq + x*x
  enddo
  rms1=sqrt(sq/(ntot-1))

  write(*,1100) ave1,rms1,xmax1
1100 format('Ave:',f8.1,'   Rms:',f8.1,'   Max:',f8.1)
  go to 999

910 print*,'Cannot open file: fmt.ini'

999 end program hftoa

