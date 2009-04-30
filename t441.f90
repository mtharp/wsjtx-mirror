program t441

! Run tests on the "TNX QSO TNX QSO ..." ping in W8WN sample file.

  parameter (NPTS=9283)
  character*28 tmsg
  character*12 arg
  real ps(128)                              !Spectrum computed in WSJT
  real dat(NPTS)                            !Raw data, 11025 S/s
  real s1(NPTS)
  real s2(NPTS)
  real p(28*3*25)                           !Folded s2
  integer itone(3*28)                       !Tones of test message
  complex cz(3*28*25)                       !Complex LO for test message
  complex csum
  complex cs2(0:2048)
  equivalence(s2,cs2)
  data twopi/6.2831853/

  nargs=iargc()
  if(nargs.ne.2) then
     print*,'Usage: t441 "Test message" nstep'
     go to 999
  endif
  call getarg(1,tmsg)
  call getarg(2,arg)
  read(arg,*) nstep
  call gen441(tmsg,nmsg,itone)
  nsym=3*nmsg
  nsamp=25*nsym

  write(*,1000) nmsg,nsamp
1000 format('Test msg:',i3,' chars,'i4,' samples.')

  open(88,file='dat.88',form='unformatted',status='old')
  read(88) jjz,ps,f0,(dat(j),j=1,jjz)       !Read raw data saved by WSJT
  df1=11025.0/256.0                         !df for the ps() spectrum

  df0=441.0                                 !Tone spacing
  dt=1.0/11025.0                            !Sample interval

  df=11025.0/(10*nsamp)
  ndf=221.0/df
  sbest=0.

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
     do lag=0,NPTS-nsamp,nstep
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
  write(*,1020) nmsg,2*ndf+1,kz
1020 format('Nmsg:',i3,'   Nf:',i4,'   Nt:',i5)
  write(*,1030) xdfpk,lagpk,sbest
1030 format('Fpk:',f7.0,'   Lagpk:',i4,'   Sbest:',f8.0)

  do k=1,kz
     write(13,1040) k,s2(k)
1040 format(i5,f10.0)
  enddo

  pbest=0.
  do np=2,28
     jz=np*75/nstep
     nsum=kz/jz
     kz2=nsum*jz
     p(1:jz)=0.
     do k=1,kz2
        j=mod(k-1,jz)+1
        p(j)=p(j)+s2(k)
     enddo
     lu=20+np
     fac=sqrt(1.0/nsum)
     pmax=0.
     do j=1,jz
        p(j)=fac*p(j)
        if(p(j).gt.pmax) then
           pmax=p(j)
           if(p(j).gt.pbest) then
              pbest=p(j)
              npbest=np
           endif
        endif
        write(lu,1050) j,p(j)
1050    format(i5,f10.0)
     enddo
     write(14,1060) np,pmax
1060 format(i5,f10.0)
  enddo
  print*,npbest,pbest,kz

  nfft=4096
  nh=nfft/2
  s2(kz+1:nfft)=0.
  s2(1:kz)=1.e-4*s2(1:kz)

  call four2a(s2,nfft,1,-1,0)
  do i=1,nh
     ss2=real(cs2(i))**2 + aimag(cs2(i))**2
     period=float(nfft)/i
     write(15,1070) i,ss2,period
1070 format(i5,f10.3,f10.3)
  enddo

999 end program t441
