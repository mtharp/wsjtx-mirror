program ccf

! Correlate two-station recordings for HF Time-of-Arrival project.

  parameter (NFS=12000)
  parameter (NMAX=310*NFS)                   !Max length of data
  parameter (LAGMAX=NFS/50)
  parameter (NFFT=4*1024*1024,NH=NFFT/2)
  integer*2 id1(NMAX),id2(NMAX)              !Sampled data
  real*4 x1(NMAX),x2(NMAX)
  character arg*12                           !Command-line arg
  character*40 file1,file2
  real xc(-LAGMAX:LAGMAX)
  real prof1(NFS),prof2(NFS)
  real*8 p1,p2,samfac
  integer resample
  real xx1(NFFT),xx2(NFFT),xx(NFFT),xx1pps(NFFT)
  real xx1a(NFFT),xx2a(NFFT)
  complex c1(0:NH),c2(0:NH),cc(0:NH)
  complex z1,z2
  complex cal1(35),cal2(35)

  character*4 mode
  character*6 mycall,mygrid
  character*10 ctime
  real*8 fkhz,tsec

  data pi/3.14159265/
  equivalence (xx1,c1),(xx2,c2),(xx,cc)

  nargs=iargc()
  if(nargs.ne.2) then
     print*,'Usage: ccf <file1> <file2>'
     go to 999
  endif

  call getarg(1,file1)
  call getarg(2,file2)
  open(12,file=file1,access='stream',status='old')
  call read_wav(12,id1,npts1,nfs1,nch1)       !Read data from disk
  read(12) tsec,fkhz,mycall,mygrid,mode,ctime     !Retrieve header information
  print*,tsec,fkhz,' ',mycall,' ',mygrid,' ',mode,' ',ctime
  close(12)
  open(12,file=file2,access='stream',status='old')
  call read_wav(12,id2,npts2,nfs2,nch2)
  close(12)

  if(nfs1.ne.NFS .or. nfs2.ne.NFS) then
     print*,'Mismatched sample rates:',nfs1,nfs2
     go to 999
  endif

  npts=min(npts1,npts2)
  dt=1.0/NFS
  df=float(NFS)/NFFT

  do i=1,npts                                 !Convert to floats
     x1(i)=id1(i)
     x2(i)=id2(i)
  enddo
  call getrms(x1,npts1,ave1,rms1,xmax1)       !Get ave, rms
  call getrms(x2,npts1,ave2,rms2,xmax2)
  x1(:npts)=(1.0/rms1)*(x1(:npts)-ave1)       !Remove DC and normalize
  x2(:npts)=(1.0/rms2)*(x2(:npts)-ave2)

  ip1=NFS-1
  ip2=NFS
  call fold1pps(x1,npts,ip1,ip2,prof1,p1,pk1,ipk1)  !Find sample rates
  call fold1pps(x2,npts,ip1,ip2,prof2,p2,pk2,ipk2)

  write(*,1010) 1,NFS,nch1,npts1,ave1,rms1,xmax1,p1,pk1,ipk1
  write(*,1010) 2,NFS,nch2,npts2,ave2,rms2,xmax2,p2,pk2,ipk2
1010 format('File',i2,':',i6,i3,i9,3f8.1,f11.4,f8.1,i6)

! Resample ntype: 0=best, 1=sinc_medium, 2=sinc_fast, 3=hold, 4=linear
  ntype=2
  samfac=NFS/p1
  ierr=resample(x1,xx1,samfac,npts,ntype)    !Resample to NFS Hz, exactly
  if(ierr.ne.0) print*,'Resample error.',samfac
  npts1=samfac*npts

  samfac=NFS/p2
  ierr=resample(x2,xx2,samfac,npts,ntype)
  if(ierr.ne.0) print*,'Resample error.',samfac
  npts2=samfac*npts
  npts=min(npts1,npts2)

  xx1(npts+1:)=0.
  xx2(npts+1:)=0.
  ip=NFS
  i1=ipk1+ip-100
  xx1a(1:npts-i1+1)=xx1(i1:npts)  !Align data so that 1 PPS is at start
  i2=ipk2+ip-100
  xx2a(1:npts-i2+1)=xx2(i2:npts)
  npts=min(npts-i1+1,npts-i2+1)
  xx1a(npts+1:)=0.
  xx2a(npts+1:)=0.

  prof1=0.
  prof2=0.
  do i=1,npts,NFS                           !Fold at p=NFS (exactly)
     prof1=prof1 + xx1a(i:i+ip-1)
     prof2=prof2 + xx2a(i:i+ip-1)
  enddo

  pmin1=0.
  pmin2=0.
  do i=1,ip
     if(prof1(i).lt.pmin1) then
        pmin1=prof1(i)
        ipk1=i
     endif
     if(prof2(i).lt.pmin2) then
        pmin2=prof2(i)
        ipk2=i
     endif
  enddo

  fac1=-1.0/pmin1
  fac2=-1.0/pmin2
  do i=0,ip-1
     i1=ipk1+i
     if(i1.gt.ip) i1=i1-ip
     i2=ipk2+i
     if(i2.gt.ip) i2=i2-ip
     xx1(i+1)=fac1*prof1(i1)
     xx2(i+1)=fac2*prof2(i2)
  enddo

  do i=-20,250
     j=i
     if(j.lt.1) j=j+ip
     write(32,1020) i,1000.0*i*dt,xx1(j),xx2(j)
1020 format(i6,f12.3,2f10.3)
  enddo


  call four2a(xx1,ip,1,-1,0)                !FFTs of 1 PPS profiles
  call four2a(xx2,ip,1,-1,0)

  do j=1,35                                 !Compute calibration arrays
     i=100*j
     z1=0.01*sum(c1(i-50:i+49))
     z2=0.01*sum(c2(i-50:i+49))
     cal1(j)=z1
     cal2(j)=z2
     s1=real(z1)**2 + aimag(z1)**2
     s2=real(z2)**2 + aimag(z2)**2
     pha1=atan2(aimag(z1),real(z1))
     pha2=atan2(aimag(z2),real(z2))
     write(33,3001) i,s1,db(s1),pha1,s2,db(s2),pha2
3001 format(i6,2(f10.0,2f10.3))
  enddo

  xx1=xx1a
  xx2=xx2a
  do i=200,npts,NFS                         !Keep only the 1PPS pulse
     xx1(i:i+NFS-200)=0.
     xx2(i:i+NFS-200)=0.
  enddo

  call four2a(xx1,NFFT,1,-1,0)              !Forward FFTs
  call four2a(xx2,NFFT,1,-1,0)

  fac=1.e-12
  cc=0.
  ia=500.0/df                               !Define rectangular passband
  ib=2500.0/df
  do i=ia,ib
     j=nint(0.01*i*df)
     z1=c1(i)/cal1(j)                       !Apply calibrations
     z2=c2(i)/cal2(j)
     cc(i)=fac*z1*conjg(z2)                 !Multiply transforms
  enddo

  call four2a(cc,NFFT,1,1,-1)               !Inverse FFT to get CCF
  xx1pps=xx*sqrt(NFS/200.0)

  xx1=xx1a
  xx2=xx2a
  do i=1,npts,NFS                           !Keep all but the 1PPS pulse
     xx1(i:i+200)=0.
     xx2(i:i+200)=0.
  enddo

  call four2a(xx1,NFFT,1,-1,0)              !Forward FFTs
  call four2a(xx2,NFFT,1,-1,0)

  fac=1.e-12
  cc=0.
  do i=ia,ib
     j=nint(0.01*i*df)
     z1=c1(i)/cal1(j)                       !Apply calibrations
     z2=c2(i)/cal2(j)
     cc(i)=fac*z1*conjg(z2)                 !Multiply transforms
  enddo

  call four2a(cc,NFFT,1,1,-1)               !Inverse FFT to get CCF

  do i=-30,30
     j=i
     if(j.le.0) j=i+NFFT
     write(31,1110) 1000.0*i*dt,xx1pps(j),xx(j) !Write CCFs to disk
1110 format(1f0.3,2f12.3)
  enddo

999 end program ccf
