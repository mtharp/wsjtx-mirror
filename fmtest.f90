!-------------------------------------------------------------------------------
!
! This file is part of the WSPR application, Weak Signal Propogation Reporter
!
! File Name:    fmtest.f90
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
program fmtest

! Conduct measurements for ARRL Frequency Measuring Test, etc.

  parameter (NMAX=600*48000)                 !Max length of 48 kHz waveform
  parameter (NMAX2=NMAX/4)                   !Max length at 12 kHz
  parameter (NFFT=65536)
  parameter (NH=NFFT/2)
  parameter (NQ=NFFT/4)

  integer*2 kwave(NMAX)                      !Raw data samples at 48 kHz
  integer*2 iwave(NMAX2)                     !Downsampled data, 12 kHz
  character arg*12                           !Command-line arg
  character callsign*6
  character cmnd*120                         !Command to set rig frequency
  character cflag*1
  real x(NFFT)                               !Real data for FFT
  real w(NFFT)                               !Window function
  complex c(0:NH-1)                          !Complex FFT result
  real s(NQ)                                !Power spectrum
  integer time,soundin                       !External functions
  equivalence (x,c)

  nargs=iargc()
  if(nargs.ne.6) then
     print*,'Usage:   fmtest <kHz> <0|1> <offset> <range> <tsec> <call>'
     print*,'Example: fmtest 10000   1    1500     100      30    WWV'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) nkhz                     !Nominal frequency to be measured (kHz)
  call getarg(2,arg)
  read(arg,*) ncal                     !1=CAL, 0=to be measured
  call getarg(3,arg)
  read(arg,*) noffset                  !Offset (Hz)
  call getarg(4,arg)
  read(arg,*) nrange                   !Search range (Hz)
  call getarg(5,arg)
  read(arg,*) ntsec                    !Length of measurement (s)
  call getarg(6,callsign)

  open(10,file='fmt.ini',status='old',err=910)
  read(10,'(a120)') cmnd              !Get rigctl command to set frequency
  read(10,*) ndevin
  close(10)
  open(12,file='fmt.out',status='unknown')
  open(13,file='fmt.all',status='unknown',position='append')

  nHz=1000*nkhz - noffset
  i1=index(cmnd,' F ')
  write(cmnd(i1+2:),*) nHz            !Insert the desired frequency
  iret=system(cmnd)
  if(iret.ne.0) then
     print*,'Error executing rigctl command to set frequency:'
     print*,cmnd
     go to 999
  endif

  df=12000.d0/NFFT
  do i=1,NFFT
     w(i)=sin(i*3.14159/NFFT)
  enddo

  write(*,1000)
1000 format(                                                              &
     '   UTC     Freq CAL Offset  fMeas        DF    Level   S/N  Call'/   &
     '          (kHz)  ?   (Hz)    (Hz)       (Hz)    (dB)  (dB)      '/   &
     '------------------------------------------------------------------')

  call soundinit                             !Initialize Portaudio

  npts=ntsec*48000
  iqmode=0
  nsec0=mod(time(),86400)
  ierr=soundin(ndevin,48000,kwave,npts,iqmode)  !Get audio data, 48 kHz rate
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif
  call fil1(kwave,npts,iwave,n2)          !Filter and downsample to 12 kHz

  nrpt=n2/NH - 1
  fac=1.0/float(NFFT)**2
  ia=(noffset-nrange)/df
  ib=(noffset+nrange)/df

  do irpt=0,nrpt
     k=irpt*NH
     t0=nsec0 + k/12000.0
     do i=1,NFFT
        k=k+1
        if(k.gt.NMAX2) go to 999
        x(i)=w(i)*iwave(k)
     enddo

     call four2a(x,NFFT,1,-1,0)              !Compute spectrum
     do i=1,nq
        s(i)=fac * (real(c(i))**2 + aimag(c(i))**2)
     enddo
  
     smax=0.
     ipk=ib                                  !Silence compiler warning
     do i=ia,ib                              !Find fpeak
        if(s(i).gt.smax) then
           smax=s(i)
           ipk=i
        endif
     enddo

     call peakup(s(ipk-1),s(ipk),s(ipk+1),dx)
     fpeak=df * (ipk+dx)

     sum=0.
     nsum=0
     do i=ia,ib
        if(abs(i-ipk).gt.10) then
           sum=sum+s(i)
           nsum=nsum+1
        endif
     enddo
     ave=sum/nsum

     n=nint(mod(t0,86400.0))
     nhr=n/3600
     nmin=mod(n/60,60)
     nsec=mod(n,60)
     pave=db(ave) + 8.0
     snr=db(smax/ave)
     ferr=fpeak-noffset
     cflag=' '
     if(snr.lt.20.0) cflag='*'
     write(*,1100)  nhr,nmin,nsec,nkhz,ncal,noffset,fpeak,ferr,pave,   &
          snr,callsign,cflag
     write(12,1100) nhr,nmin,nsec,nkhz,ncal,noffset,fpeak,ferr,pave,   &
          snr,callsign,cflag
     write(13,1100) nhr,nmin,nsec,nkhz,ncal,noffset,fpeak,ferr,pave,   &
          snr,callsign,cflag
1100 format(i2.2,':',i2.2,':',i2.2,i7,i3,i6,2f10.3,2f7.1,2x,a6,2x,a1)
     call flush(12)
     call flush(13)
  enddo
  go to 999

910 print*,'Cannot open file: fmt.ini'

999 end program fmtest

