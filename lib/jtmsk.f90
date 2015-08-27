subroutine jtmsk(id2,narg,line)

! Decoder for JTMSK

  parameter (NMAX=30*12000)
  parameter (NFFTMAX=512*1024)
  integer*2 id2(0:NMAX)
  real d(0:NMAX)
  real xrms(256)
  complex c(NFFTMAX)
  complex cb(66)
  complex cdat(24000)
  integer narg(0:11)
  integer b11(11)
  character*22 msg,msg0                     !Decoded message
  character*80 line(100)
  logical first
  data first/.true./
  data b11/1,1,1,0,0,0,1,0,0,1,0/
  save first,cb,twopi,dt,f0,f1

! Parameters from GUI are in narg():
  nutc=narg(0)                         !UTC
  npts=min(narg(1),NMAX)               !Number of samples in id2 (12000 Hz)
  newdat=narg(3)                       !1==> new data, compute symbol spectra
  minsync=narg(4)                      !Lower sync limit
  npick=narg(5)
  t0=0.001*narg(6)
  t1=0.001*narg(7)
  maxlines=narg(8)                     !Max # of decodes to return to caller
  nmode=narg(9)
  nrxfreq=narg(10)                     !Target Rx audio frequency (Hz)
  ntol=narg(11)                        !Search range, +/- ntol (Hz)

  nline=0
  line(1:100)(1:1)=char(0)
  msg0='                      '

  if(first) then
     j=0
     twopi=8.0*atan(1.0)
     dt=1.0/12000.0
     phi=0.
     f0=1000.0
     f1=2000.0
     do i=1,11
        if(b11(i).eq.0) dphi=twopi*f0*dt
        if(b11(i).eq.1) dphi=twopi*f1*dt
        do n=1,6
           j=j+1
           phi=phi+dphi
           cb(j)=cmplx(cos(phi),sin(phi))
        enddo
     enddo
     first=.false.
     line(1)=""
     msg=""
  endif

  d(0:npts-1)=id2(0:npts-1)
  n=log(float(npts))/log(2.0) + 1.0
  nfft=2**n
  call analytic(d,npts,nfft,c)

  nblks=npts/1404
  k=0
  do j=1,nblks
     sq=0.
     do i=1,1404
        k=k+1
        sq=sq + d(k)*d(k)
     enddo
     xrms(j)=sqrt(sq/1404.0)
  enddo
  call pctile(xrms,nblks,16,base)
  rms=1.25*base
  c=c/rms

  nlen=12000
  nstep=8000
  tstep=nstep/12000.0
  ib=6000
  sigmin=1.3
  do iter=1,999
     if(ib.eq.npts) exit
     ib=ib+nstep
     if(ib.gt.npts) ib=npts
     ia=ib-nlen+1
     iz=ib-ia+1
     cdat(1:iz)=c(ia:ib)
     t0=ia/12000.0
     nsnr=0
     ja=ia/1404 + 1
     jb=ib/1404 + 1
     sig=maxval(xrms(ja:jb))/base
     if(sig.lt.sigmin) cycle
     call syncmsk(cdat,iz,cb,jpk,ipk,idf,rmax,snr,metric,msg)
     if(rmax.lt.2.0) cycle
     freq=f0+idf
     t0=(ia+jpk)/12000.0
     nsnr=db(snr) - 4.0
!     write(81,3020) nutc,snr,t0,freq,ipk,metric,sig,rmax,msg
!3020 format(i6.6,2f5.1,f7.1,2i6,f7.1,f7.2,1x,a22)
     if(msg.ne.'                      ') then
        if(msg.ne.msg0) then
           nline=nline+1
           nsnr0=-99
        endif
        if(nsnr.gt.nsnr0) then
           write(line(nline),1020) nutc,nsnr,t0,nint(freq),msg
1020       format(i6.6,i4,f5.1,i5,3x,a22)
        endif
        nsnr0=nsnr
        msg0=msg
        if(nline.ge.maxlines) exit
     endif
 enddo

  return
end subroutine jtmsk
