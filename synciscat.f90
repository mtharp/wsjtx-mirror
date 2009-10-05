subroutine synciscat(dat,jz,DFTolerance,NFreeze,MouseDF,                &
     dtx,dfx,snrx,snrsync,ccfblue,ccfred1,isbest)

! Synchronizes ISCAT data, finding the best-fit DT and DF.  

  parameter (NFFTMAX=1024)         !Max length of FFTs
  parameter (NHMAX=NFFTMAX/2)      !Max length of power spectra
  parameter (NSMAX=2813)           !Max number of quarter-symbol steps
  integer DFTolerance              !Range of DF search
  real dat(jz)                     !Raw data, downsampled to 6 kHz
  real s2(NHMAX,NSMAX)             !2d spectrum, stepped by half-symbols
  real x(NFFTMAX)                  !Temp array for computing FFTs
  real ccfblue(-5:540)             !CCF with pseudorandom sequence
  real ccfred1(-224:224)           !Peak of ccfblue, as function of freq
  real ccf64(-5:540)
  integer isync(10,3)
  integer ic10(10)
  data ic10/0,1,3,7,4,9,8,6,2,5/     !10x10 Costas array

  print*,'a'
! Set up the ISCAT sync pattern
  nsync=10
  do i=1,10
     isync(i,1)=ic10(i)
     isync(i,2)=ic10(11-i)
     isync(i,3)=9-ic10(i)
  enddo
  nsym=nsync+63

! Do FFTs of twice symbol length, stepped by quarter symbols.  
  nfft=1024
  nh=nfft/2
  nsteps=4*(jz-NH)/nh -1
  kstep=nh/4
  df=12000.0/nfft

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
  fbmax=1200.
  f0=700.0
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
  print*,'b',fa,fb,df,ia,ib,i0

! Find best frequency bin and best sync pattern
  syncbest=-1.e30
  ss=0.
  nss=0
  do i=ia,ib
     smax=-1.e30
     do lag=-5,540
        sum1=0.
        sum2=0.
        sum3=0.
        do j=1,nsync
           j0=4*j - 3 + lag
           if(j0.ge.1 .and. j0.le.nsteps) then
              sum1=sum1 + s2(i+2*isync(j,1),j0)
              sum2=sum2 + s2(i+2*isync(j,2),j0)
              sum3=sum3 + s2(i+2*isync(j,3),j0)
           endif
        enddo
        ccf1=sum1/nsync
        ccf2=sum2/nsync
        ccf3=sum3/nsync
        if(ccf1.gt.smax) then
           smax=ccf1
           ispk=1
        endif
        if(ccf2.gt.smax) then
           smax=ccf2
           ispk=2
        endif
        if(ccf3.gt.smax) then
           smax=ccf3
           ispk=3
        endif
     enddo

     j=i-i0
     if(abs(j).le.224) then
        ccfred1(i-i0)=smax
        ss=ss+smax
        nss=nss+1
     endif
     if(smax.gt.syncbest) then
        syncbest=smax
        ipk=i
        isbest=ispk
     endif
  enddo
  print*,'c',ipk,isbest,syncbest

  ave=ss/nss
  do j=-224,224
     if(ccfred1(j).ne.0.0) ccfred1(j)=0.5*(ccfred1(j)-ave)
  enddo

! Once more, using best frequency and best sync pattern:
  i=ipk
  syncbest=-1.e30
  do lag=-5,540
     sum=0.
     do j=1,nsync
        j0=4*j - 3 + lag
        if(j0.ge.1 .and. j0.le.nsteps) then
           sum=sum + s2(i+2*isync(j,isbest),j0)
        endif
     enddo
     ccf64(lag)=sum/nsync
     if(ccf64(lag).gt.syncbest) then
        lagpk=lag
        syncbest=ccf64(lag)
     endif
     ccfblue(lag+15)=ccf64(lag)
  enddo

  sum=0.
  nsum=0
  do j=-5,35
     if(abs(j-15-lagpk).gt.1) then
        sum=sum + ccfblue(j)
        nsum=nsum + 1
     endif
  enddo
  ave=sum/nsum
  do j=-5,35
     ccfblue(j)=ccfblue(j)-ave
  enddo

  snrsync=syncbest/ave - 1.0
  snrx=-31.
  if(syncbest.gt.1.0) snrx=db(snrsync) - 30.5
  dtstep=kstep*2.d0/12000.d0
  dtx=dtstep*lagpk
  dfx=(ipk-i0)*df

  print*,'B',dtx,dfx,snrx,snrsync
  do i=-5,540
     write(55,3001) i,ccfblue(i)
3001 format(i5,f12.3)
  enddo

  do i=-224,224 
     write(56,3001) i,ccfred1(i)
  enddo

  return
end subroutine synciscat
