      subroutine sync162(psavg,sstf,kz)

C  Find MEPT_JT sync signals, with best-fit DT and DF.  

      parameter (NFFT=256)
      parameter (NH=NFFT/2)
      parameter (NSMAX=351)
      real psavg(-NH:NH)
      real psmo(-NH:NH)
      real tmp(513)
      real sstf(275)

      do i=-nh+2,nh-2
         psmo(i)=0.
         do j=-2,2
            psmo(i)=psmo(i)+psavg(i+j)
         enddo
         psmo(i)=0.2*psmo(i)
      enddo

      call pctile(psmo(-68),tmp,137,45,base)
      call pctile(psmo(-68),tmp,137,11,base2)
      rms2=base-base2

      ia=-65
      ib=65
      df=375.0/nfft
      do i=ia,ib
         psmo(i)=(psmo(i)-base)/rms2
!         write(51,3001) i,150.0+i*df,psavg(i),psmo(i)
! 3001    format(i6,3f12.3)
      enddo

      plimit=10
      pmax=plimit
      k=1
      do i=ia,ib
         if(psmo(i).gt.pmax) then
            sstf(k)=i*df
            pmax=psmo(i)
         endif
!         if(psmo(i).lt.0.5*pmax .and. pmax.gt.plimit) then
         if(psmo(i).lt.pmax-3.0 .and. pmax.gt.plimit) then
!            print*,'A ',k,pmax,sstf(k)
            k=k+1
            sstf(k)=99999
            pmax=psmo(i)
         endif
      enddo
      kz=k-1

      k=0
      do j=1,kz
         if(abs(sstf(j)).lt.10000.0) then
            k=k+1
            sstf(k)=sstf(j)
!            print*,'B ',k,sstf(k)
         endif
      enddo
      kz=k

      return
      end

