subroutine syncms(dat,jz,snrsync,dfx,lagbest,isbest)

  parameter (MAXSAM=32768)           !Max number of samples in ping
  real dat(jz)                       !Raw data sampled at 12000 Hz
  complex cdat(MAXSAM)               !Analytic signal
  complex csync(256)                 !Complex sync waveform
  complex c0(8)                      !Waveform for bit=0
  complex c1(8)                      !Waveform for bit=1
  complex c(MAXSAM)                  !Work array
  complex z
  real ccfblue(0:4000)
  real fblue(0:4000)
  real*8 fs,dt,twopi,baud,f0,f1
  integer istep(3),ibit(3)
  logical first
  data istep/928,1216,1696/
  data ibit/30,48,78/
  data first/.true./
  save

  if(first) then
     first=.false.
     twopi=8*atan(1.d0)
     fs=12000.d0                     !Sample rate
     nsps=8                          !Number of samples per symbol
     nsync=32                        !Number of symbols in sync vector
     dt=1.d0/fs                      !Sample interval
     baud=fs/nsps                    !Keying rate
     f0=0.5d0*baud                   !Nominal Tx frequency for "0" bit
     f1=baud                         !Nominal Tx frequency for "1" bit
     call setupms(f0,f1,csync,c0,c1)
  endif

  call analytic(dat,jz,cdat)         !Convert signal to analytic form

! Find lag and DF
  nfft=512
  nh=nfft/2
  df=fs/nfft
  sbest=0.
  isbest=0
  lagmax=min(4000,jz-nh)
  iz=500.0/df
  do lag=0,lagmax
     do i=1,nh
        c(i)=cdat(i+lag)*conjg(csync(i))
     enddo
     c(nh+1:nfft)=0.
     call four2a(c,nfft,1,-1,1)
     smax=0.
     do i=1,iz
        sq=real(c(i))**2 + aimag(c(i))**2
        if(sq.gt.smax) then
           smax=sq
           ipk=i
        endif
     enddo
     do i=nfft-iz,nfft
        sq=real(c(i))**2 + aimag(c(i))**2
        if(sq.gt.smax) then
           smax=sq
           ipk=i
        endif
     enddo
     freq=df*(ipk-1)
     if(ipk.gt.nh+1) freq=df*(ipk-1-nfft)
     ccfblue(lag)=1.e-8*smax
     fblue(lag)=freq
     write(72,2002) lag,ccfblue(lag),fblue(lag)
2002 format(i6,2f12.3)
     if(smax.gt.sbest) then
        sbest=smax
        fbest=df*(ipk-1)
        lagbest=lag
     endif
  enddo
  if(fbest.gt.0.5*fs) fbest=fbest-fs

! Find length of message: isbest=1, 2, or 3 for nbit=30, 48, or 78.
  smax=0.
  do n=1,3
     do nsgn=-1,1,2
        i0=lagbest + nsgn*istep(n)
        if((nsgn.eq.-1 .and. i0.ge.3) .or.                          &
           (nsgn.eq.1 .and. i0.le.lagmax-3))  then
           do i=-3,3
              write(74,*) n,nsgn,i0+i,ccfblue(i0+i)
              if(ccfblue(i0+i).gt.smax .and.                        &
                   abs(fblue(i0+i)-fbest).lt.1.5*df) then
                 smax=ccfblue(i0+i)
                 isbest=n
              endif
           enddo
        endif
     enddo
  enddo

  nbit=0
  nstep=928
  if(isbest.ne.0) then
     nbit=ibit(isbest)
     nstep=istep(isbest)
  endif

  write(*,1060) fbest,lagbest,1.e-8*sbest,nbit
1060 format('DF:',f8.1,'   Lag:',i5,'   Sbest:',f8.1,'   Nbit:',i3)

  phi=0.d0
  dphi=twopi*dt*fbest
  do i=1,jz
     phi=phi+dphi
     cdat(i)=cdat(i) * cmplx(cos(phi),-sin(phi))
     j=mod(i-lagbest+100*nstep,nstep) + 1
     z=0.
     c(i)=0.
     if(j.ge.1 .and. j.le.256) then
        z=csync(j)
        c(i)=cdat(i) * conjg(z)
     endif
     write(73,3101) i,i-lagbest,0.002*cdat(i),z
3101 format(2i8,4f12.3)
  enddo

  xn=log(float(jz))/log(2.0)
  n=xn
  if(xn-n .gt.0.001) n=n+1
  nfft=2**n
  nh=nfft/2
  df=fs/nfft
  c(jz+1:nfft)=0.
  call four2a(c,nfft,1,-1,1)
  do i=1,nfft
     sq=real(c(i))**2 + aimag(c(i))**2
     freq=df*(i-1)
     if(i.gt.nh+1) freq=df*(i-1-nfft)
     write(71,2001) freq,1.e-8*sq
2001 format(2f12.3)
  enddo

  dfx=fbest-375
  snrsync=1.e-8*sbest

  call flushqqq(71)
  call flushqqq(72)
  call flushqqq(73)
  call flushqqq(74)

  return
end subroutine syncms
