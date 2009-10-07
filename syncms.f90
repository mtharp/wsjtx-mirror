subroutine syncms(dat,jz,snrsync,fbest,lagbest,isbest)

  parameter (MAXSAM=24000)           !Max number of samples in ping
  integer id(32)                     !Sync followed by data in one-bit format
  real dat(jz)
  real x0(32)                        !Waveform for bit=0
  real x1(32)                        !Waveform for bit=1
  real ccfblue(0:4000)
  real fblue(0:4000)
  complex csync(1024)                !Complex sync waveform
  complex c(MAXSAM)                  !Work array
  integer istep(3)
  logical first
  data isync32/Z'1acffc1d'/          !32-bit sync
  data istep/928,1216,1696/,nstep/3/
  data first/.true./
  save

  if(first) then
     fs=12000
     nsps=8
     nsync=32
     pha=0.
     nbit=0
     pha0=-90.
     ndata=(nbit+12)*2               !Number of data symbols (K=13, r=1/2)
     nsym=ndata+nsync                !Total number of symbols
     twopi=8*atan(1.0)
     dt=1./fs                        !Sample interval
     baud=fs/nsps                       !Keying rate

     foffset=375.
     f0=0.5*baud                            !Nominal Tx frequency for "0" bit
     f1=baud                        !Nominal Tx frequency for "1" bit

! Unpack sync bits into the first nsync positions of id()
     id=0
     n=isync32
     do j=1,nsync
        if(n.lt.0) id(j)=1
        n=ishft(n,1)
     enddo

! Generate sync waveform
     k=0
     phi=0.
     do j=1,nsync
        if(id(j).eq.1) then
           dphi=twopi*dt*(f1+foffset)
        else
           dphi=twopi*dt*(f0+foffset)
        endif
        do i=1,nsps
           k=k+1
           phi=phi+dphi
           csync(k)=cmplx(cos(phi),sin(phi))
        enddo
     enddo

! Generate the basic waveforms for symbols "0" and "1" 
     phi0=0.
     phi1=0.
     dphi0=twopi*dt*750.0
     dphi1=twopi*dt*1500.0
     do i=1,nsps
        phi0=phi0+dphi0
        phi1=phi1+dphi1
        x0(i)=sin(phi0)
        x1(i)=sin(phi1)
     enddo
  endif

! Find lag and DF
  nfft=512
  nh=nfft/2
  df=fs/nfft
  sbest=0.
  lagmax=min(4000,jz-nh)
  iz=500.0/df
  do lag=0,lagmax
     c=0.
     do i=1,nh
        c(i)=csync(i)*dat(i+lag)
     enddo
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

! Find length of message, nbit
  smax=0.
  do n=1,nstep
     do nsgn=-1,1,2
        i0=lagbest + nsgn*istep(n)
        if(i0.ge.3) then
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

! NB: the computed phase will be off if frequency is inexact!
!  write(*,1060) fbest,lagbest,sbest
!1060 format('Measured  DF:',f8.1,16x,'   lag:',i5,   &
!          '   Sbest:',e12.3)

!  ia=max(1,lagbest-928)
!  ib=min(lagbest+2*928,jz)
!  do i=ia,ib
!     k=mod(i-lagbest-1+9280,928)+1
!     write(73,3101) i-lagbest,0.0033*dat(i),csync(k)
!3101 format(i8,3f12.6)
!  enddo

!! Once more, just for the plot of sq vs freq
!  c=0.
!  do i=1,nh
!     c(i)=csync(i)*dat(i+lagbest)
!  enddo
!  call four2a(c,nfft,1,-1,1)
!  do i=1,nfft
!     sq=real(c(i))**2 + aimag(c(i))**2
!     freq=df*(i-1)
!     if(i.gt.nh+1) freq=df*(i-1-nfft)
!     write(71,2001) freq,1.e-4*sq
!2001 format(2f12.3)
!  enddo

  snrsync=1.e-8*sbest

  return
end subroutine syncms
