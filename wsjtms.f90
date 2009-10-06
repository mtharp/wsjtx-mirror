subroutine wsjtms(dat,jz,cfile6,MinSigdB,pick,lumsg,lcum,NSyncOK,s2,ps0,psavg)

  parameter (NZMAX=3100)
  real dat(jz)                !Raw audio data
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
  character msg*40,msg3*3,cf*1
  character*90 line
  common/ccom/nline,tping(100),line(100)

!### Placed here for tests ###
  call cs_lock('wsjtms')

  nchan=64                   !Save 64 spectral channels
  nstep=240                  !Set step size to ~20 ms
  nz=jz/nstep                !# of spectra to compute

!  if(.not.pick) then
!     MouseButton=0
!     jza=jz
!     labdat=labdat+1
!  endif
  tbest=0.
  NsyncOK=0


! Compute the 2D spectrum.
  df=12000.0/256.0            !FFT resolution ~47 Hz
  dtbuf=nstep/12000.0
  stlim=nslim2                !Single-tone threshold
  call spec2d(dat,jz,nstep,s2,nchan,nz,psavg,sigma)
  nline0=nline
  npkept=0
  minwidth=40
  nqrn=0
  dftolerance=400
  istart=1

! Decode JTMS mesages.

  slim=MinSigdB
  wmin=0.001*MinWidth * (19.95/20.0)
  nf1=-DFTolerance
  nf2=DFTolerance
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
!        write(*,3001) iping,tstart,peak,mswidth
!3001    format(i5,2f8.2,i5)
        call syncms(dat(jj),max(jjz,6000),snrsync,dfx,lagbest)
        nsnr=nint(db(snrsync)-2.0)
        ndf=nint(dfx)
        dtx=(lagbest+jj-1)*dt
        nrpt=0
        write(11,1010) cfile6,dtx,mswidth,nsnr,nrpt,ndf
1010    format(a6,f6.1,i5,i4,i4,i6)
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
     cf=' '
     if(nline.le.99) nline=nline+1
     tping(nline)=tstart
     write(line(nline),1050) cfile6,tstart,mswidth,int(peak),           &
          nwidth,nstrength,noffset,msg3,msg,cf
1050 format(a6,f5.1,i5,i3,1x,2i1,i5,1x,a3,1x,a40,1x,a1)
100  continue
  enddo

  call s2shape(s2,nchan,nz,tbest)

  call cs_unlock
  return
end subroutine wsjtms

