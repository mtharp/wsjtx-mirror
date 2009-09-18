program msk

  parameter (NZ=32*124)
  integer id(NZ)
  real x0(32),x1(32)
  real y(NZ)
  real ccf(-NZ:NZ)
  character*12 arg
  data isync32/Z'1acffc1d'/                    !32-bit
  data isync28/Z'dc444780'/                    !28-bit
  data isync13/Z'f9c80000'/                    !13-bit

  nargs=iargc()
  if(nargs.ne.3) then
     print*,'Usage: msk fsample nsps nsync'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) fs
  call getarg(2,arg)
  read(arg,*) nsps
  call getarg(3,arg)
  read(arg,*) nsync

  isync=isync32
  if(nsync.eq.13) isync=isync13
  if(nsync.eq.28) isync=isync28
  
  twopi=8*atan(1.)
  dt=1./fs
  baud=fs/nsps
  f0=baud
  f1=0.5*f0
  ndata=(50+12)*2
  ntot=ndata+nsync

  write(*,1000) fs,baud,f0,f1,nsps
1000 format('fs:',f7.0,'   baud:',f8.1,'   f0:',f8.1,'   f1:',f8.1,    &
          '   nsps:',i3)

  n=isync
  do j=1,nsync
     id(j)=0
     if(n.lt.0) id(j)=1
     n=ishft(n,1)
  enddo

  do j=nsync+1,NZ
     id(j)=0
     call random_number(x)
     if(x.gt.0.5) id(j)=1
  enddo

  phi=0.
  k=0
  nx0=0
  nx1=0
  do j=1,ntot
     if(id(j).eq.0) dphi=twopi*dt*baud
     if(id(j).eq.1) dphi=0.5*twopi*dt*baud
     do i=1,nsps
        k=k+1
        phi=phi+dphi
        y(k)=cos(phi)
        if(id(j).eq.0 .and. nx0.eq.0) then
           x0(i)=y(k)
           nx0=1
        else if(id(j).eq.1 .and. nx1.eq.0) then
           x1(i)=y(k)
           nx1=1
        endif
        write(13,1010) k,float(k)/nsync,y(k)
1010    format(i5,3f10.3)
     enddo
  enddo

  do i=1,nsps
     write(12,1012) i,x0(i),x1(i)
1012 format(i5,2f10.3)
  enddo

  k=0
  is=1
  nerr=0
  do j=1,ntot
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

  lstep=nsps
!  lstep=1
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

  print*,'Bit errors:',nerr

999 end program msk
