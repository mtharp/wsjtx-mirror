subroutine filbig(dd,npts,f0,newdat,c4a,n4)

! Filter and real data in array dd(npts), sampled at 12000 Hz.
! Output is complex, sampled at 1375.125 Hz.

  parameter (NFFT1=672000,NFFT2=77175)
  real*4  dd(npts)                           !Input data
  complex ca(NFFT1)                          !FFT of input
  complex c4a(NFFT2)                         !Output data
  real*8 df
  real halfpulse(8)                 !Impulse response of filter (one sided)
  complex cfilt(NFFT2)                       !Filter (complex; imag = 0)
  real rfilt(NFFT2)                          !Filter (real)
  integer*8 plan1,plan2,plan3
  logical first
  include 'fftw3.f90'
  equivalence (rfilt,cfilt)
  data first/.true./,npatience/1/
  data halfpulse/114.97547150,36.57879257,-20.93789101,              &
       5.89886379,1.59355187,-2.49138308,0.60910773,-0.04248129/
  save

  if(npts.lt.0) go to 900

  if(first) then
     nflags=FFTW_ESTIMATE
     if(npatience.eq.1) nflags=FFTW_ESTIMATE_PATIENT
     if(npatience.eq.2) nflags=FFTW_MEASURE
     if(npatience.eq.3) nflags=FFTW_PATIENT
     if(npatience.eq.4) nflags=FFTW_EXHAUSTIVE
! Plan the FFTs just once
     call timer('FFTplans ',0)
     call sfftw_plan_dft_1d(plan1,nfft1,ca,ca,FFTW_BACKWARD,nflags)
     call sfftw_plan_dft_1d(plan2,nfft2,c4a,c4a,FFTW_FORWARD,nflags)
     call sfftw_plan_dft_1d(plan3,nfft2,cfilt,cfilt,FFTW_BACKWARD,nflags)
     call timer('FFTplans ',1)

! Convert impulse response to filter function
     do i=1,nfft2
        cfilt(i)=0.
     enddo
     fac=0.00625/nfft1
     cfilt(1)=fac*halfpulse(1)
     do i=2,8
        cfilt(i)=fac*halfpulse(i)
        cfilt(nfft2+2-i)=fac*halfpulse(i)
     enddo
     call timer('FFTfilt ',0)
     call sfftw_execute(plan3)
     call timer('FFTfilt ',1)

     base=cfilt(nfft2/2+1)
     do i=1,nfft2
        rfilt(i)=real(cfilt(i))-base
     enddo

     df=12000.d0/nfft1
     first=.false.
  endif

! When new data comes along, we need to compute a new "big FFT"
! If we just have a new f0, continue with the existing ca and cb.

  if(newdat.ne.0) then
     nz=min(npts,nfft1)
     ca(1:nz)=dd(1:nz)
     ca(nz+1:)=0.                   !### Should change this to r2c FFT ###
     call timer('FFTbig  ',0)
     call sfftw_execute(plan1)
     call timer('FFTbig  ',1)
!###
!     nadd=50
!     iz=NFFT1/(2*nadd)
!     df=nadd*12000.0/NFFT1
!     k=0
!     do i=1,iz
!        ss=0.
!        do j=1,nadd
!           k=k+1
!           ss=ss + real(ca(k))**2 + aimag(ca(k))**2
!        enddo
!        write(81,3001) i*df,ss,db(ss)
!3001    format(f12.3,e12.3,f12.3)
!     enddo
!###        
     newdat=0
  endif

! NB: f0 is the frequency at which we want our filter centered.
!     i0 is the bin number in ca and cb closest to f0.

  i0=nint(f0/df) + 1
  nh=nfft2/2
  do i=1,nh                                !Copy data into c4a and c4b,
     j=i0+i-1                              !and apply the filter function
     if(j.ge.1 .and. j.le.nfft1) then
        c4a(i)=rfilt(i)*ca(j)
     else
        c4a(i)=0.
     endif
  enddo
  do i=nh+1,nfft2
     j=i0+i-1-nfft2
     if(j.lt.1) j=j+nfft1                  !nfft1 was nfft2
     c4a(i)=rfilt(i)*ca(j)
  enddo

! Do the short reverse transform, to go back to time domain.
  call timer('FFTsmall',0)
  call sfftw_execute(plan3)
  call timer('FFTsmall',1)
  n4=min(npts/8,nfft2)
  return

900 call sfftw_destroy_plan(plan1)
  call sfftw_destroy_plan(plan2)
  call sfftw_destroy_plan(plan3)
  
  return
end subroutine filbig
