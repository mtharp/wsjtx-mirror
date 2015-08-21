subroutine jtmsk(id2,narg,line)

! Decoder for JTMSK
! Files used for debugging output:
!   71 - total power ("green line"), 10 ms steps
!   72 - spectrum of squared complex signal
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
  character*22 msg                     !Decoded message
  character*80 line(100)
  logical first,ldebug
  integer*8 count0,count1,clkfreq
  common/mskcom/tmskdf,tsync,tsoft,tvit,ttotal
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
  ldebug=.false.

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

! Normalize the data
  sq=0.
  do i=1,npts
     sq=sq + real(c(i))**2 + aimag(c(i))**2
  enddo
  rms=sqrt(sq/npts)
  c=c/rms

  if(ldebug) then
     do i=1,npts,120
        sq1=0.
        sq2=0.
        do n=1,120
           sq1=sq1 + float(id2(i+n-1))**2
           sq2=sq2 + real(c(i+n-1))**2 + aimag(c(i+n-1))**2 
        enddo
        write(71,3001) (i+60)*dt,1.e-6*sq1,0.5e-6*sq2   !Green line
3001    format(f12.3,2f12.3)
     enddo
  endif

  nlen=12000
  nstep=6000
  ib=6000
  do iter=1,999
     ib=ib+nstep
     if(ib.gt.npts) exit
     ia=ib-nlen+1 
!###
!     if(iter.gt.1) exit
!     ia=8.0*12000
!     ib=ia+12000-1
     snrsq2=20
!     dfx=1134.0-1000.0
     dfx=1126.3-1000.0
     if(mod(nutc,10).ne.0) dfx=1073.7-1000.0
!###

     iz=ib-ia+1
     n=log(float(iz))/log(2.0) + 1.0
     nfft1=2**n                                   !FFT length
     cdat(1:iz)=c(ia:ib)
!     call mskdf(cdat,iz,nfft1,f0,ldebug,dfx,snrsq2)      !Get freq offset
     t0=ia/12000.0
     nsnr=0
!     print*,f0,dfx,f0+dfx

     if(snrsq2.ge.15.0) then
        do idf=1,11
           itry=idf/2
           if(mod(idf,2).eq.0) itry=-itry
           twk=-6.0 + itry*0.5                  !Why the 6 Hz offset ???
           call tweak1(cdat,iz,-(dfx+twk),cdat2)     !Mix to standard frequency
! DF is known, now establish sync and decode the message
           call syncmsk(cdat2,iz,cb,ldebug,ipk,jpk,rmax,metric,msg)
           write(81,3020) nutc,nsnr,t0,nint(f0+dfx+twk),ipk,metric,rmax,  &
                snrsq2,itry,msg
3020       format(i6.6,i5,f5.1,i6,2i6,f7.2,f7.1,i4,2x,a22)
           if(msg.ne.'                      ') then
              write(*,1020) nutc,nsnr,t0,nint(f0+dfx+twk),msg,ipk,metric,   &
                   rmax,snrsq2,itry
1020          format(i6.6,i5,f5.1,i6,2x,a22,2i6,f7.2,f7.0,i4)
              exit
           endif
        enddo
     else
        write(81,3020) nutc,nsnr,t0,nint(f0+dfx+twk),0,0,0.0,snrsq2,0
     endif

  enddo

  return
end subroutine jtmsk
