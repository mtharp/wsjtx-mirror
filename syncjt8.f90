subroutine syncjt8(dat,jz,DFTolerance,NFreeze,MouseDF,dtx,dfx,snrx,      &
     snrsync,ccfblue,ccfred,s3)

! Synchronizes JT8 data, finding the best-fit DT and DF.  
! NB: data are already downsampled to 6 kHz.

  parameter (NP2=30*12000)         !Size of data array
  parameter (NFFTMAX=4200)         !Max length of FFTs
  parameter (NHMAX=NFFTMAX/2)      !Max length of power spectra
  parameter (NSMAX=590)            !Max number of quarter-symbol steps
  integer DFTolerance              !Range of DF search
  real dat(jz)                     !Raw data, downsampled to 6 kHz
  real s2(NHMAX,NSMAX)             !2d spectrum, stepped by half-symbols
  real s3(8,124)                   !2d spectrum, synchronized, data only
  real x(NFFTMAX)                  !Temp array for computing FFTs
  real ccfblue(-5:540)             !CCF with pseudorandom sequence
  real ccfred(-224:224)            !Peak of ccfblue, as function of freq
  integer ic8(8)                   !Costas array, 8x8
  data ic8/3,6,2,4,5,0,7,1/

  mousedf=0                        !### tests only ###
! Set up the JT8 sync pattern
  nsync=2*8                        !16 sync symbols
  ndata=((78+15)*4)/3              !124 data symbols
  nsym=nsync+ndata                 !Total of 140 symbols

! Do FFTs of twice symbol length, stepped by quarter symbols.  
! NB: we have already downsampled the data by factor of 2.
  nfft=4200
  nh=nfft/2
  nsteps=min(4*(jz-NH)/nh,NSMAX)
  kstep=nfft/8
  df=6000.0/nfft

! Compute power spectrum for each quarter-symbol step
  do j=1,nsteps
     k=(j-1)*kstep + 1
     do i=1,nh
        x(i)=dat(k+i-1)
        x(i+nh)=0.
     enddo
     call ps(x,nfft,s2(1,j))
  enddo

! Determine the search range in frequency
  famin=3.
  fbmax=2700.
  f0=1270.46
  fa=famin
  fb=fbmax
  if(NFreeze.eq.1) then
     fa=max(famin,f0+MouseDF-DFTolerance)
     fb=min(fbmax,f0+MouseDF+DFTolerance)
  else
     fa=max(famin,f0+MouseDF-600)
     fb=min(fbmax,f0+MouseDF+600)
  endif
  ia=fa/df
  ib=fb/df
  i0=nint(f0/df)

! Find best frequency bin and best sync pattern
  syncbest=-1.e30
  ss=0.
  nss=0
  do i=ia,ib
     smax=-1.e30
     do lag=-5,30
        sum=0.
        do j=1,8
           j0=4*j - 3 + lag
           if(j0.ge.1 .and. j0.le.nsteps) then
              sum=sum + s2(i+2*ic8(j),j0)+ s2(i+2*ic8(j),j0+528)
           endif
        enddo
        ccf=sum/16.0
        if(ccf.gt.smax) then
           smax=ccf
           lagpk=lag
        endif
     enddo

     j=i-i0
     if(abs(j).le.224) then
        ccfred(i-i0)=smax
        ss=ss+smax
        nss=nss+1
     endif
     if(smax.gt.syncbest) then
        syncbest=smax
        lagbest=lagpk
        ipk=i
     endif
  enddo

  ave=ss/nss
  do j=-224,224
     if(ccfred(j).ne.0.0) ccfred(j)=0.5*(ccfred(j)-ave)
!     write(61,3001) j*df,ccfred(j)
!3001 format(2f12.3)
  enddo

! Once more, using best frequency and best sync pattern:
  do lag=-5,30
     sum=0.
     do j=1,8
        j0=4*j - 3 + lag
        if(j0.ge.1 .and. j0.le.nsteps) then
           sum=sum + s2(ipk+2*ic8(j),j0)+ s2(ipk+2*ic8(j),j0+528)
        endif
     enddo
     ccfblue(lag)=sum/16.
  enddo

  sum=0.
  nsum=0
  do j=-5,30
     if(abs(j-lagbest).gt.1) then
        sum=sum + ccfblue(j)
        nsum=nsum + 1
     endif
  enddo
  ave=sum/nsum
  do j=-5,30
     ccfblue(j)=4*(ccfblue(j)-ave)
!     write(62,3002) j,ccfblue(j)
!3002 format(i5,f12.3)
  enddo

  do i=1,8
     ii=ipk + 2*(i-1)
     j0=4*8 - 3 + lagbest
     do j=1,124
        s3(i,j)=s2(ii,j0+4*j)
     enddo
  enddo

  snrsync=syncbest/ave - 1.0
  snrx=-31.
  if(syncbest.gt.1.0) snrx=db(snrsync) - 27.0
  dtstep=kstep*2.d0/12000.d0
  dtx=dtstep*lagbest - 1.0
  dfx=(ipk-i0)*df
  
  return
end subroutine syncjt8
