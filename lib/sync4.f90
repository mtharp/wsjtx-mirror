subroutine sync4(dat,jz,ntol,emedelay,dttol,nfqso,mode4,minw,    &
     dtx,nfreq,snrx,sync,flip)

! Synchronizes JT4 data, finding the best-fit DT and DF.  

  use jt4
  parameter (NFFTMAX=2520)         !Max length of FFTs
  parameter (NHMAX=NFFTMAX/2)      !Max length of power spectra
  parameter (NSMAX=525)            !Max number of half-symbol steps
  real dat(jz)
  real psavg(NHMAX)                !Average spectrum of whole record
  real ps0(450)                    !Avg spectrum for plotting
  real s2(NHMAX,NSMAX)             !2d spectrum, stepped by half-symbols
  real ccfblue(65)                 !CCF with pseudorandom sequence
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

  call timer('ps4     ',0)
  do j=1,nsteps                 !Compute spectrum for each step, get average
     k=(j-1)*nq + 1
     call ps4(dat(k),nfft,s2(1,j))
     psavg(1:nh)=psavg(1:nh) + s2(1:nh,j)
  enddo
  call timer('ps4     ',1)

  call timer('flat1a  ',0)
  nsmo=min(10*mode4,150)
  call flat1a(psavg,nsmo,s2,nh,nsteps,NHMAX,NSMAX)        !Flatten spectra
  call timer('flat1a  ',1)

  call timer('smo     ',0)
  if(mode4.ge.9) call smo(psavg,nh,tmp,mode4/4)
  i0=132
  do i=1,450
     ps0(i)=5.0*(psavg(i0+2*i) + psavg(i0+2*i+1) - 2.0)
  enddo
  call timer('smo     ',1)

  ia=600.0/df
  ib=1600.0/df
  syncbest=-1.e30
  ccfred=0.
  jmax=-1000
  jmin=1000
  ichpk=1
  ipk=1
  dt=2.0/11025.0
  dtoffset=0.8

!  ichmax=1.0+log(float(mode4))/log(2.0)
  do ich=minw+1,7                     !Find best width
     kz=nch(ich)/2
     savered=.false.
! Set istep>1 for wide submodes?
     do i=ia+kz,ib-kz                     !Find best frequency channel for CCF
        call timer('xcor4   ',0)
        call xcor4(s2,i,nsteps,nsym,ich,mode4,ccfblue,ccf0,lagpk0,flip)
        call timer('xcor4   ',1)
        ccfred(i)=ccf0

! Find rms of the CCF, without main peak
        call timer('slope   ',0)
        call slope(ccfblue,65,float(lagpk0))
        call timer('slope   ',1)
        sync=abs(ccfblue(lagpk0))

! Find best sync value
        nf=nint(i*df)
        dtxx=lagpk0*nq*dt - dtoffset
        if(abs(nf-nfqso).le.ntol .and. abs(dtxx-emedelay).le.dttol .and.  &
             sync.gt.syncbest) then
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
  nfreq=nint(ipk*df)

! Peak up once more in time, at best whole-channel frequency
  call xcor4(s2,ipk,nsteps,nsym,ichpk,mode4,ccfblue,ccfmax,lagpk,flip)
  xlag=lagpk
  if(lagpk.gt.1 .and. lagpk.lt.65) then
     call peakup(ccfblue(lagpk-1),ccfmax,ccfblue(lagpk+1),dx2)
     xlag=lagpk+dx2
  endif

  call slope(ccfblue,65,xlag)

! Find rms of the CCF, without the main peak
  sq=0.
  nsq=0
  do lag=1,65
     if(abs(lag-xlag).gt.2.0) then
        sq=sq+ccfblue(lag)**2
        nsq=nsq+1
     endif
  enddo
  rms=sqrt(sq/nsq)
  sync=max(0.0,db(abs(ccfblue(lagpk)/rms - 1.0)) - 4.5)

  snr0=-26.
  if(mode4.eq.2)  snr0=-25.
  if(mode4.eq.4)  snr0=-24.
  if(mode4.eq.9)  snr0=-23.
  if(mode4.eq.18) snr0=-22.
  if(mode4.eq.36) snr0=-21.
  if(mode4.eq.72) snr0=-20.
  snrx=snr0 + sync
  dtx=xlag*nq*dt - dtoffset

  return
end subroutine sync4

