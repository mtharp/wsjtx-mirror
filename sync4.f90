subroutine sync4(dat,jz,ntol,NFreeze,MouseDF,mode,mode4,    &
     dtx,dfx,snrx,snrsync,ccfblue,ccfred1,flip,width,ps0)

! Synchronizes JT4 data, finding the best-fit DT and DF.  

  parameter (NFFTMAX=2520)         !Max length of FFTs
  parameter (NHMAX=NFFTMAX/2)      !Max length of power spectra
  parameter (NSMAX=525)            !Max number of half-symbol steps
  integer ntol                     !Range of DF search
  real dat(jz)
  real psavg(NHMAX)                !Average spectrum of whole record
  real ps0(450)                    !Avg spectrum for plotting
  real s2(NHMAX,NSMAX)             !2d spectrum, stepped by half-symbols
  real ccfblue(-5:540)             !CCF with pseudorandom sequence
  real ccfred(-450:450)            !Peak of ccfblue, as function of freq
  real ccfred1(-224:224)           !Peak of ccfblue, as function of freq
  real tmp(1260)
  integer ipk1(1)
  equivalence (ipk1,ipk1a)
  save

! Do FFTs of twice symbol length, stepped by half symbols.  Note that 
! we have already downsampled the data by factor of 2.

  nsym=207
  nfft=2520
  nh=nfft/2
  nq=nfft/4
  nsteps=jz/nq - 1
  df=0.5*11025.0/nfft
  psavg(1:nh)=0.

  do j=1,nsteps                     !Compute spectrum for each step, get average
     k=(j-1)*nq + 1
     call ps4(dat(k),nfft,s2(1,j))
     psavg(1:nh)=psavg(1:nh) + s2(1:nh,j)
  enddo

  nsmo=min(10*mode4,150)
  call flat1(psavg,nsmo,s2,nh,nsteps,NHMAX,NSMAX)        !Flatten spectra

  if(mode4.ge.9) call smo(psavg,nh,tmp,mode4/4)
  i0=132
  do i=1,450
     ps0(i)=5.0*(psavg(i0+2*i) + psavg(i0+2*i+1) - 2.0)
  enddo

! Set freq and lag ranges
  famin=200.
  fbmax=2700.
  fa=famin
  fb=fbmax
  if(NFreeze.eq.1) then
     fa=max(famin,1270.46+MouseDF-ntol)
     fb=min(fbmax,1270.46+MouseDF+ntol)
  else
     fa=max(famin,1270.46+MouseDF-600)
     fb=min(fbmax,1270.46+MouseDF+600)
  endif
  ia=fa/df
  ib=fb/df
  if(mode.eq.7) then
     ia=ia - 3*mode4
     ib=ib - 3*mode4
  endif
  i0=nint(1270.46/df)
  lag1=-5
  lag2=59
  syncbest=-1.e30
  syncbest2=-1.e30
  ccfred=0.
  if(ia-i0.lt.-450) ia=i0-450
  if(ib-i0.gt.450)  ib=i0450
  jmax=-1000
  jmin=1000

  do i=ia,ib                                !Find best frequency channel for CCF

     call xcor4(s2,i,nsteps,nsym,lag1,lag2,mode4,ccfblue,ccf0,lagpk0,flip)
     j=i-i0
     if(mode.eq.7) j=j + 3*mode4
     if(j.ge.-372 .and. j.le.372) then
        ccfred(j)=ccf0
        jmax=max(j,jmax)
        jmin=min(j,jmin)
     endif

! Find rms of the CCF, without main peak
     call slope(ccfblue(lag1),lag2-lag1+1,lagpk0-lag1+1.0)
     sync=abs(ccfblue(lagpk0))
     ppmax=psavg(i)-1.0

! Find best sync value
     if(sync.gt.syncbest2) then
        ipk2=i
        lagpk2=lagpk0
        syncbest2=sync
     endif

! We are most interested if snrx will be more than -30 dB.
     if(ppmax.gt.0.2938) then            !Corresponds to snrx.gt.-30.0
        if(sync.gt.syncbest) then
           ipk=i
           lagpk=lagpk0
           syncbest=sync
        endif
     endif
  enddo

! If we found nothing with snrx > -30 dB, take the best sync that *was* found.
  if(syncbest.lt.-10.) then
     ipk=ipk2
     lagpk=lagpk2
     syncbest=syncbest2
  endif

  dfx=(ipk-i0)*df
  if(mode.eq.7) dfx=dfx + 3*mode4*df

! Peak up in time, at best whole-channel frequency
  call xcor4(s2,ipk,nsteps,nsym,lag1,lag2,mode4,ccfblue,ccfmax,lagpk,flip)
  xlag=lagpk
  if(lagpk.gt.lag1 .and. lagpk.lt.lag2) then
     call peakup(ccfblue(lagpk-1),ccfmax,ccfblue(lagpk+1),dx2)
     xlag=lagpk+dx2
  endif

! Find rms of the CCF, without the main peak
  call slope(ccfblue(lag1),lag2-lag1+1,xlag-lag1+1.0)
  sq=0.
  nsq=0
  do lag=lag1,lag2
     if(abs(lag-xlag).gt.2.0) then
        sq=sq+ccfblue(lag)**2
        nsq=nsq+1
     endif
  enddo
  rms=sqrt(sq/nsq)
  snrsync=abs(ccfblue(lagpk))/rms - 1.1                       !Empirical

  dt=2.0/11025.0
  istart=xlag*nq
  dtx=istart*dt
  snrx=-99.0
  ppmax=psavg(ipk)-1.0

  if(ppmax.gt.0.0001) snrx=db(ppmax*df/2500.0) + 16.5        !Empirical
  if(snrx.lt.-33.0) snrx=-33.0

  ccfred1=0.
  jmin=max(jmin,-224)
  jmax=min(jmax,224)
  do i=jmin,jmax
     ccfred1(i)=ccfred(i)
  enddo

  ipk1=maxloc(ccfred1) - 225
  ns=0
  s=0.
  iw=min(mode4,(ib-ia)/4)
  do i=jmin,jmax
     if(abs(i-ipk1a).gt.iw) then
        s=s+ccfred1(i)
        ns=ns+1
     endif
  enddo
  base=s/ns
  ccfred1=ccfred1-base
  ccf10=0.1*maxval(ccfred1)
  do i=ipk1a,jmin,-1
     if(ccfred1(i).le.ccf10) exit
  enddo
  i1=i
  do i=ipk1a,jmax
     if(ccfred1(i).le.ccf10) exit
  enddo
  width=df*(i-i1)

999 return
end subroutine sync4

