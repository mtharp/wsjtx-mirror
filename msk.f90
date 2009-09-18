program msk

! Simulates an MSK signal waveform containing a sync vector and data 
! of specified length.

! "Decodes" the waveform using matched-filter correlators against the
! basic symbol waveforms for "0" amd "1" bits.  

! Computes CCF of sync-vector waveform with the full waveform, to see how
! well the sync can be distinguished from random data.

  parameter (MAXSYM=212)             !Max number of symbols (sync + data)
  parameter (MAXSAM=32*MAXSYM)       !Max number of samples
  integer id(MAXSYM)                 !Sync followed by data in one-bit format
  real x0(32)                        !Waveform for bit=0
  real x1(32)                        !Waveform for bit=1
  real y(MAXSAM)                     !Full waveform for sync and data bits
  real ccf(-MAXSAM:MAXSAM)           !CCF of sync vector with received data
  character*12 arg
  data isync13/Z'f9a80000'/          !13-bit sync
  data isync28/Z'dc444780'/          !28-bit sync
  data isync32/Z'1acffc1d'/          !32-bit sync

  nargs=iargc()
  if(nargs.ne.4) then
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

  isync=isync32
  if(nsync.eq.13) isync=isync13
  if(nsync.eq.28) isync=isync28
  ndata=(nbit+12)*2
  nsym=ndata+nsync
  
  twopi=8*atan(1.)
  dt=1./fs
  baud=fs/nsps
  f0=baud
  f1=0.5*f0

  write(*,1000) fs,baud,f0,f1,nsps
1000 format('fs:',f7.0,'   baud:',f8.1,'   f0:',f8.1,'   f1:',f8.1,    &
          '   nsps:',i3)
  write(*,1002) nbit,ndata,nsync,nsym
1002 format('nbit:',i3,'   ndata:',i4,'   nsync:',i3,'   nsym:',i4)

  id=0
  n=isync
  do j=1,nsync
     id(j)=0
     if(n.lt.0) id(j)=1
     n=ishft(n,1)
  enddo

  j=nsync
  do i=1,ndata
     j=j+1
     call random_number(x)
     if(x.gt.0.5) id(j)=1
  enddo

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

  k=0
  nx0=0
  nx1=0
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
  print*,'Bit errors:',nerr

!  lstep=nsps
  lstep=1
  do lag=0,ndata*nsps,lstep
     sum=0.
     do i=1,nsps*nsync
        sum=sum + y(i)*y(i+lag)
     enddo
     ccf(lag)=2*sum/(nsps*nsync)
     ccf(-lag)=ccf(lag)
  enddo

  do lag=-ndata*nsps,ndata*nsps,lstep
     write(15,1030) float(lag)/nsps,ccf(lag)
1030 format(2f10.3)
  enddo

999 end program msk
