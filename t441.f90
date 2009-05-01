program t441

! Run tests on the "TNX QSO TNX QSO ..." ping in W8WN sample file.

  parameter (NPTS=9283)
  character*28 tmsg
  character*12 arg
  real ps(128)                              !Spectrum computed in WSJT
  real dat(NPTS)                            !Raw data, 11025 S/s
  real s1(NPTS)
  real s2(NPTS)
  real acf(500)
  real p(28*3*25)                           !Folded s2
  integer itone(3*28)                       !Tones of test message
  complex cz(3*28*25)                       !Complex LO for test message
  complex csum
  data twopi/6.2831853/

  nargs=iargc()
  if(nargs.ne.3) then
     print*,'Usage: t441 "Test message" tstep fdiv'
     go to 999
  endif
  call getarg(1,tmsg)
  call getarg(2,arg)
  read(arg,*) nstep
  call getarg(3,arg)
  read(arg,*) fdiv

  call gen441(tmsg,nmsg,itone)
  nsym=3*nmsg
  nsamp=25*nsym

  open(88,file='dat.88',form='unformatted',status='old')
  read(88) jjz,ps,f0,(dat(j),j=1,jjz)       !Read raw data saved by WSJT
  df1=11025.0/256.0                         !df for the ps() spectrum

  df0=441.0                                 !Tone spacing
  dt=1.0/11025.0                            !Sample interval

  df=11025.0/(fdiv*nsamp)
  ndf=221.0/df
  sbest=0.

  do idf=-ndf,ndf                           !Loop over allowed range of DF
     xdf=idf*df
     phi=0.                                 !Initialize phase
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

     k=0
     do idt=0,NPTS-nsamp,nstep             !Loop over time offset DT
        k=k+1
        csum=0.
        do i=1,nsamp
           csum=csum + cz(i)*dat(i+idt)
        enddo
        s=real(csum)**2 + aimag(csum)**2
        s1(k)=s
        if(s.gt.sbest) then
           sbest=s
           idfpk=idf
           idtpk=idt
        endif
     enddo
     if(idfpk.eq.idf) s2(1:k)=s1(1:k)
  enddo
  kz=k
  xdfpk=idfpk*df

  do k=1,kz
     write(13,1040) k,s2(k)
1040 format(i5,f10.0)
  enddo

  do lag=0,2500/nstep
     sum=0.
     do i=1,kz-lag
        sum=sum + s2(i)*s2(i+lag)
     enddo
     acf(lag)=1.e-3*sum/(kz-lag)
     tp=lag*nstep/75.0
     write(14,1050) lag,tp,acf(lag)
1050 format(i5,f10.3,f13.3)
     if(tp.gt.1.5 .and. acf(lag).gt.acfmax) then
        acfmax=acf(lag)
        ppk=tp
     endif
  enddo

  write(*,1020) tmsg(1:8),nmsg,2*ndf+1,kz,nint(xdfpk),idtpk,nint(sbest),ppk
1020 format(a8,'  Nmsg:',i3,'  Nf:',i4,'  Nt:',i5,'  DF:',i4,      &
            '  DT:',i5,'  S:'i6,'  P:',f7.2)

999 end program t441
