program wwv

! Find time delay between 1 PPS ticks from GPS and WWV.

  parameter (NFSMAX=48000)
  parameter (NMAX=310*NFSMAX)                !Max length of data
  integer*2 id(NMAX)                         !Raw data
  character arg*12                           !Command-line arg
  character cdate*8                          !CCYYMMDD
  character ctime*10                         !HHMMSS.SSS
  character*120 cmnd0,cmnd                   !Command to set rig frequency
  character*4 cwwv
  character*6 mycall,mygrid
  real*8 tsec,tsec0,fkhz,p1,samfac
  real x1(NMAX),xx1(NMAX)
  real prof1(NFSMAX)
  real tick1(NFSMAX/200)
  real ccf1(0:NFSMAX/40)
  integer soundin
  integer resample
  integer nkhz(0:4)
  data nkhz/2500,5000,10000,15000,20000/
  data nloop/-1/,nHz0/-99/

  nargs=iargc()
  if(nargs.ne.4) then
     print*,'Usage:    wwv  <fsample> <f_kHz> <nsave> <nsec>'
     print*,'Example:  wwv    48000    10000     0      60'
     go to 999
  endif

  call getarg(1,arg)
  read(arg,*) nfs                      !Sample rate (Hz)
  call getarg(2,arg)
  read(arg,*) fkhz                     !Rx frequency (kHz)
  call getarg(3,arg)
  read(arg,*) nsave                    !nsave=1 to save all profiles and ccfs
  call getarg(4,arg)
  read(arg,*) nsec                     !Duration of each recording (s)

  open(10,file='fmt.ini',status='old',err=910)
  read(10,'(a120)') cmnd0              !Get rigctl command to set frequency
  read(10,*) ndevin
  read(10,*) mycall
  read(10,*) mygrid
  close(10)

  open(16,file='delay.dat',status='unknown',position='append')
  open(20,file='wwv.bin',form='unformatted',status='unknown',position='append')


  call soundinit                             !Initialize Portaudio

  npts=nfs*nsec
  nchan=1
  dt=1.0/nfs

  do i=1,nfs/200
     tick1(i)=sin(6.283185307*1000.0*dt*i)
  enddo

  call getutc(cdate,ctime,tsec0)

10 nloop=nloop+1

  if(fkhz.gt.0.d0) then
     nHz=nint(1.d3*fkhz)
  else
     nHz=1000*nkhz(mod(nloop,5))
  endif
  
  if(nHz.ne.nHz0) then
     cmnd=cmnd0
     i1=index(cmnd,' F ')
     write(cmnd(i1+2:),*) nHz                   !Insert desired frequency
     iret=system(cmnd)                          !Set Rx frequency
     if(iret.ne.0) then
        print*,'Error executing rigctl command to set frequency:'
        print*,cmnd
        go to 999
     endif

     cmnd(i1+1:)='M AM 0'
     iret=system(cmnd)                          !Set Rx mode
     if(iret.ne.0) then
        print*,'Error executing rigctl command to set Rx mode:'
        print*,cmnd
        go to 999
     endif
     nHz0=nHz
  endif

  call getutc(cdate,ctime,tsec)

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

!  do i=1,ip
!     write(13,1020) 1000.0*i*dt,prof1(i)
!1020 format(f12.3,f10.3)
!  enddo

!  ia=-0.002/dt
!  ib=+0.025/dt
!  do i=ia,ib
!     j=i+ipk
!     if(j.lt.1) j=j+ip
!     if(j.gt.ip) j=j-ip
!     write(14,1030) 1000.0*i*dt,prof1(j)
!1030 format(f12.3,f10.3)
!  enddo

  lag1=nint(nfs*0.002)
  lagmax=nfs/40
  ccf1=0.
  ccfmax1=0.
  do lag=lag1,lagmax
     s1=0.
     do i=1,nfs/200
        j=ipk+lag+i-1
        if(j.gt.ip) j=j-ip
        s1=s1 + tick1(i)*prof1(j)
     enddo
     ccf1(lag)=s1
     if(ccf1(lag).gt.ccfmax1) then
        ccfmax1=ccf1(lag)
        lagpk1=lag
     endif
  enddo

!  fac=1.0/ccfmax1
!  do lag=0,lagmax
!     write(15,1040) 1000.0*lag*dt,fac*ccf1(lag)
!1040 format(f9.3,2f10.6)
!  enddo

  delay=1000.0*lagpk1*dt
  hrs=mod(tsec,86400.d0)/3600
  read(cdate(7:8),*) nday
  day=nday + hrs/24.0
  ikhz=nhz/1000
  write(*,1012)  cdate,ctime(:6),day,delay,ccfmax1,ikhz,p1,mycall,mygrid
  write(16,1012) cdate,ctime(:6),day,delay,ccfmax1,ikhz,p1,mycall,mygrid
1012 format(a8,2x,a6,f11.5,f8.2,f10.3,i7,f10.2,1x,a6,1x,a6)

!  call flush(13)
!  call flush(14)
!  call flush(15)
  call flush(16)

  if(nsave.gt.0) then
     write(20)  cdate,ctime(:6),day,delay,ccfmax1,ikhz,p1,mycall,mygrid,  &
          prof1(:ip),ccf1(:lagmax)
     call flush(20)
  endif

  go to 10

910 print*,'Cannot open file: fmt.ini'

999 end program wwv
