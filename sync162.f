      subroutine sync162(c2,jz,dtx,dfx,snrx,snrsync,sstf,kz)

C  Find MEPT_JT sync signals, with best-fit DT and DF.  

      complex c2(jz)
      parameter (NFFT=512)             !Length of FFTs
      parameter (NH=NFFT/2)            !Length of power spectra
      parameter (NSMAX=351)            !Number of half-symbol steps
      real psavg(-NH:NH)               !Average spectrum of whole record
      real s2(-NH:NH,NSMAX)            !2d spectrum, stepped by half-symbols
      real ccfred(-NH:NH)              !Peak of ccfblue, as function of freq
      real ccfblue(-5:540)             !CCF with pseudorandom sequence
      real tmp(513)
      real sstf(4,275)
      save

C  Do FFTs of twice symbol length, stepped by half symbols.  Note that 
C  we have already downsampled the data by factor of 2.

      nsym=162
      nq=NFFT/4
      nsteps=jz/nq - 1
      df=375.0/nfft
      call zero(psavg,NFFT+1)

C  Compute power spectrum for each step, and get average
      do j=1,nsteps
         k=(j-1)*nq + 1
         call ps162(c2(k),s2(-NH,j))
         call add(psavg,s2(-NH,j),psavg,NFFT)
      enddo
      call pctile(psavg(-136),tmp,273,45,base)

      ia=nint(-100.0/df)
      ib=-ia
      i0=0
      lag1=-5
      lag2=20
      syncbest=-1.e30

      call zero(ccfred,745)
      do i=ia,ib
         call xcor162(s2,i,nsteps,nsym,lag1,lag2,ccfblue,ccf0,lagpk0)
         ccfred(i+3)=ccf0
         sync=ccfblue(lagpk0)
         k=i-ia+1
         sstf(1,k)=sync/base
         sstf(3,k)=i
         sstf(4,k)=lagpk0
      enddo

      kz=k
      do k=1,kz
         if(sstf(1,k).lt.1.0) then
            sstf(1,k)=0.
         else
            i1=max(1,k-5)
            i2=min(kz,k+6)
            do i=i1,i2
               if(sstf(1,i).gt.sstf(1,k)) sstf(1,k)=0.
            enddo
         endif
      enddo

      k=0
      do i=1,kz
         if(sstf(1,i).gt.0.0) then
            k=k+1
            sstf(1,k)=sstf(1,i)
            sstf(3,k)=sstf(3,i)
            sstf(4,k)=sstf(4,i)
         endif
      enddo
      kz=k

      do k=1,kz
         ipk=nint(sstf(3,k))
         dfx=(ipk-i0+3)*df

C  Peak up in time, at best whole-channel frequency
         call xcor162(s2,ipk,nsteps,nsym,lag1,lag2,ccfblue,ccfmax,lagpk)
         xlag=lagpk
         if(lagpk.gt.lag1 .and. lagpk.lt.lag2) then
            call peakup(ccfblue(lagpk-1),ccfmax,ccfblue(lagpk+1),dx2)
            xlag=lagpk+dx2
         endif

C  Find rms of the CCF, without the main peak
         sq=0.
         nsq=0
         do lag=lag1,lag2
            if(abs(lag-xlag).gt.2.0) then
               sq=sq+ccfblue(lag)**2
               nsq=nsq+1
            endif
         enddo
         rms=sqrt(sq/nsq)
         snrsync=ccfblue(lagpk)/rms - 8.0           !Empirical

         dt=1.0/375.0
         istart=xlag*nq
         dtx=istart*dt - 2.0
         ppmax=0.
         do i=-4,4
            ppmax=ppmax + psavg(ipk+i)
         enddo
         ppmax=(ppmax/(9.0*base)) - 1.0
         snrx=db(max(ppmax,0.0001)) -23.55          !Empirical
         sstf(1,k)=snrsync
         sstf(2,k)=snrx
         sstf(3,k)=dtx
         sstf(4,k)=dfx
      enddo

      return
      end

