program msk

! Simulates an MSK waveform containing a sync vector and data of 
! specified length.

! Finds sync status (DF and DT) by multiplying received waveform by 
! conjugate of sync pattern, at a range of lags, computing FFT at 
! each lag.  Refine these values and find initial phase, PHA0, by
! looping over small increments in DF and PHA0.  

! Demodulates the waveform by using matched-filter correlators against 
! the basic symbol waveforms for "0" amd "1".  

! Counts the number of hard-decision, single-bit errors in the demodulated
! signal.  The signal should decode correctly if the fraction of such
! errors is less than about 15%.

  parameter (MAXSYM=212)             !Max number of symbols (sync + data)
  parameter (MAXSAM=32*MAXSYM)       !Max number of samples
  integer id(MAXSYM)                 !Sync followed by data in one-bit format
  integer id2(MAXSYM)                !Hard-decision demodulated bits
  integer symbol(MAXSYM)             !Soft-decision symbols
  real x0(32)                        !Waveform for bit=0
  real x1(32)                        !Waveform for bit=1
  complex cs(1024)                   !Complex waveform for sync bits
  complex c(MAXSAM)                  !Work array
  complex cy(MAXSAM)                 !Full waveform for sync and data bits
  complex z0,z1
  real ccf(-MAXSAM:MAXSAM)           !CCF of sync vector with received data
  character arg*12,cerr*3
  data isync13/Z'f9a80000'/          !13-bit sync
  data isync28/Z'dc444780'/          !28-bit sync
  data isync32/Z'1acffc1d'/          !32-bit sync
  data idum/-1/

  nargs=iargc()
  if(nargs.ne.7) then
     print*,'Usage: msk fsample nsps nbit nsync DF Dpha snrdb'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) fs                     !Sample rate
  call getarg(2,arg)
  read(arg,*) nsps                   !Samples per symbol
  call getarg(3,arg)
  read(arg,*) nbit                   !User bits in message
  call getarg(4,arg)
  read(arg,*) nsync                  !Number of sync bits
  call getarg(5,arg)
  read(arg,*) foffset                !Frequency offset of received signal
  call getarg(6,arg)
  read(arg,*) pha0                   !Phase offset of received signal
  call getarg(7,arg)
  read(arg,*) snrdb                  !S/N

  isync=isync32
  if(nsync.eq.13) isync=isync13
  if(nsync.eq.28) isync=isync28
  ndata=(nbit+12)*2                  !Number of data symbols (K=13, r=1/2)
  nsym=ndata+nsync                   !Total number of symbols
  twopi=8*atan(1.0)
  dt=1./fs                           !Sample interval
  baud=fs/nsps                       !Keying rate
  f0=baud                            !Nominal Tx frequency for "0" bit
  f1=0.5*baud                        !Nominal Tx frequency for "1" bit

  write(*,1000) fs,baud,f0,f1,nsps
1000 format('fs:',f7.0,'   baud:',f8.1,'   f0:',f8.1,'   f1:',f8.1,    &
          '   nsps:',i3)
  write(*,1002) nbit,ndata,nsync,nsym
1002 format('nbit:',i3,'   ndata:',i4,'   nsync:',i3,'   nsym:',i4)
  write(*,1004) foffset,pha0
1004 format('Generated DF:',f8.1,'   Dpha:',f8.1)

! First, do several setup tasks.
! Unpack the sync bits into the first nsync positions of id()
  id=0
  n=isync
  do j=1,nsync
     if(n.lt.0) id(j)=1
     n=ishft(n,1)
  enddo

! Fill id(nsym) with random data bits following the sync bits
  j=nsync
  do i=1,ndata
     j=j+1
     call random_number(x)
     if(x.gt.0.5) id(j)=1
  enddo

! Generate the sync waveform
  k=0
  phi=0.
  do j=1,nsync
     if(id(j).eq.0) dphi=twopi*dt*f0
     if(id(j).eq.1) dphi=twopi*dt*f1
     do i=1,nsps
        k=k+1
        phi=phi+dphi
        cs(k)=cmplx(cos(phi),sin(phi))
     enddo
  enddo

! Generate basic symbol waveforms for "0" and "1" 
!  phi0=twopi/8.               !This gives Dpha=0.
!  phi1=twopi/8.
  phi0=0.                      !This gives Dpha=45 deg
  phi1=0.
  dphi0=twopi*dt*f0
  dphi1=twopi*dt*f1
  do i=1,nsps
     x0(i)=sin(phi0)
     x1(i)=sin(phi1)
     phi0=phi0+dphi0
     phi1=phi1+dphi1
  enddo

! Generate the whole Tx waveform, sync + data, using foffset and pha0.
  snr=10.0**(0.05*snrdb)
  fac=0.707/snr
  k=0
  phi=pha0/57.2957795
  do j=1,nsym
     if(id(j).eq.0) dphi=twopi*dt*(f0+foffset)
     if(id(j).eq.1) dphi=twopi*dt*(f1+foffset)
     do i=1,nsps
        k=k+1
        phi=phi+dphi
        xx=cos(phi) + fac*gasdev(idum)
        yy=sin(phi) + fac*gasdev(idum)
        cy(k)=cmplx(xx,yy)
!        write(13,1010) k,cy(k)
!1010    format(i5,2f10.3)
     enddo
  enddo

! Find the (presumably unknown) lag and DF
  nfft=512
  df=fs/nfft
  sbest=0.
  do lag=0,ndata*nsps
     c=0.
     do i=1,nsync*nsps
        c(i)=conjg(cs(i))*cy(i+lag)
     enddo
     call four1(c,nfft,-1)
     smax=0.
     do i=1,nfft
        sq=real(c(i))**2 + aimag(c(i))**2
        if(sq.gt.smax) then
           smax=sq
           ipk=i
        endif
     enddo
     if(smax.gt.sbest) then
        sbest=smax
        fbest=df*(ipk-1)
        lagbest=lag
     endif
  enddo
  if(fbest.gt.0.5*fs) fbest=fbest-fs
! NB: this computed phase will be off if frequency is inexact!
  write(*,1060) fbest,lagbest,sbest
1060 format('Measured  DF:',f8.1,16x,'   lag:',i5,   &
          '   Sbest:',f9.1)

! Shift the received signal in frequency by small increments around
! fbest, looking for maximum sq.
! NB: might be better to use the "fchisq" method?  (However, beware
! the oscillatory nature of si and sq vs nn.)
  dsqpk=0.
  nn=0
  do idf=-12,12                            !Try freq offsets over +/- 12 Hz
     fshift=nint(fbest)+idf
     do iph=-4,4                           !Try phases over +/- 90 deg
        phi=(22.5*iph)/57.2957795
        dphi=twopi*dt*fshift
        do i=1,nsps*nsym
           phi=phi+dphi
           c(i)=cy(i)*cmplx(cos(phi),-sin(phi))
        enddo

! Decode the waveform using matched-filter, integrate-and-dump correlators.
        k=0
        is=1
        nerr=0
        si=0.
        sq=0.
        do j=1,nsym
           z0=0.
           z1=0.
           do i=1,nsps
              k=k+1
              z0=z0 + x0(i)*c(k)
              z1=z1 + x1(i)*c(k)
           enddo
           s0=real(z0)
           s1=real(z1)
           s0=2*s0/nsps
           s1=2*s1/nsps
           ssym=is*(s1-s0)
           si=si + ssym*ssym

           s0=aimag(z0)
           s1=aimag(z1)
           s0=2*s0/nsps
           s1=2*s1/nsps
           ssym=is*(s1-s0)
           sq=sq + ssym*ssym

           ibit=0
           if(ssym.gt.0.0) ibit=1
           if(ibit.ne.id(j)) nerr=nerr+1
           if(ssym.gt.0.0) is=-is
        enddo
!        dsq=sq-si
        dsq=sq/si
        if(dsq.gt.dsqpk) then
           dsqpk=dsq
           sqpk=sq
           fpk=fshift
           ierr=nerr
           iphpk=iph
        endif
        nn=nn+1
!        write(17,3001) nn,fshift,22.5*iph,si,sq,dsq,nerr
!3001    format(i5,2f8.1,3f10.1,i5)
     enddo
  enddo
  cerr='   '
  write(*,1022) fpk,22.5*iphpk,sqpk
1022 format('Refined   DF:',f8.1,'   Dpha:',f8.1,16x,'sqpk:',f9.1)
  if(ierr.gt.0) cerr='***'
  write(*,1024) ierr,cerr,100.0*float(ierr)/nsym
1024 format('Bit errors:',i4,1x,a3,f8.1,'%')

!Do it once more, using best params

  fshift=fpk
  phi=(22.5*iphpk)/57.2957795
  dphi=twopi*dt*fshift
  do i=1,nsps*nsym
     phi=phi+dphi
     c(i)=cy(i)*cmplx(cos(phi),-sin(phi))
  enddo

! Decode the waveform using matched-filter, integrate-and-dump correlators.
  k=0
  is=1
  nerr=0
  si=0.
  sq=0.
  do j=1,nsym
     z0=0.
     z1=0.
     do i=1,nsps
        k=k+1
        z0=z0 + x0(i)*c(k)
        z1=z1 + x1(i)*c(k)
     enddo
     s0=real(z0)
     s1=real(z1)
     s0=2*s0/nsps
     s1=2*s1/nsps
     ssym=is*(s1-s0)
     si=si + ssym*ssym
     
     s0=aimag(z0)
     s1=aimag(z1)
     s0=2*s0/nsps
     s1=2*s1/nsps
     ssym=is*(s1-s0)
     sq=sq + ssym*ssym
     symbol(j)=nint(10.0*ssym)

     ibit=0
     if(ssym.gt.0.0) ibit=1
     if(ibit.ne.id(j)) nerr=nerr+1
     if(ssym.gt.0.0) is=-is
     id2(j)=ibit
  enddo

  do j=1,nsym
     idiff=id2(j)-id(j)
     write(12,1040) j,id(j),id2(j),idiff,symbol(j)
     if(id2(j).ne.id(j)) write(13,1040) j,id(j),id2(j),idiff,symbol(j)
1040 format(4i5,i10)
  enddo

999 end program msk
