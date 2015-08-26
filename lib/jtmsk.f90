subroutine jtmsk(id2,narg,line)

! Decoder for JTMSK
! Files used for debugging output:
!   71 - total power ("green line"), 10 ms steps
!   72 - 
!   73 - ccf used for the DF search
!   74 - symbol#, cb, cdat, z, abs(z) phi
!   75 - k, sym, phi, ibit

  parameter (NMAX=30*12000)
  parameter (NFFTMAX=512*1024)
  integer*2 id2(0:NMAX)
  real d(0:NMAX)
  complex c(NFFTMAX)
  complex cb(66)
  complex cdat(24000)
  complex cdat2(24000)
  integer narg(0:11)
  integer b11(11)
  character*22 msg,msg0                     !Decoded message
  character*80 line(100)
  logical first,ldebug
  data first/.true./
  data b11/1,1,1,0,0,0,1,0,0,1,0/
  save first,cb,twopi,dt,f0,f1

! Parameters from GUI are in narg():
  nutc=narg(0)                         !UTC
  npts=min(narg(1),NMAX)               !Number of samples in id2 (12000 Hz)
  npts=npts/2
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
  ldebug=.false.
!  ldebug=.true.

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

! Normalize the data, using minimum rms in a 1-second stretch.
  rmsmin=1.e30
  k=0
  do i=2400,npts-14400,12000
     sq=0.
     do n=1,12000
        sq=sq + real(c(i+n-1))**2 + aimag(c(i+n-1))**2
     enddo
     rms=sqrt(sq/12000)
     rmsmin=min(rms,rmsmin)
     k=k+1
  enddo
  rms=rmsmin
  c=c/rms

  if(ldebug) then
     do i=1,npts,600
        sq=0.
        do n=1,600
           sq=sq + real(c(i+n-1))**2 + aimag(c(i+n-1))**2 
        enddo
        sq=0.5*sq/600.0
        write(71,3001) (i+300)*dt,sq,db(sq)               !Green line
3001    format(3f12.3)
     enddo
  endif

  nlen=12000
  nstep=6000
  tstep=nstep/12000.0
  ib=6000
  do iter=1,999
     ib=ib+nstep
     if(ib.gt.npts) exit
     ia=ib-nlen+1
     iz=ib-ia+1
     cdat(1:iz)=c(ia:ib)
     t0=ia/12000.0
     nsnr=0
     cdat2(1:iz)=cdat(1:iz)
     call syncmsk(cdat2,iz,cb,ldebug,jpk,ipk,idf,rmax,snr,metric,msg)
     freq=f0+idf
     t0=(ia+jpk)/12000.0
     nsnr=db(snr) - 4.0
     write(81,3020) nutc,snr,t0,freq,ipk,metric,rmax,msg
3020 format(i6.6,2f5.1,f7.1,2i6,f7.2,1x,a22)
     if(msg.ne.'                      ') then
        if(msg.ne.msg0) then
           nline=nline+1
           nsnr0=-99
        endif
        if(nsnr.gt.nsnr0) write(line(nline),1020) nutc,nsnr,t0,   &
             nint(freq),msg,ipk,metric,rmax,idf
1020    format(i6.6,i5,f5.1,i6,1x,a22,2i6,f7.2,i4)
        nsnr0=nsnr
        msg0=msg
        if(nline.ge.maxlines) exit
     endif
  enddo

  return
end subroutine jtmsk
