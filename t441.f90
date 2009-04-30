program t441

! Run tests on the "TNX QSO TNX QSO ..." ping in W8WN sample file.

  parameter (NSTEP=3)                       !Step size for lag (samples)
  parameter (NP=1200/NSTEP)                 !Period of full message (lags)
  parameter (MAXFFT=4096)                   !FFT length
  character*28 tmsg
  real ps(128)                              !Spectrum computed in WSJT
  real dat(9283)                            !Raw data, 11025 S/s
  integer itone(3*28)                       !Tones of test message
  complex cz(3*28*25)                       !Complex LO for test message
  complex c(MAXFFT)                         !Mixed signal
  data twopi/6.2831853/

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: t441 "Test message"'
     go to 999
  endif
  call getarg(1,tmsg)
  call gen441(tmsg,nmsg,itone)
  nsym=3*nmsg
  nsamp=25*nsym

  write(*,1000) nmsg,nsamp,8,8*75
1000 format('Test msg:',i3,' ch,'i4,' samples.'/               &
            'Full msg:',i3,' ch,'i4,' samples.')

  open(88,file='dat.88',form='unformatted',status='old')
  read(88) jjz,ps,f0,(dat(j),j=1,jjz)       !Read raw data saved by WSJT
  df1=11025.0/256.0                         !df for the ps() spectrum

  foffset=582.
  f0=882-foffset
  df0=441.0                                 !Tone spacing
  dt=1.0/11025.0                            !Sample interval
  phi=0.                                    !Initialize phase
  j0=999
  do i=1,nsamp                      !Generate conjugate of message waveform
     j=(i-1)/25 + 1
     if(j.ne.j0) then
        freq=f0 + itone(j)*df0
        dphi=twopi*freq*dt
        j0=j
     endif
     phi=phi+dphi
     cz(i)=0.001*cmplx(cos(phi),-sin(phi))
  enddo

! Find best match to test message over all lags and all frequency offsets
  nfft=256
  nh=nfft/2
  df=11025.0/nfft
  k=0
  sbest=0.
  do lag=0,9000,NSTEP
     k=k+1
     c=0.
     do i=1,nsamp
        c(i)=cz(i) * dat(i+lag)
     enddo
     call four2a(c,nfft,1,-1,1)
     smax=0.
     do i=1,nh+1
        s=(real(c(i))**2 + aimag(c(i))**2)
        if(s.gt.smax) then
           smax=s
           ipk=i
        endif
     enddo
     write(13,3002) lag,smax,ipk
3002 format(i6,f10.0,i8)
     if(smax.gt.sbest) then
        sbest=smax
        npk=ipk
        kpk=k
     endif
  enddo
  kz=k
  fpk=(npk-1)*df
  xdf=fpk-foffset
  write(*,1030) xdf,kpk,sbest
1030 format('Fpk:',f7.0,'   Lagpk:',i4,'   Sbest:',f8.0)
  
999 end program t441
