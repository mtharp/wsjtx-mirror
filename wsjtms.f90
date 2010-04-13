subroutine wsjtms(dat,jz,istart,cfile6,MinSigdB,NFreeze,MouseDF,        &
     DFTolerance,pick,NSyncOK,s2,ps0,psavg)

  parameter (NZMAX=3100)
  real dat(jz)                      !Raw audio data
  integer DFTolerance
  real ps0(431)           !Spectrum of best ping  (###correct dimension?###)
  real s2(64,NZMAX)        !2D spectral array
  logical pick
  character*6 cfile6
  real sigdb(NZMAX)             !Detected signal in dB, sampled at 20 ms
  real work(NZMAX)
  integer indx(NZMAX)
  real pingdat(3,100)
  real ps(128)
  real psavg(450)
  character msg*40,msg3*3,c1*1,decoded*24
  character*90 line
  common/ccom/nline,tping(100),line(100)

  nchan=64                   !Save 64 spectral channels
  nstep=240                  !Set step size to ~20 ms
  nz=jz/nstep                !# of spectra to compute
  tbest=0.
  NsyncOK=0

  if(.not.pick) then
     MouseButton=0
     jza=jz
  endif

! Compute the 2D spectrum.
  df=12000.0/256.0            !FFT resolution ~47 Hz
  dtbuf=nstep/12000.0
  stlim=nslim2                !Single-tone threshold
  call spec2d(dat,jz,nstep,s2,nchan,nz,psavg,sigma)
  do i=1,128
     psavg(i)=db(psavg(i))
  enddo

  nline0=nline
  npkept=0
  minwidth=40
  nqrn=0

! Decode JTMS mesages.

  slim=MinSigdB
  wmin=0.001*MinWidth * (19.95/20.0)
  msg3='   '
  dt=1.0/12000.0
  
! Find signal power at suitable intervals to search for pings.
! Probably should filter the data first, matching the nominal JTMS spectrum.
  istep=240
  dtbuf=istep/12000.
  do n=1,nz
     s=0.
     ib=n*istep
     ia=ib-istep+1
     do i=ia,ib
        s=s+dat(i)**2
     enddo
     sigdb(n)=s/istep                       !This is power, not yet in dB
  enddo

!#####################################################################
  if(.not.pick) then
! Remove initial transient from sigdb
     call indexx(nz,sigdb,indx)
     imax=0
     do i=1,50
        if(indx(i).gt.50) go to 10
        imax=max(imax,indx(i))
     enddo
10   do i=1,50
        if(indx(nz+1-i).gt.50) go to 20
        imax=max(imax,indx(nz+1-i))
     enddo
20   imax=imax+6            !Safety margin
     base1=sigdb(indx(nz/2))
     do i=1,imax
        sigdb(i)=base1
     enddo
  endif
!##################################################################

  call smooth(sigdb,nz)

! Remove baseline (and one dB for good measure?)
  call pctile (sigdb,work,nz,50,base1)
  do i=1,nz
     sigdb(i)=dB(sigdb(i)/base1)             ! - 1.0
  enddo

  call ping(sigdb,nz,dtbuf,slim,wmin,pingdat,nping)

! If this is a "mouse pick" and no ping was found, force a pseudo-ping 
! at center of data.
  if(pick.and.nping.eq.0) then
     if(nping.le.99) nping=nping+1
     pingdat(1,nping)=0.5*jz*dt
     pingdat(2,nping)=0.16
     pingdat(3,nping)=1.0
  endif

  bigpeak=0.
  do iping=1,nping
! Find starting place and length of data to be analyzed:
     tstart=pingdat(1,iping)
     width=pingdat(2,iping)
     peak=pingdat(3,iping)
     mswidth=10*nint(100.0*width)
     jj=(tstart-0.02)/dt
     if(jj.lt.1) jj=1
     jjz=nint((width+0.02)/dt)+1
     jjz=min(jjz,jz+1-jj)

     if(tstart.lt.29.5) then
! Look for the JTMS sync pattern
        jz2=max(jjz,6000)
        if(jz2.gt.65536) jz2=65536
        call syncms(dat(jj),jz2,NFreeze,MouseDF,DFTolerance,snrsync,   &
             dfx,lagbest,isbest,nerr,metric,decoded)
!        if(isbest.gt.0) call msksymbol(dat(jj),max(jjz,6000),dfx,lagbest,isbest)
        nsnr=nint(db(snrsync)-2.0)
        ndf=nint(dfx)
        dtx=(lagbest+istart+jj-1)*dt
        nrpt=16
        if(mswidth.ge.120) nrpt=26
        if(mswidth.gt.1000) nrpt=36
        if(nsnr.ge.6) nrpt=nrpt+1
        if(nsnr.ge.9) nrpt=nrpt+1
        c1=' '
        if(nsnr.ge.2 .and. isbest.ne.0) c1='*'
        call cs_lock('wsjtms')
        write(11,1010) cfile6,dtx,mswidth,nsnr,nrpt,ndf,isbest,c1,    &
             decoded,nerr,metric
        write(21,1010) cfile6,dtx,mswidth,nsnr,nrpt,ndf,isbest,c1,    &
             decoded,nerr,metric
1010    format(a6,f6.1,i5,i4,i4,i6,i3,a1,2x,a24,i7,i5)
        call cs_unlock
     endif

! Compute average spectrum of this ping.
     call spec441(dat(jj),jjz,ps,f0)

! Decode the message.
!###
     nwidth=0
     nstrength=0
     noffset=0
!###

! If it's the best ping yet, save the spectrum:
     if(peak.gt.bigpeak) then
        bigpeak=peak
        do i=1,128
           ps0(i)=db(ps(i))
        enddo
     endif

     tstart=tstart + dt*(istart-1)
     c1=' '
     if(nline.le.99) nline=nline+1
     tping(nline)=tstart
!     write(line(nline),1050) cfile6,tstart,mswidth,int(peak),           &
!          nwidth,nstrength,noffset,msg3,msg,c1
!1050 format(a6,f5.1,i5,i3,1x,2i1,i5,1x,a3,1x,a40,1x,a1)
  enddo

  call s2shape(s2,nchan,nz,tbest)

  return
end subroutine wsjtms

