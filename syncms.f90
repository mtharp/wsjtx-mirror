subroutine syncms(dat,jz,snrsync,dfx,lagbest,isbest,nerr,metric,decoded)

  parameter (MAXSAM=65536)           !Max number of samples in ping
  real dat(jz)                       !Raw data sampled at 12000 Hz
  complex cdat(MAXSAM)               !Analytic signal
  complex cdat0(MAXSAM)               !Analytic signal
  complex csync(256)                 !Complex sync waveform
  complex c0(8)                      !Waveform for bit=0
  complex c1(8)                      !Waveform for bit=1
  complex c(MAXSAM)                  !Work array
  complex z,z0,z1
  real ccfblue(0:4000)
  real fblue(0:4000)
  real*8 fs,dt,twopi,baud,f0,f1
  integer istep(3),ibit(3)
  integer gsym(180)
  integer isym(212)
  integer iu(3)
  logical first
  character cmode*5,decoded*24

  integer is32(32)                     !Sync vector in one-bit format
  data is32/0,0,0,1,1,0,1,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,0,1/ 

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

  call analytic(dat,jz,cdat)      !Convert signal to analytic form
  cdat0(1:jz)=cdat(1:jz)

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
!     write(72,2002) lag,ccfblue(lag),fblue(lag)
!2002 format(i6,2f12.3)
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
!              write(74,*) n,nsgn,i0+i,ccfblue(i0+i)
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
  nsym=nstep/nsps

!  write(*,1060) fbest,lagbest,1.e-8*sbest,nbit
!1060 format('DF:',f8.1,'   Lag:',i5,'   Sbest:',f8.1,'   Nbit:',i3)

! Get refined values of DF and phase
  smax=0.
  do idf=-25,25
     dphi=twopi*dt*(fbest+idf)
     s1=0.
     do iph=-160,180,20
        phi=iph/57.2957795
        s=0.
        do i=1,256
           phi=phi+dphi
           s=s + cdat(lagbest+i-1)*cmplx(cos(phi),-sin(phi)) * conjg(csync(i))
        enddo
        if(s.gt.s1) then
           s1=s
           iph1=iph
        endif
     enddo
!     write(71,3101) idf,iph1,s1
!3101 format(2i5,f10.1)
     if(s1.gt.smax) then
        smax=s1
        iphpk=iph1
        idfpk=idf
     endif
  enddo
  print*,'Best:',smax,idfpk,iphpk,nsym

! Adjust cdat() using best values for frequency and phase
  dphi=twopi*dt*(fbest+idfpk)
  do iph=-160,180,20
  phi0=iph/57.2957795
  do i=1,jz
     phi=phi0 + (i-lagbest+1)*dphi
     cdat(i)=cdat0(i)*cmplx(cos(phi),-sin(phi))
  enddo

  nerr=0
  nsgn=1
  do j=1,nsym                               !Get soft symbols
     k=lagbest + 8*j-7
     z0=dot_product(c0,cdat(k:k+7))
     z1=dot_product(c1,cdat(k:k+7))
     z0=0.003*z0 * cexp(cmplx(0.0,-j*1.56/200.0))
     z1=0.003*z1 * cexp(cmplx(0.0,-j*1.56/200.0))
     x0=z0
     x1=z1

     if(nsgn.lt.0) then
        z0=-z0
        z1=-z1
     endif
     if(abs(z0).ge.abs(z1)) pha=atan2(aimag(z0),real(z0))
     if(abs(z0).lt.abs(z1)) pha=atan2(aimag(z1),real(z1))
     write(72,2903) j,(isym(j)-127)/2,pha,z0,z1
2903 format(2i6,5f10.2)

     softsym=nsgn*(x1-x0)
     if(softsym.ge.0.0) then
        id2=1
     else
        id2=0
        nsgn=-nsgn
     endif
     if(j.le.32) then
        n=0
        if(id2.ne.is32(j)) n=1
!        write(*,2901) j,is32(j),id2,n,softsym
!2901    format(4i6,f9.1)
        if(id2.ne.is32(j)) nerr=nerr+1
     else
        n=nint(softsym)
        gsym(j-32)=min(127,max(-127,n)) + 128
     endif
     ii=0
     if(j.le.32) ii=is32(j)
     n=0
     if(j.gt.32) n=gsym(j-32)
     write(71,1010) j,ii,id2,n,softsym,x0,x1,z0,z1
1010 format(4i4,3f8.0,2x,4f8.0)
  enddo

!  write(*,1020) nerr
!1020 format('Hard-decision errors in sync vector:',i4)

  decoded='                        '
  metric=0
  if(nbit.ne.0) then
     minmet=5*nbit
     call decodems(nbit,gsym,metric,iu)
     if(metric.ge.minmet) then
        cmode='JTMS'
        call srcdec(cmode,nbit,iu,decoded)
     endif
  endif
  print*,iph,iphpk,nerr,metric,'   ',decoded
  enddo
  dfx=fbest-375+idfpk
  snrsync=1.e-8*sbest

  call flushqqq(71)
  call flushqqq(72)
!  call flushqqq(73)
!  call flushqqq(74)

  return
end subroutine syncms
