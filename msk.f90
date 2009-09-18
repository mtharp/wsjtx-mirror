program msk

! Simulates an MSK waveform containing a sync vector and data of 
! specified length.

! Decodes the waveform using matched-filter correlators against the
! basic symbol waveforms for "0" amd "1".

! Computes CCF of the sync-vector waveform with the full waveform, to see how
! well the sync can be detected in random (noiseless) data.

  parameter (MAXSYM=212)             !Max number of symbols (sync + data)
  parameter (MAXSAM=32*MAXSYM)       !Max number of samples
  integer id(MAXSYM)                 !Sync followed by data in one-bit format
  real x0(32)                        !Waveform for bit=0
  real x1(32)                        !Waveform for bit=1
  complex cs(1024)                   !Complex waveform for sync bits
  complex c(2048)                    !Work array
  real y(MAXSAM)                     !Full waveform for sync and data bits
  real ccf(-MAXSAM:MAXSAM)           !CCF of sync vector with received data
  character*12 arg
  data isync13/Z'f9a80000'/          !13-bit sync
  data isync28/Z'dc444780'/          !28-bit sync
  data isync32/Z'1acffc1d'/          !32-bit sync

  nargs=iargc()
  if(nargs.ne.5) then
     print*,'Usage: msk fsample nsps nbit nsync'
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

  isync=isync32
  if(nsync.eq.13) isync=isync13
  if(nsync.eq.28) isync=isync28
  ndata=(nbit+12)*2
  nsym=ndata+nsync
  
  twopi=8*atan(1.)
  dt=1./fs
  baud=fs/nsps
  f0=baud + foffset
  f1=0.5*baud + foffset

  write(*,1000) fs,baud,f0,f1,nsps
1000 format('fs:',f7.0,'   baud:',f8.1,'   f0:',f8.1,'   f1:',f8.1,    &
          '   nsps:',i3)
  write(*,1002) nbit,ndata,nsync,nsym
1002 format('nbit:',i3,'   ndata:',i4,'   nsync:',i3,'   nsym:',i4)

  id=0                               !Clear the whole data array
  n=isync
  do j=1,nsync
     if(n.lt.0) id(j)=1              !Insert the sync vector's 1 bits
     n=ishft(n,1)
  enddo

  j=nsync
  do i=1,ndata              !Generate random data bits following the sync bits
     j=j+1
     call random_number(x)
     if(x.gt.0.5) id(j)=1
  enddo

! Generate sync waveform
  k=0
  phi=0.
  do j=1,nsync
     if(id(j).eq.0) dphi=twopi*dt*baud
     if(id(j).eq.1) dphi=0.5*twopi*dt*baud
     do i=1,nsps
        k=k+1
        phi=phi+dphi
        cs(k)=cmplx(cos(phi),sin(phi))
     enddo
  enddo

! Generate simulated waveform, sync + data
  k=0
  phi=0.
  do j=1,nsym
     if(id(j).eq.0) dphi=twopi*dt*f0
     if(id(j).eq.1) dphi=twopi*dt*f1
     do i=1,nsps
        k=k+1
        phi=phi+dphi
        y(k)=sin(phi)
        write(13,1010) k,y(k)
1010    format(i5,f10.3)
     enddo
  enddo

! Generate basic symbol waveforms for "0" and "1" 
  phi0=0.
  phi1=0.
  dphi0=twopi*dt*f0
  dphi1=twopi*dt*f1
  do i=1,nsps
     phi0=phi0+dphi0
     phi1=phi1+dphi1
     x0(i)=sin(phi0)
     x1(i)=sin(phi1)
  enddo

! Decode the waveform using matched-filter, integrate-and-dump correlators.
  k=0
  is=1
  nerr=0
  do j=1,nsym
     s0=0.
     s1=0.
     do i=1,nsps
        k=k+1
        s0=s0 + x0(i)*y(k)
        s1=s1 + x1(i)*y(k)
     enddo
     s0=2*s0/nsps
     s1=2*s1/nsps
     ssym=is*(s1-s0)
     ibit=0
     if(ssym.gt.0) ibit=1
     if(ibit.ne.id(j)) nerr=nerr+1
     write(14,1020) j,id(j),ibit,ibit-id(j),ssym
1020 format(4i5,f10.3)
     if(ssym.gt.0) is=-is
  enddo

! Compute CCF of sync waveform against the whole received waveform
!  lstep=nsps
  lstep=1
  do lag=0,ndata*nsps,lstep
     sum=0.
     do i=1,nsps*nsync
        sum=sum + real(cs(i))*y(i+lag)
     enddo
     ccf(lag)=2*sum/(nsps*nsync)
     ccf(-lag)=ccf(lag)
  enddo

  do lag=-ndata*nsps,ndata*nsps,lstep
     write(15,1030) float(lag)/nsps,ccf(lag)
1030 format(2f10.3)
  enddo

  nfft=512
  df=fs/nfft
  sbest=0.
  do lag=0,ndata*nsps
     c=0.
     do i=1,nsync*nsps
        c(i)=conjg(cs(i))*y(i+lag)
     enddo
     call four1(c,nfft,-1)
     smax=0.
     do i=1,nfft
        sq=real(c(i))**2 + aimag(c(i))**2
        if(sq.gt.smax) then
           smax=sq
           ipk=i
           phapk=atan2(aimag(c(i)),real(c(i)))
        endif
     enddo
     if(smax.gt.sbest) then
        sbest=smax
        fbest=df*(ipk-1)
        phabest=phapk
        lagbest=lag
     endif
  enddo
  if(fbest.gt.0.5*fs) fbest=fbest-fs
  write(*,1060) lagbest,sbest,fbest,57.2957795*phabest
1060 format('Lagbest:',i5,'   Sbest:',f9.1,'   DF:',f7.1,'   phabest:',f6.1)
  write(*,1070) nerr
1070 format('Bit errors:',i4)

999 end program msk
