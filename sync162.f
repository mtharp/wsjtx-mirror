      subroutine sync162(c2,jz,dtx,dfx,snrx,snrsync,sstf,kz)

C  Find MEPT_JT sync signals, with best-fit DT and DF.  

      complex c2(jz)
      parameter (NFFT=512)             !Length of FFTs
      parameter (NH=NFFT/2)            !Length of power spectra
      parameter (NSMAX=351)            !Number of half-symbol steps
      real psavg(-NH:NH)               !Average spectrum of whole record
      real psmo(-NH:NH)
      real s2(-NH:NH,NSMAX)            !2d spectrum, stepped by half-symbols
      real ccfred(-NH:NH)              !Peak of ccfblue, as function of freq
      real ccfblue(-5:540)             !CCF with pseudorandom sequence
      real tmp(513)
      real sstf(8,275)
      real a(5)
      save

C  Do FFTs of twice symbol length, stepped by half symbols.  Note that 
C  we have already downsampled the data by factor of 2.

      dt=1.0/375.0
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

      do i=-nh+2,nh-2
         psmo(i)=0.
         do j=-2,2
            psmo(i)=psmo(i)+psavg(i+j)
         enddo
         psmo(i)=0.2*psmo(i)
      enddo
      psmo(-nh)=psmo(-nh+2)
      psmo(-nh+1)=psmo(-nh+2)
      psmo(nh-1)=psmo(nh-2)
      psmo(nh)=psmo(nh-2)

      call pctile(psmo(-136),tmp,273,45,base)
      call pctile(psmo(-136),tmp,273,11,base2)
      rms2=base-base2

      do i=-nh,nh
         psmo(i)=(psmo(i)-base)/rms2
         write(51,3001) i,i*df,psavg(i),psmo(i)
 3001    format(i6,3f12.3)
      enddo

      ia=-136
      ib=136
      plimit=10
      pmax=plimit
      k=1
      do i=ia,ib
         if(psmo(i).gt.pmax) then
            sstf(1,k)=3.0
            sstf(6,k)=i*df
            pmax=psmo(i)
         endif
         if(psmo(i).lt.0.5*pmax .and. pmax.gt.plimit) then
            k=k+1
            pmax=plimit
         endif
      enddo
      kz=k-1
      print*,'kz: ',kz

      return
      end

