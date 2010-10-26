program fmt

! Conduct measurements for ARRL Frequency Measuring Test, etc.

  parameter (NZ1=131072)                     !Max length of 12000 Hz waveform
  parameter (NZ4=4*NZ1)                      !Ditto at 48000 Hz
  integer*2 kwave(NZ4)                       !Raw data samples at 48 kHz
  integer*2 iwave(NZ1)                       !Downsampled data, 12 kHz
  character arg*12                           !Command-line arg
  character cmnd*120                         !Command to set rig frequency
  real x(NZ1)                                !Real data for FFT
  complex c(0:NZ1/2-1)                       !Complex FFT result
  real s1(NZ1/4)                             !Power spectrum
!  real*8 s,sq
  integer time
  integer soundin                            !External, calls portaudio
  equivalence (x,c)

  nargs=iargc()
  if(nargs.lt.2) then
     print*,'Usage: fmt kHz offset [nrpt]'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) nkhz                     !Nominal frequency to be measured (kHz)
  call getarg(2,arg)
  read(arg,*) noffset                  !Offset (Hz)
  nrpt=9999999
  if(nargs.ge.3) then
     call getarg(3,arg)
     read(arg,*) nrpt                  !Number of 64k blocks to be measured
  endif

  open(10,file='fmt.ini',status='old',err=910)
  read(10,'(a120)') cmnd              !Get rigctl command to set frequency
  read(10,*) ndevin
  close(10)
  nHz=1000*nkhz - noffset
  i1=index(cmnd,' F ')
  write(cmnd(i1+2:),*) nHz            !Insert the desired frequency
  iret=system(cmnd)
  if(iret.ne.0) then
     print*,'Error executing rigctl command to set frequency:'
     print*,cmnd
     go to 999
  endif

  nfft=65536
  df=12000.d0/nfft

  open(12,file='fmt.out',status='unknown')
  open(13,file='fmt.all',status='unknown',position='append')
!  open(14,file='fmt.spec',status='unknown',position='append')
!  open(15,file='fmt.raw',status='unknown',position='append',    &
!       form='unformatted')

  call soundinit                      !Initialize Portaudio

  npts=4*nfft + 36                           !Samples to acquire
  iqmode=0
  do iter=1,nrpt                             !Loop over repetitions
     nsec=time()
     ierr=soundin(ndevin,kwave,npts,iqmode)  !Get audio data, 48 kHz rate
     if(ierr.ne.0) then
        print*,'Error in soundin',ierr
        stop
     endif
     call fil1(kwave,npts,iwave,n2)          !Fiilter and downsample to 12 kHz

     s=0.
     do i=1,n2                               !Get ave
        s=s + iwave(i)
     enddo
     ave=s/n2
     sq=0.
     do i=1,n2                               !Get rms
        x(i)=iwave(i)-ave
        sq=sq + x(i)**2
        w=sin(i*3.14159/nfft)
        x(i)=w*x(i)
     enddo
     rms=sqrt(sq/n2)

     call four2a(x,nfft,1,-1,0)              !Compute spectrum

     smax=0.
     nq=nfft/4
     fac=1.0/float(nfft)**2
     i0=noffset/df
     ia=(noffset-500)/df
     ib=(noffset+1000)/df
     do i=ia,ib                              !Find fpeak
        s1(i)=fac * (real(c(i))**2 + aimag(c(i))**2)
        if(s1(i).gt.smax) then
           smax=s1(i)
           fpeak=i*df
        endif
     enddo

     s=0.
     do i=ia,ib
        if(abs(i-i0).gt.10) s=s+s1(i)
     enddo
     s=s/(ib-ia+1-21)

     n=mod(nsec,86400)
     nhr=n/3600
     nmin=mod(n/60,60)
     nsec=mod(n,60)
!     smax=100.0*smax/(rms*rms)
     pave=db(s)
     peak=db(smax)
     ferr=fpeak-noffset
     write(*,1100)  nhr,nmin,nsec,nkhz,noffset,fpeak,ferr,pave,peak
     write(12,1100) nhr,nmin,nsec,nkhz,noffset,fpeak,ferr,pave,peak
     write(13,1100) nhr,nmin,nsec,nkhz,noffset,fpeak,ferr,pave,peak
1100 format(i2.2,':',i2.2,':',i2.2,i7,i6,f10.2,f8.2,2f8.1)
!     write(14,1100) nhr,nmin,nsec,nkhz,noffset,fpeak,ferr,pave,peak
!     do i=1,nq
!        write(14,1102) i*df,s1(i)
!1102    format(2f10.2)
!     enddo
!     write(15) nhr,nmin,nsec,nkhz,noffset,fpeak,ferr,pave,peak,iwave
     call flush(12)
     call flush(13)
!     call flush(14)
!     call flush(15)
  enddo
  go to 999

910 print*,'Cannot open file: fmt.ini'

999 end program fmt
