subroutine sync4(dat,jz,ntol,emedelay,dttol,nfqso,mode4,minw,    &
     dtx,dfx,snrx,snrsync,flip,width)

! Synchronizes JT4 data, finding the best-fit DT and DF.  

  use jt4
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
  real red(-450:450)               !Peak of ccfblue, as function of freq
  real ccfred1(-224:224)           !Peak of ccfblue, as function of freq
  real tmp(1260)
  integer ipk1(1)
  logical savered
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

  do j=1,nsteps                 !Compute spectrum for each step, get average
     k=(j-1)*nq + 1
     call ps4(dat(k),nfft,s2(1,j))
     psavg(1:nh)=psavg(1:nh) + s2(1:nh,j)
  enddo

  nsmo=min(10*mode4,150)
  call flat1a(psavg,nsmo,s2,nh,nsteps,NHMAX,NSMAX)        !Flatten spectra

  if(mode4.ge.9) call smo(psavg,nh,tmp,mode4/4)
  i0=132
  do i=1,450
     ps0(i)=5.0*(psavg(i0+2*i) + psavg(i0+2*i+1) - 2.0)
  enddo

! Set freq and lag ranges
  famin=200.0 + 3*mode4*df
  fbmax=2700.0 - 3*mode4*df
  nfmid=nfqso + nint(1.5*mode4*4.375)
  fa=max(famin,float(nfmid-ntol))
  fb=min(fbmax,float(nfmid+ntol))
  ia=fa/df - 3*mode4                   !Index of lowest tone, bottom of range
  ib=fb/df - 3*mode4                   !Index of lowest tone, top of range
  i0=nint(1270.46/df)
  irange=450
  if(ia-i0.lt.-irange) ia=i0-irange
  if(ib-i0.gt.irange)  ib=i0+irange

  thsym=1.0/(2.0*4.375)
  lag1=-5
  lag2=59
!  lag1=(0.8+emedelay-dttol)/thsym
!  lag2=(0.8+emedelay+dttol)/thsym

  syncbest=-1.e30
  ccfred=0.
  jmax=-1000
  jmin=1000
  ichpk=1
  ipk=1

  do ich=minw+1,7                       !Find best width
     kz=nch(ich)/2
     savered=.false.
     do i=ia+kz,ib-kz                     !Find best frequency channel for CCF
        call xcor4(s2,i,nsteps,nsym,lag1,lag2,ich,mode4,ccfblue,ccf0,   &
             lagpk0,flip)
        j=i-i0 + 3*mode4
        if(j.ge.-372 .and. j.le.372) then
           ccfred(j)=ccf0
           jmax=max(j,jmax)
           jmin=min(j,jmin)
        endif

! Find rms of the CCF, without main peak
        call slope(ccfblue(lag1),lag2-lag1+1,lagpk0-lag1+1.0)
        sync=abs(ccfblue(lagpk0))

! Find best sync value
        if(sync.gt.syncbest) then
           ipk=i
           lagpk=lagpk0
           ichpk=ich
           syncbest=sync
           savered=.true.
        endif
     enddo
     if(savered) red=ccfred
  enddo

  ccfred=red
!  width=df*nch(ichpk)
  dfx=(ipk-i0 + 3*mode4)*df

! Peak up in time, at best whole-channel frequency
  call xcor4(s2,ipk,nsteps,nsym,lag1,lag2,ichpk,mode4,ccfblue,ccfmax,   &
       lagpk,flip)
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
  snrsync=max(0.0,db(abs(ccfblue(lagpk)/rms - 1.0)) - 4.5)
  snrx=-26.
  if(mode4.eq.2)  snrx=-25.
  if(mode4.eq.4)  snrx=-24.
  if(mode4.eq.9)  snrx=-23.
  if(mode4.eq.18) snrx=-22.
  if(mode4.eq.36) snrx=-21.
  if(mode4.eq.72) snrx=-20.
  snrx=snrx + snrsync

  dt=2.0/11025.0
  istart=xlag*nq
  dtx=istart*dt
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
  ccf10=0.5*maxval(ccfred1)
  do i=ipk1a,jmin,-1
     if(ccfred1(i).le.ccf10) exit
  enddo
  i1=i
  do i=ipk1a,jmax
     if(ccfred1(i).le.ccf10) exit
  enddo
  width=(i-i1)*df

!  write(*,3301) emedelay,lag1*0.1142857,lag2*0.1142857,dtx,dtx-0.8
!3301 format(5f8.3)


!###
  rewind 71
  rewind 72
  df=0.5*11025.0/2520.0
  do i=-224,224
     write(71,3001) i,i*df,ccfred1(i)
3001 format(i6,2f12.3)
  enddo
  do i=-5,540
     write(72,3001) i,i*(2520.0/2.0)/11025.0,ccfblue(i)
  enddo
  do i=1,450
     write(73,3001) i,i*df,ps0(i)
  enddo
  flush(71)
  flush(72)
  flush(73)
!###



  return
end subroutine sync4

