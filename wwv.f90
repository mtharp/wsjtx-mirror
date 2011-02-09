program wwv

! Find time delay from GPS to WWV.

  parameter (NFSMAX=48000)
  parameter (NMAX=300*NFSMAX)                !Max length of data
  parameter (NFFTMAX=4*1024*1024,NHMAX=NFFTMAX/2)
  integer*2 id1(NMAX)                        !Sampled data
  real*4 x1(NMAX)
  character arg*12                           !Command-line arg
  character*40 infile
  character ctime*10                         !HHMMSS.SSS
  character*4 mode
  character*6 mycall,mygrid
  real*8 fkhz,tsec
  real prof1(NFSMAX)
  real*8 p1,samfac
  integer resample
  real xx1(NFFTMAX)
  real xx1a(NFFTMAX)
  complex c1(0:NHMAX)
  complex z1
  complex cal1(35)
  data pi/3.14159265/
  equivalence (xx1,c1)

  nargs=iargc()
  if(nargs.ne.1) then
     print*,'Usage: wwv <infile>'
     go to 999
  endif

  call getarg(1,infile)
  open(10,file=infile,access='stream',status='old')
  call read_wav(10,id1,npts,nfs,nch)              !Read data from disk
  read(10) tsec,fkhz,mycall,mygrid,mode,ctime     !Get header information
  close(10)

  write(*,1000) mycall,mygrid,ctime
1000 format('Station: ',a6,'   Locator: ',a6,'   Start time: ',a10)

  open(32,file='prof.dat',status='unknown')

  dt=1.0/nfs

  do i=1,npts                                 !Convert to floats
     x1(i)=id1(i)
  enddo
  call averms(x1,npts,ave1,rms1,xmax1)       !Get ave, rms
  write(*,1010) npts,ave1,rms1,xmax1
1010 format('Npts:',i9,'   Ave:',f8.1,'   Rms:',f8.1,'   Max:',f8.1)
  x1(:npts)=(1.0/rms1)*(x1(:npts)-ave1)       !Remove DC and normalize

  ip1=nfs-1
  ip2=nfs
  call fold1pps(x1,npts,ip1,ip2,prof1,p1,pk1,ipk1)  !Find sample rates
  write(*,1011) nfs,p1
1011 format('Sample rate:',i6,' Hz nominal,',f11.3,' Hz measured.')

! Resample ntype: 0=best, 1=sinc_medium, 2=sinc_fast, 3=hold, 4=linear
  ntype=1
  samfac=nfs/p1
  ierr=resample(x1,xx1,samfac,npts,ntype)    !Resample to nfs Hz, exactly
  if(ierr.ne.0) print*,'Resample error.',samfac
  npts=samfac*npts

  ip=nfs
  i1=ipk1+ip-100
  xx1a(1:npts-i1+1)=xx1(i1:npts)  !Align data so that 1 PPS is near start
  npts=npts-i1+1

  prof1=0.
  do i=1,npts,nfs                           !Fold at p=nfs (exactly)
     prof1(:ip)=prof1(:ip) + xx1a(i:i+ip-1)
  enddo

  pmin1=0.
  do i=1,ip
     if(prof1(i).lt.pmin1) then
        pmin1=prof1(i)
        ipk1=i
     endif
  enddo

  fac1=-1.0/pmin1
  do i=0,ip-1
     i1=ipk1+i
     if(i1.gt.ip) i1=i1-ip
     xx1(i+1)=fac1*prof1(i1)
  enddo

  do i=-20,250
     j=i
     if(j.lt.1) j=j+ip
     write(32,1020) 1000.0*i*dt,xx1(j)
1020 format(f12.3,f10.3)
  enddo

999 end program wwv
