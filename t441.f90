program t441

! Run tests on the "TNX QSO TNX QSO ..." ping in W8WN sample file.

  parameter (NSTEP=3)                       !Step size for lag (samples)
  parameter (NP=1200/NSTEP)                 !Period of full message (lags)
  character*28 tmsg
  real ps(128)                              !Spectrum computed in WSJT
  real dat(9283)                            !Raw data, 11025 S/s
  real s1(9283)
  real s2(9283)
  integer itone(3*28)                       !Tones of test message
  complex cz(3*28*25)                       !Complex LO for test message
  complex csum
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

  df0=441.0                                 !Tone spacing
  dt=1.0/11025.0                            !Sample interval

  df=11025.0/(10*nsamp)
  ndf=221.0/df
  sbest=0.
  print*,nsamp,df,ndf

  do idf=-ndf,ndf
     xdf=idf*df
     phi=0.                                    !Initialize phase
     j0=999
     do i=1,nsamp                      !Generate conjugate of message waveform
        j=(i-1)/25 + 1
        if(j.ne.j0) then
           freq=882.0 + xdf + itone(j)*df0
           dphi=twopi*freq*dt
           j0=j
        endif
        phi=phi+dphi
        cz(i)=0.001*cmplx(cos(phi),-sin(phi))
     enddo

     ! Find best match to test message over all lags and all frequency offsets
     k=0
     do lag=0,9283-nsamp,NSTEP
        k=k+1
        csum=0.
        do i=1,nsamp
           csum=csum + cz(i)*dat(i+lag)
        enddo
        s=real(csum)**2 + aimag(csum)**2
        s1(k)=s
        if(s.gt.sbest) then
           sbest=s
           idfpk=idf
           lagpk=lag
        endif
     enddo
     if(idfpk.eq.idf) s2(1:k)=s1(1:k)
  enddo
  kz=k
  xdfpk=idfpk*df
  write(*,1030) xdfpk,lagpk,sbest
1030 format('Fpk:',f7.0,'   Lagpk:',i4,'   Sbest:',f8.0)

  do k=1,kz
     write(13,1040) k,s2(k)
1040 format(i5,f10.0)
  enddo
  
999 end program t441
