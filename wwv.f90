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
  real xcal(NFSMAX)
  real w(NFSMAX/200)                         !Waveform of WWV tick
  real ccf1(0:NFSMAX/40)
  integer soundin
  integer resample
  integer nkhz(0:4)
  data nkhz/2500,5000,10000,15000,20000/
  data nloop/-1/,nHz0/-99/

  nargs=iargc()
  if(nargs.lt.1 .or. nargs.gt.2) then
     print*,'Usage: wwv cal <nsec>'
     print*,'       wwv <f_kHz>'
     print*,'       wwv all'
     go to 999
  endif

  open(10,file='fmt.ini',status='old',err=910)  !Open this WSPR file
  read(10,'(a120)') cmnd0              !Get rigctl command to set frequency
  read(10,*) ndevin                    !Get audio device number
  read(10,*) mycall                    !Get my callsign
  read(10,*) mygrid                    !Get my grid locator
  close(10)

  nfs=48000                                  !Sample rate
  dt=1.0/nfs
  nchan=1                                    !Single-channel recording
  call soundinit                             !Initialize Portaudio

  call getarg(1,arg)
  if(arg.eq.'cal' .or. arg.eq.'CAL') then
     call getarg(2,arg)                      !This is a CAL measurement
     read(arg,*) nsec
     call calobs(nfs,nsec,ndevin,id,x1,prof1)
     go to 999
  endif

  fkhz=0.
  if(arg.ne.'all' .and. arg.ne.'ALL') read(arg,*) fkhz    !Rx frequency (kHz)

  open(10,file='cal.dat',status='old',err=920) !Open previously recorded cal.dat
  read(10,1000) p1                            !Get measured sample rate
1000 format(76x,f12.4)
  do i=1,nfs                                  !Read the cal profile
     read(10,1002) xcal(i)
1002 format(10x,f10.3)
  enddo
  close(10)

  open(16,file='delay.dat',status='unknown',position='append')
  open(20,file='wwv.bin',form='unformatted',status='unknown',position='append')

  do i=1,nfs/200                             !Generate the WWV tick waveform
     w(i)=sin(6.283185307*1000.0*dt*i)
  enddo
  npts=nfs*51

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
  do while (ctime(5:6).ne.'01')
     call getutc(cdate,ctime,tsec)
     call msleep(100)
  enddo

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

  rewind 14
  ia=-0.002/dt
  ib=+0.025/dt
  do i=ia,ib
     j=i+ipk
     if(j.lt.1) j=j+ip
     if(j.gt.ip) j=j-ip
     write(14,1030) 1000.0*i*dt,prof1(j)
1030 format(f12.3,f10.3)
  enddo

  lag1=nint(nfs*0.002)
  lagmax=nfs/40
  ccf1=0.
  ccfmax1=0.
  do lag=lag1,lagmax
     s1=0.
     do i=1,nfs/200
        j=ipk+lag+i-1
        if(j.gt.ip) j=j-ip
        s1=s1 + w(i)*prof1(j)
     enddo
     ccf1(lag)=s1
     if(ccf1(lag).gt.ccfmax1) then
        ccfmax1=ccf1(lag)
        lagpk1=lag
     endif
  enddo

  rewind 15
  fac=1.0/ccfmax1
  do lag=0,lagmax
     write(15,1040) 1000.0*lag*dt,fac*ccf1(lag)
1040 format(f9.3,2f10.6)
  enddo

  delay=1000.0*lagpk1*dt
  hrs=mod(tsec,86400.d0)/3600
  read(cdate(7:8),*) nday
  day=nday + hrs/24.0
  ikhz=nhz/1000
  write(*,1012)  cdate,ctime(:6),day,delay,ccfmax1,ikhz,p1,mycall,mygrid
  write(16,1012) cdate,ctime(:6),day,delay,ccfmax1,ikhz,p1,mycall,mygrid
1012 format(a8,2x,a6,f11.5,f8.2,f10.3,i7,f10.2,1x,a6,1x,a6)

!  call flush(13)
  call flush(14)
  call flush(15)
  call flush(16)

  if(nsave.gt.0) then
     write(20)  cdate,ctime(:6),day,delay,ccfmax1,ikhz,p1,mycall,mygrid,  &
          prof1(:ip),ccf1(:lagmax)
     call flush(20)
  endif

  go to 10

910 print*,'Cannot open file: fmt.ini'
  go to 999
920 print*,'Cannot open file: cal.dat'
  go to 999

999 end program wwv
