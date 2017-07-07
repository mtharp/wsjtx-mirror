program ft8sim

! Generate simulated data for a 15-second HF/6m mode using 8-FSK.
! Output is saved to a *.wav file.

  use wavhdr
  include 'ft8_params.f90'               !Set various constants
  type(hdr) h                            !Header for .wav file
  character arg*12,fname*17
  character msg*22,msgsent*22
  complex c0(0:NMAX-1)
  complex c(0:NMAX-1)
  integer itone(NN)
  integer*2 iwave(NMAX)                  !Generated full-length waveform  

! Get command-line argument(s)
  nargs=iargc()
  if(nargs.ne.6) then
     print*,'Usage:   ft8sim "message"          DT fdop del nfiles snr'
     print*,'Example: ft8sim "K1ABC W9XYZ EN37" 0.0 0.1 1.0   10   -18'
     go to 999
  endif
  call getarg(1,msg)                     !Message to be transmitted
  call getarg(2,arg)
  read(arg,*) xdt                        !Time offset from nominal (s)
  call getarg(3,arg)
  read(arg,*) fspread                    !Watterson frequency spread (Hz)
  call getarg(4,arg)
  read(arg,*) delay                      !Watterson delay (ms)
  call getarg(5,arg)
  read(arg,*) nfiles                     !Number of files
  call getarg(6,arg)
  read(arg,*) snrdb                      !SNR_2500

  twopi=8.0*atan(1.0)
  fs=12000.0                             !Sample rate (Hz)
  dt=1.0/fs                              !Sample interval (s)
  tt=NSPS*dt                             !Duration of symbols (s)
  baud=1.0/tt                            !Keying rate (baud)
  bw=8*baud                              !Occupied bandwidth (Hz)
  txt=NZ*dt                              !Transmission length (s)
  bandwidth_ratio=2500.0/(fs/2.0)
  sig=sqrt(2*bandwidth_ratio) * 10.0**(0.05*snrdb)
  if(snrdb.gt.90.0) sig=1.0
  txt=NN*NSPS/12000.0

  call genft8(msg,msgsent,itone)         !Source-encode, then get itone()
  write(*,1000) f0,xdt,txt,snrdb,bw,msgsent
1000 format('f0:',f9.3,'   DT:',f6.2,'   TxT:',f6.1,'   SNR:',f6.1,    &
          '  BW:',f4.1,2x,a22)
  
!  call sgran()
  c=0.
  do ifile=1,nfiles
     c0=0.
     do isig=1,25
        f0=(isig+2)*100.0
        phi=0.0
        k=-1 + nint(xdt+0.5/dt)
        do j=1,NN                             !Generate complex waveform
           dphi=twopi*(f0+itone(j)*baud)*dt
           if(k.eq.0) phi=-dphi
           do i=1,NSPS
              k=k+1
              phi=phi+dphi
              if(phi.gt.twopi) phi=phi-twopi
              xphi=phi
              if(k.ge.0 .and. k.lt.NMAX) c0(k)=cmplx(cos(xphi),sin(xphi))
           enddo
        enddo
        if(fspread.ne.0.0 .or. delay.ne.0.0) call watterson(c,NMAX,fs,delay,fspread)
        c=c+c0
     enddo
     c=c*sig
     if(snrdb.lt.90) then
        do i=0,NMAX-1                   !Add gaussian noise at specified SNR
           xnoise=gran()
           ynoise=gran()
           c(i)=c(i) + cmplx(xnoise,ynoise)
        enddo
     endif

     fac=32767.0
     rms=100.0
     if(snrdb.ge.90.0) iwave(1:NMAX)=nint(fac*real(c))
     if(snrdb.lt.90.0) iwave(1:NMAX)=nint(rms*real(c))

     h=default_header(12000,NMAX)
     write(fname,1102) ifile
1102 format('000000_',i6.6,'.wav')
     open(10,file=fname,status='unknown',access='stream')
     write(10) h,iwave                !Save to *.wav file
     close(10)
     write(*,1110) ifile,xdt,f0,snrdb,fname
1110 format(i4,f7.2,f8.2,f7.1,2x,a17)
  enddo
       
999 end program ft8sim
