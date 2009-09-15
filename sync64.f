      subroutine sync64(dat,jz,DFTolerance,NFreeze,MouseDF,
     +  mode64,dtx,dfx,snrx,snrsync,ccfblue,ccfred1,flip,width)

C  Synchronizes JT64 data, finding the best-fit DT and DF.  
C  NB: at this stage, submodes ABC are processed in the same way.

      parameter (NP2=30*12000)         !Size of data array
      parameter (NFFTMAX=3500)         !Max length of FFTs
      parameter (NHMAX=NFFTMAX/2)      !Max length of power spectra
      parameter (NSMAX=180)            !Max number of half-symbol steps
      integer DFTolerance              !Range of DF search
      real dat(jz)
      real s2(NHMAX,NSMAX)             !2d spectrum, stepped by half-symbols
      real ccfblue(-5:540)             !CCF with pseudorandom sequence

C  The value 450 is empirical:
      real ccfred1(-224:224)           !Peak of ccfblue, as function of freq
      real ccf64(-224:224)
      integer ic6(6)
      integer isync(81)
      data ic6/0,1,4,3,5,2/,idum/-1/

!      rewind 61
!      write(61) jz,dat,DFTolerance,NFreeze,MouseDF,mode64

! Set up the JT64 sync pattern
      isync=-1
      do n=1,3
         i0=0
         if(n.eq.2) i0=36
         if(n.eq.3) i0=75
         do i=1,6
            isync(i0+i)=ic6(i)
         enddo
      enddo
      nsync=18

C  Do FFTs of symbol length, stepped by half symbols.  Note that we have
C  already downsampled the data by factor of 2.
      nsym=81
      nfft=3500
      nsteps=2*jz/nfft - 1
      nh=nfft/2
      df=0.5*12000.0/nfft

C  Compute power spectrum for each step
      do j=1,nsteps
         k=(j-1)*nh + 1
!         call limit(dat(k),nfft)
         call ps64(dat(k),nfft,s2(1,j))
         if(mode64.eq.4) call smooth(s2(1,j),nh)
      enddo

C  Find the best frequency channel for CCF
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
      syncbest=-1.e30

C### Following code probably needs work!
      ss=0.
      nss=0
      do i=ia,ib
         smax=-1.e30
         do lag=-20,20
            sum=0.
            do j=1,nsym
               if(isync(j).ge.0) then
                  j0=2*j -1 + lag
                  if(j0.ge.1 .and. j0.le.nsteps) then
                     sum=sum + s2(isync(j)+i,j0)
                  endif
               endif
            enddo
            ccf64(lag)=sum/nsync
            if(ccf64(lag).gt.smax) smax=ccf64(lag)
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
         endif
      enddo
      ave=ss/nss
      syncbest=syncbest-ave
      do j=-224,224
         if(ccfred1(j).ne.0.0) ccfred1(j)=0.5*(ccfred1(j)-ave)
      enddo

! Once more, at the best frequency
      i=ipk
      syncbest=-1.e30

      dtstep=nh*2.d0/12000.d0
      do lag=-20,20
         sum=0.
         do j=1,nsym
            if(isync(j).ge.0) then
               j0=2*j - 1 + lag
               if(j0.ge.1 .and. j0.le.nsteps) then
                  sum=sum + s2(isync(j)+i,j0)
               endif
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

      snrsync=syncbest-ave
      snrx=-30
      if(syncbest.gt.2.0) snrx=db(syncbest) - 34.0
      dtx=dtstep*lagpk
      dfx=(ipk-i0)*df

      return
      end

