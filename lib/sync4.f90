subroutine sync4(dat,jz,ntol,emedelay,dttol,nfqso,mode4,minw,    &
     dtx,dfx,snrx,snrsync,flip)

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
  real ccfblue(-5:59)              !CCF with pseudorandom sequence
  real ccfred(NHMAX)
  real redsave(NHMAX)
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

! Set istep>1 for wide submodes?
     do i=ia+kz,ib-kz                     !Find best frequency channel for CCF
        call xcor4(s2,i,nsteps,nsym,lag1,lag2,ich,mode4,ccfblue,ccf0,   &
             lagpk0,flip)
        ccfred(i)=ccf0

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
     if(savered) redsave=ccfred
  enddo

  ccfred=redsave
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

!###
  rewind 71
  rewind 72
  df=0.5*11025.0/2520.0
  do i=ia+kz,ib-kz
     write(71,3001) i,i*df,ccfred(i)
3001 format(i6,2f12.3)
  enddo
  do i=lag1,lag2
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

