subroutine syncms(dat,jz,NFreeze,MouseDF,DFTolerance,snrsync,dfx,     &
     lagbest,isbest,nerr,metric,decoded)

  parameter (MAXSAM=65536)           !Max number of samples in ping
  real dat(jz)                       !Raw data sampled at 12000 Hz
  integer DFTolerance
  complex cdat(MAXSAM)               !Analytic signal
  complex cdat0(MAXSAM)               !Analytic signal
  complex csync(256)                 !Complex sync waveform
  complex c0(8)                      !Waveform for bit=0
  complex c1(8)                      !Waveform for bit=1
  complex c(MAXSAM)                  !Work array
  complex z,z0,z1,zsum,zavg
  real ccfblue(0:4000)
  real fblue(0:4000)
  real*8 fs,dt,twopi,baud,f0,f1
  integer istep(3),ibit(3)
  integer gsym(180)
  integer isym(212)
  integer iu(3)
  logical first
  character cmode*5,decoded*24,dec2*24

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

  decoded='                        '
  metric=0

  call analytic(dat,jz,cdat)      !Convert signal to analytic form
  cdat0(1:jz)=cdat(1:jz)          !Save a copy for possible later use

  nfft=512                        !Set constants and initial values
  nh=nfft/2
  df=fs/nfft
  sbest=0.
  isbest=0
  lagmax=min(4000,jz-nh)
  lagbest=0
  iz=500.0/df

  famin=-25.                      !Set DF search range
  fbmax=775.
  ia=famin/df
  ib=fbmax/df
  f0=375.
  if(NFreeze.eq.1) then
     fa=max(famin,f0+MouseDF-DFTolerance)
     fb=min(fbmax,f0+MouseDF+DFTolerance)
  else
     fa=max(famin,f0+MouseDF-400)
     fb=min(fbmax,f0+MouseDF+400)
  endif
  ia=fa/df - 2
  if(ia.lt.1) ia=1
  ib=fb/df + 3

  do lag=0,lagmax                           !Find lag and DF
     do i=1,nh
        c(i)=cdat(i+lag)*conjg(csync(i))
     enddo
     c(nh+1:nfft)=0.
     call four2a(c,nfft,1,-1,1)
     smax=0.
     do i=ia,ib
        sq=real(c(i))**2 + aimag(c(i))**2
        f=df*(i-1)
        if(f.ge.fa-0.5*df .and. f.le.fb+0.5*df .and. sq.gt.smax) then
           smax=sq
           ipk=i
        endif
     enddo
     freq=df*(ipk-1)
     ccfblue(lag)=1.e-8*smax
     fblue(lag)=freq
     if(smax.gt.sbest) then
        sbest=smax
        fbest=freq
        lagbest=lag
     endif
  enddo

  smax=0.
  do n=1,3                                   !Find message length
     do nsgn=-1,1,2
        i0=lagbest + nsgn*istep(n)
        if((nsgn.eq.-1 .and. i0.ge.3) .or.                          &
           (nsgn.eq.1 .and. i0.le.lagmax-3))  then
           do i=-3,3
              if(ccfblue(i0+i).gt.smax .and.                        &
                   abs(fblue(i0+i)-fbest).lt.1.5*df) then
                 smax=ccfblue(i0+i)
                 isbest=n
              endif
           enddo
        endif
     enddo
  enddo

  if(lagbest.eq.0) then
     snrsync=0.                             !Bail out if nothing found
     go to 999
  endif

  nbit=0
  nstep=928
  if(isbest.ne.0) then
     nbit=ibit(isbest)
     nstep=istep(isbest)
  endif
  nsym=nstep/nsps

!  rewind 72

  smax=0.
  do idf=-25,25                           !Refine values of DF and phase
     dphi=twopi*dt*(fbest+idf)
     dfx=fbest + idf - 375.0
     if(dfx.ge.mousedf-dftolerance .and. dfx.le.mousedf+dftolerance) then
        s1=0.
        do iph=-160,180,20
           phi=iph/57.2957795
           s=0.
           do i=1,256
              phi=phi+dphi
              s=s + cdat(lagbest+i-1)* cmplx(cos(phi),-sin(phi)) *     &
                   conjg(csync(i))
           enddo
           if(s.gt.s1) then
              s1=s
              iph1=iph
           endif
        enddo
        if(s1.gt.smax) then
           smax=s1
           iphpk=iph1
           idfpk=idf
        endif
     endif
  enddo

  metmax=-10000
  do idf=-10,10,2
     do iph=0,180,30
        dphi=twopi*dt*(fbest+idfpk+idf)
        phi0=iph/57.2957795

        do i=1,jz                            !Tweak using best DF and phase
           phi=phi0 + (i-lagbest+1)*dphi
           cdat(i)=cdat0(i)*cmplx(cos(phi),-sin(phi))
        enddo

        nerr=0
        nsgn=1
        zsum=0.
        u=0.25
        sig=0.
        do j=1,nsym                               !Get soft symbols
           k=lagbest + 8*j-7
           tmid=(k+3)*dt
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
           if(abs(z0).ge.abs(z1)) then
              pha=atan2(aimag(z0),real(z0))
              if(j.eq.1) zavg=z0
              if(j.eq.1) sig=z0*conjg(z0)
              zavg=zavg + u*(z0-zavg)
              sig=sig + u*(z0*conjg(z0)-sig)
              zsum=zsum + z0
           else
              pha=atan2(aimag(z1),real(z1))
              if(j.eq.1) zavg=z0
              if(j.eq.1) sig=z0*conjg(z0)
              zavg=zavg + u*(z1-zavg)
              sig=sig + u*(z1*conjg(z1)-sig)
              zsum=zsum + z1
           endif
           phavg=atan2(aimag(zavg),real(zavg))
!           write(72,2903) j,pha,phavg,tmid,sig             !Save phase for plot
!2903       format(i6,2f10.3,f10.6,f10.2)

           softsym=nsgn*(x1-x0)
           if(softsym.ge.0.0) then
              id2=1
           else
              id2=0
              nsgn=-nsgn
           endif
           if(j.le.32) then                   !Count the hard sync-bit errors
              n=0
              if(id2.ne.is32(j)) n=1
              if(id2.ne.is32(j)) nerr=nerr+1
           else
              n=nint(softsym)
              gsym(j-32)=min(127,max(-127,n)) + 128
           endif
           ii=0
           if(j.le.32) ii=is32(j)
           n=0
           if(j.gt.32) n=gsym(j-32)
        enddo
        
        if(nbit.ne.0 .and. nerr.le.8) then
           minmet=8*(nbit+12)
           call decodems(nbit,gsym,metric,iu)
           if(metric.ge.minmet) then
              cmode='JTMS'
              call srcdec(cmode,nbit,iu,decoded)
           endif
        endif

        if(metric.gt.metmax) then
           dec2=decoded
           idfpk2=idf
           iphpk2=iph
           metmax=metric
           nerr2=nerr
        endif
     enddo
  enddo
  idfpk=idfpk+idfpk2
  decoded=dec2
  metric=metmax
  nerr=nerr2
!  write(73,2701) idfpk2,iphpk2,nerr,metric,decoded
!2701 format(4i6,2x,a24)

  dfx=fbest-375+idfpk
  snrsync=1.e-9*sbest

!  call flushqqq(72)
!  call flushqqq(73)

999  return
end subroutine syncms
