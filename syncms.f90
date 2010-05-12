subroutine syncms(dat,jz,NFreeze,MouseDF,DFTolerance,ndepth,snrsync,dfx,     &
     lagbest,isbest,nerr,nqual,decoded,short,nshort)

  parameter (MAXSAM=65536)           !Max number of samples in ping
  real dat(jz)                       !Raw data sampled at 12000 Hz
  integer DFTolerance
  complex cdat(MAXSAM)               !Analytic signal
  complex cdat0(MAXSAM)               !Analytic signal
  complex csync(256)                 !Complex sync waveform
  complex c0(8)                      !Waveform for bit=0
  complex c1(8)                      !Waveform for bit=1
  complex c(MAXSAM)                  !Work array
  complex z0,z1
  real ccfblue(0:4000)
  real fblue(0:4000)
  real*8 fs,dt,twopi,baud,f0,f1
  integer istep(3),ibit(3)
  integer gsym(180),gs(3,180)
  integer iu(3)
  logical first
  character cmode*5,decoded*24,dec2*24

  integer is32(32)                   !Sync vector in one-bit format
  data is32/0,0,0,1,1,0,1,0,1,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,0,1/ 

  data istep/928,1216,1696/
  data ibit/30,48,78/
  data first/.true./
  save

  if(first) then
     first=.false.
     cmode='JTMS'
     twopi=8*atan(1.d0)
     fs=12000.d0                     !Sample rate
     nsps=8                          !Number of samples per symbol
     dt=1.d0/fs                      !Sample interval
     baud=fs/nsps                    !Keying rate
     f0=0.5d0*baud                   !Nominal Tx frequency for "0" bit
     f1=baud                         !Nominal Tx frequency for "1" bit
     call setupms(f0,f1,csync,c0,c1)
  endif

  decoded='                        '
  metric=0

  call analytic(dat,jz,cdat,fshort,short)   !Convert signal to analytic form

  nshort=0
  if(short.ge.10.0) then
     do ish=0,3
        dfshort=fshort-(882+ish*441)
        if(abs(dfshort).lt.DFTolerance) go to 10
     enddo
  endif
  go to 20
10 nshort=ish+1
20 continue

  cdat0(1:jz)=cdat(1:jz)             !Save a copy for possible later use
  nfft=512                           !Set constants and initial values
  nh=nfft/2
  df=fs/nfft
  sbest=0.
  isbest=0
  lagmax=min(4000,jz-nh)
  lagbest=0
  famin=-25.                         !Set DF search range
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

  do lag=0,lagmax                    !Find lag and DF
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

  if(lagbest.eq.0) then
     snrsync=0.                      !Bail out if nothing found
     go to 999
  endif

  smax=0.
  do n=1,3                           !Find message length
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

  nbit=30
  nstep=928
  if(isbest.ne.0) then
     nbit=ibit(isbest)
     nstep=istep(isbest)
  endif
  nsym=nstep/nsps

  smax=0.
  do idf=-25,25                      !Refine values of DF and phase
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
!           iphpk=iph1
           idfpk=idf
        endif
     endif
  enddo

  metmax=-10000
  do idf=-10,10
     do iph=0,180,30
        dphi=twopi*dt*(fbest+idfpk+idf)
        phi0=iph/57.2957795

        do i=1,jz                    !Tweak using best DF and phase
           phi=phi0 + (i-lagbest+1)*dphi
           cdat(i)=cdat0(i)*cmplx(cos(phi),-sin(phi))
        enddo

        nerr=0
        nsgn=1

        u=0.25
        sig=0.
        do j=1,nsym                  !Get soft symbols
           k=lagbest + 8*j-7
           z0=dot_product(c0,cdat(k:k+7))
           z1=dot_product(c1,cdat(k:k+7))
           if(j.eq.1 .and. real(z0).lt.real(z1)) nsgn=-1
           if(nsgn.lt.0) then
              z0=-z0
              z1=-z1
           endif
           x0=z0
           x1=z1

           s0=min(x0*x0,x1*x1)
           s1=max(x0*x0,x1*x1)
           sig=sig + s1 - s0

           softsym=5.0*(x1-x0)
           if(softsym.ge.0.0) then
              id2=1
           else
              id2=0
              nsgn=-nsgn
           endif
           if(j.le.32) then          !Count the hard sync-bit errors
              n=0
              if(id2.ne.is32(j)) n=1
              if(id2.ne.is32(j)) nerr=nerr+1
           endif
           if(j.ge.33 .and. j.le.212) then
              n=nint(softsym)
              gsym(j-32)=min(127,max(-127,n)) + 128
           endif
        enddo
        
        minmet0=9*(nbit+12)
        minmet=minmet0
        maxerr=8
        if(ndepth.eq.1) then
           minmet=10*(nbit+12)
           maxerr=6
        endif

        if(nerr.le.maxerr) then
           call decodems(nbit,gsym,metric,iu)
           if(metric.ge.minmet) then
              call srcdec(cmode,nbit,iu,decoded)
           endif

           if(metric.gt.metmax) then
              dec2=decoded
              idfpk2=idf
              iphpk2=iph
              metmax=metric
              nerr2=nerr
              sigbest=sig
           endif
        endif
     enddo
  enddo

!###
! OK, we now have the best idf and iph.  Do the inner loop once more,
! using soft symbols from before as well as after the sync vector.

  if(nerr2.le.maxerr) then
     idf=idfpk2
     iph=iphpk2
     dphi=twopi*dt*(fbest+idfpk+idf)
     phi0=iph/57.2957795
     do i=1,jz                    !Tweak freq and phase
        phi=phi0 + (i-lagbest+1)*dphi
        cdat(i)=cdat0(i)*cmplx(cos(phi),-sin(phi))
     enddo

     nsgn=1
     sig=0.

! Get soft symbols and decode
     ja=1-nsym
     if(ja.lt.(8-lagbest)/8) ja=(8-lagbest)/8 + 1
     jb=2*nsym
     if(jb.gt.(65543-lagbest)/8) jb=(65543-lagbest)/8
     gs=0
     do j=ja,jb
        k=lagbest + 8*j-7
        z0=dot_product(c0,cdat(k:k+7))
        z1=dot_product(c1,cdat(k:k+7))
        if(j.eq.1 .and. real(z0).lt.real(z1)) nsgn=-1
        if(nsgn.lt.0) then
           z0=-z0
           z1=-z1
        endif
        x0=z0
        x1=z1

        s0=min(x0*x0,x1*x1)
        s1=max(x0*x0,x1*x1)
        sig=sig + s1 - s0

        softsym=5.0*(x1-x0)
        if(softsym.ge.0.0) then
           id2=1
        else
           id2=0
           nsgn=-nsgn
        endif
        n=nint(softsym)
        
        if(j.ge.33-nsym .and. j.le.212-nsym) gs(1,j-32+nsym)=n
        if(j.ge.33 .and. j.le.212) gs(2,j-32)=n
        if(j.ge.33+nsym .and. j.le.212+nsym) gs(3,j-32-nsym)=n
        if(j.ge.33 .and. j.le.212) gsym(j-32)=min(127,max(-127,n)) + 128
     enddo

     metmax=-10000
     ndata=nsym-32
     call decodems(nbit,gsym,metric,iu)
     if(metric.ge.metmax) then
        metmax=metric
        call srcdec(cmode,nbit,iu,decoded)
        dec2=decoded
        nbest=1
     endif

     do j=1,ndata
        n=nint((gs(1,j) + gs(2,j))/2.0)
        gsym(j)=min(127,max(-127,n)) + 128
     enddo
     call decodems(nbit,gsym,metric,iu)
     if(metric.ge.metmax) then
        metmax=metric
        call srcdec(cmode,nbit,iu,decoded)
        dec2=decoded
        nbest=2
     endif

     do j=1,ndata
        n=nint((gs(2,j) + gs(3,j))/2.0)
        gsym(j)=min(127,max(-127,n)) + 128
     enddo
     call decodems(nbit,gsym,metric,iu)
     if(metric.ge.metmax) then
        metmax=metric
        call srcdec(cmode,nbit,iu,decoded)
        dec2=decoded
        nbest=3
     endif

     do j=1,ndata
        n=nint((gs(1,j) + gs(2,j) + gs(3,j))/3.0)
        gsym(j)=min(127,max(-127,n)) + 128
     enddo
     call decodems(nbit,gsym,metric,iu)
     if(metric.ge.metmax) then
        metmax=metric
        call srcdec(cmode,nbit,iu,decoded)
        dec2=decoded
        nbest=4
     endif
  endif
!###

  idfpk=idfpk+idfpk2
  metric=metmax
  nerr=nerr2
  decoded='                        '
  nqual=0
  if(metric.ge.minmet) then
     decoded=dec2
     nqual=nint(10.0*(float(metric)/minmet0 - 1.0)) + 1
!     print*,'A',nbit,nbest,nerr2,metric,minmet0,nqual
  endif
  dfx=fbest-375+idfpk
  snrsync=sbest
  snrsync=sigbest

999  return
end subroutine syncms
