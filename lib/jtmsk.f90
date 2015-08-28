subroutine jtmsk(id2,narg,line)

! Decoder for JTMSK

  parameter (NMAX=30*12000)
  parameter (NFFTMAX=512*1024)
  parameter (NSPM=1404)                !Samples per JTMSK message
  integer*2 id2(0:NMAX)                !Raw i*2 data, up to T/R = 30 s
  real d(0:NMAX)                       !Raw r*4 data
  real xrms(256)                       !Rms in 117 ms segments
  complex c(NFFTMAX)                   !Complex (analytic) data
  complex cdat(24000)                  !Short segments, up to 2 s
  integer narg(0:11)                   !Arguments passed from calling pgm
  character*22 msg,msg0                !Decoded message
  character*80 line(100)               !Decodes passed back to caller

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
  nsnr0=-99
  nline=0
  line(1:100)(1:1)=char(0)
  msg0='                      '
  msg=msg0

  d(0:npts-1)=id2(0:npts-1)
  n=log(float(npts))/log(2.0) + 1.0
  nfft=2**n
  call analytic(d,npts,nfft,c)         !Convert to analytic signal

  nblks=npts/NSPM
  k=0
  do j=1,nblks                         !Find rms in segments of 117 ms
     sq=0.
     do i=1,NSPM
        k=k+1
        sq=sq + d(k)*d(k)
     enddo
     xrms(j)=sqrt(sq/NSPM)
  enddo
  call pctile(xrms,nblks,16,base)      !Get base, an estimate of baseline rms
  rms=1.25*base
  c=c/rms

  nlen=12000
  nstep=8000
  tstep=nstep/12000.0
  ib=nlen-nstep
  sigmin=1.04
  do iter=1,999
     if(ib.eq.npts) exit               !Previous one had ib=npts, we're done
     ib=ib+nstep
     if(ib.gt.npts) ib=npts
     ia=ib-nlen+1
     iz=ib-ia+1
     cdat(1:iz)=c(ia:ib)               !Select nlen complex samples
     t0=ia/12000.0
     nsnr=0
     ja=ia/NSPM + 1
     jb=ib/NSPM + 1
     sig=maxval(xrms(ja:jb))/rms       !Check sig level relative to baseline
     if(sig.lt.sigmin) cycle           !Don't process if too weak to decode
     call syncmsk(cdat,iz,jpk,ipk,idf,rmax,snr,metric,msg)
     if(rmax.lt.2.0) cycle             !No output is no significant sync
     freq=1500.0+idf
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
1020       format(i6.6,i4,f5.1,i5,' & ',a22)
        endif
        nsnr0=nsnr
        msg0=msg
        if(nline.ge.maxlines) exit
     endif
  enddo
  if(line(1)(1:6).eq.'      ') line(1)(1:1)=char(0)

  return
end subroutine jtmsk
