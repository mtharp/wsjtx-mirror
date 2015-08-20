subroutine jtmsk(id2,narg,line)

! Decoder for JTMSK

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
  character*22 msg                     !Decoded message
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
  ldebug=.true.

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
  nfft=256*1024
  call analytic(d,npts,nfft,c)

  if(ldebug) then
     do i=1,npts,120
        sq1=0.
        sq2=0.
        do n=1,120
           sq1=sq1 + float(id2(i+n-1))**2
           sq2=sq2 + real(c(i+n-1))**2 + aimag(c(i+n-1))**2 
        enddo
        write(13,3001) (i+60)*dt,1.e-6*sq1,0.5e-6*sq2   !Green line
3001    format(f12.3,2f12.3)
     enddo
  endif

  ia=5.5*12000
  ib=6.5*12000
  iz=ib-ia+1
  n=log(float(iz))/log(2.0) + 1.0
  nfft1=2**n                                   !FFT length
  cdat(1:iz)=c(ia:ib)
  call mskdf(cdat,iz,nfft1,f0,ldebug,dfx,snrsq2)      !Get freq offset

  twk=6.0
  call tweak1(cdat,iz,-dfx+twk,cdat2)      !Mix to standard frequency

! DF is known, now establish character sync.

  call syncmsk(cdat2,iz,cb,ldebug,rmax)      !Look for the Barker codes

  return
end subroutine jtmsk
