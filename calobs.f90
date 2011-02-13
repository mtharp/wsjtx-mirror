subroutine calobs(nfs,nsec,ndevin,id,x1,prof1)

  parameter (NFSMAX=48000)
  parameter (NMAX=310*NFSMAX)                !Max length of data
  integer*2 id(NMAX)                         !Raw data
  real*8 p1,samfac
  real x1(NMAX),xx1(NMAX)
  real prof1(NFSMAX)
  integer soundin,resample

  npts=nfs*nsec
  nchan=1
  ierr=soundin(ndevin,nfs,id,npts,nchan-1)   !Get audio data
  if(ierr.ne.0) then
     print*,'Error in soundin',ierr
     stop
  endif

  do i=1,npts                                 !Convert to floats
     x1(i)=id(i)
  enddo
  call averms(x1,npts,ave1,rms1,xmax1)        !Get ave, rms
  x1(:npts)=(1.0/rms1)*(x1(:npts)-ave1)       !Remove DC and normalize

  ip1=nfs-1
  ip2=nfs
  call fold1pps(x1,npts,ip1,ip2,prof1,p1,pk1,ipk1)  !Find sample rates

! Resample ntype: 0=best, 1=sinc_medium, 2=sinc_fast, 3=hold, 4=linear
  ntype=1
  samfac=nfs/p1
  ierr=resample(x1,xx1,samfac,npts,ntype)    !Resample to nfs Hz, exactly
  if(ierr.ne.0) print*,'Resample error.',samfac
  npts=samfac*npts

  ip=nfs
  prof1=0.
  do i=1,npts,nfs                           !Fold at p=nfs (exactly)
     prof1(:ip)=prof1(:ip) + xx1(i:i+ip-1)
  enddo
  if(pk1.lt.0.0) prof1(:ip)=-prof1(:ip)

  pk=0.
  do i=1,ip
     if(prof1(i).gt.pk) then
        pk=prof1(i)
        ipk=i
     endif
  enddo
  prof1(:ip)=prof1(:ip)/pk

  write(*,1000) ave1,rms1,xmax1,p1
1000 format('Ave:',f8.2,'   Rms:',f8.2,'   Max:',f8.0,'   Fsample:',f12.4)

  open(10,file='cal.dat',status='unknown')
  write(10,1010) 0.0,0.0,ave1,rms1,xmax1,p1
1010 format(2f10.3,'   Ave:',f8.2,'   Rms:',f8.2,'   Max:',f8.0,         &
          '   Fsample:',f12.4)

  dt=1.0/nfs
  i0=ipk-nint(0.002/dt)
  do i=0,ip-1
     j=i+i0
     if(j.lt.1) j=j+ip
     if(j.gt.ip) j=j-ip
     write(10,1030) 1000.0*i*dt,prof1(j)
1030 format(2f10.3)
  enddo
  close(10)

  return
end subroutine calobs
