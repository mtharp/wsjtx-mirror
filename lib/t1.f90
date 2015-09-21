program t1

  parameter (NSPM=1404)
  complex csig(0:NSPM-1)
  complex c(0:NSPM-1)
  complex cnoise(0:NSPM-1)
  complex cd(0:11,0:3)
  integer itone(234)
  real r(234)
  character*12 arg

  nargs=iargc()
  if(nargs.ne.2) then
     print*,'Usage: t1 nsymtest snr'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) nsymtest
  call getarg(2,arg)
  read(arg,*) snr

  call random_number(r)
  itone=0
  where(r.gt.0.5) itone=1

  twopi=8.0*atan(1.0)
  fmid=1500.0
  f0=fmid-500.
  f1=fmid+500.
  dt=1.0/12000.0

  phi=0.
  do n=0,3
     k=-1
     dphi=twopi*f0*dt
     if(n.ge.2) dphi=twopi*f1*dt
     do i=1,6
        k=k+1
        phi=phi+dphi
        if(phi.gt.twopi) phi=phi-twopi
        cd(k,n)=cmplx(cos(phi),sin(phi))
     enddo

     dphi=twopi*f0*dt
     if(mod(n,2).eq.1) dphi=twopi*f1*dt
     do i=1,6
        k=k+1
        phi=phi+dphi
        if(phi.gt.twopi) phi=phi-twopi
        cd(k,n)=cmplx(cos(phi),sin(phi))
     enddo
  enddo

  do k=0,11
     write(13,1000) k,cd(k,0:3)
1000 format(i4,8f9.3)
enddo

! Generate Tx waveform
  k=-1
  phi=0.
  do j=1,234
     dphi=twopi*f0*dt
     if(itone(j).eq.1) dphi=twopi*f1*dt
     do i=1,6
        k=k+1
        phi=phi+dphi
        if(phi.gt.twopi) phi=phi-twopi
        csig(k)=cmplx(cos(phi),sin(phi))
        write(14,1000) k,csig(k)
     enddo
  enddo

  do i=0,NSPM-1
     x=gran()
     y=gran()
     cnoise(i)=cmplx(x,y)
  enddo

  c=csig + cnoise/snr
  nerr=0
  n1=2
  nstep=2
  iz=5
  if(nsymtest.eq.2) then
     n1=3
     nstep=1
     iz=11
  endif

  do j=1,233
     smax=0.
     do n=0,n1,nstep
        s=0.
        k=6*(j-1)
        do i=0,iz
           s=s + aimag(c(k+i))*aimag(cd(i,n))
        enddo
        if(abs(s).gt.abs(smax)) then
           smax=s
           npk=n
        endif
     enddo
     ibit=npk/2
     if(ibit.ne.itone(j)) nerr=nerr+1
  enddo

  write(*,1020) nerr
1020 format('nerr:',i4)

999 end program t1

