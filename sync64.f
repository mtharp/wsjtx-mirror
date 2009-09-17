      subroutine sync64(dat,jz,DFTolerance,NFreeze,MouseDF,
     +  mode64,dtx,dfx,snrx,snrsync,ccfblue,ccfred1,isbest)

C  Synchronizes JT64 data, finding the best-fit DT and DF.  
C  NB: at this stage, submodes ABC are processed in the same way.

      parameter (NP2=30*12000)         !Size of data array
      parameter (NFFTMAX=6480)         !Max length of FFTs
      parameter (NHMAX=NFFTMAX/2)      !Max length of power spectra
      parameter (NSMAX=390)            !Max number of quarter-symbol steps
      integer DFTolerance              !Range of DF search
      real dat(jz)                     !Raw data, downsampled to 6 kHz
      real s2(NHMAX,NSMAX)             !2d spectrum, stepped by half-symbols
      real x(NFFTMAX)                  !Temp array for computing FFTs
      real ccfblue(-5:540)             !CCF with pseudorandom sequence
      real ccfred1(-224:224)           !Peak of ccfblue, as function of freq
      real ccf64(-224:224)
      integer isync(24,3),jsync(24)
      integer ic6(6)                   !Costas array
      data ic6/0,1,4,3,5,2/,idum/-1/


! Set up the JT64 sync pattern
      mode64=1                                  !### temporary ###
      nsync=0
      j=0
      do n=1,4
         i0=0
         if(n.eq.2) i0=27
         if(n.eq.3) i0=54
         if(n.eq.4) i0=81
         do i=1,6
            j=j+1
            isync(j,1)=ic6(i)
            isync(j,2)=ic6(7-i)
            isync(j,3)=5-ic6(i)
            jsync(j)=i0+i
         enddo
      enddo
      nsync=j
      nsym=nsync+63

C  Do FFTs of twice symbol length, stepped by quarter symbols.  
C  NB: we have already downsampled the data by factor of 2.
      nfft=6480
      nh=nfft/2
      nsteps=4*(jz-NH)/nh -1
      kstep=3240/4
      df=0.5*12000.0/nfft

C  Compute power spectrum for each quarter-symbol step
      do j=1,nsteps
         k=(j-1)*kstep + 1
         do i=1,nh
            x(i)=dat(k+i-1)
            x(i+nh)=0.
         enddo
         call ps64(x,nfft,s2(1,j))
      enddo

C  Determine the search range in frequency
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

C  Find best frequency bin and best sync pattern
      syncbest=-1.e30
      ss=0.
      nss=0
      do i=ia,ib
         smax=-1.e30
         do lag=-20,20
            sum1=0.
            sum2=0.
            sum3=0.
            do j=1,nsync
               j0=4*jsync(j) - 3 + lag
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

      ave=ss/nss
      do j=-224,224
         if(ccfred1(j).ne.0.0) ccfred1(j)=0.5*(ccfred1(j)-ave)
      enddo

! Once more, using best frequency and best sync pattern:
      i=ipk
      syncbest=-1.e30
      do lag=-20,20
         sum=0.
         do j=1,nsync
            j0=4*jsync(j) - 3 + lag
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

      return
      end
