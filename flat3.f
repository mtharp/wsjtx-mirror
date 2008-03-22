      subroutine flat3(ss0,n,nsum)

      parameter (NZ=256)
      real ss0(NZ)
      real ss(NZ)
      real ref(NZ)
      real tmp(NZ)

      call move(ss0,ss(129),128)
      call move(ss0(129),ss,128)

      nsmo=20
      base=50*(float(nsum)**1.5)
      ia=nsmo+1
      ib=n-nsmo-1
      do i=ia,ib
         call pctile(ss(i-nsmo),tmp,2*nsmo+1,50,ref(i))
      enddo
      call pctile(ref(ia),tmp,ib-ia+1,68,base2)

C  Don't flatten if signal is extremely low (e.g., RX is off).
!      print*,base2/(0.05*base)
      if(base2.gt.0.01*base) then
         do i=ia,ib
            ss(i)=base*ss(i)/ref(i)
         enddo
      else
         do i=1,n
            ss(i)=0.
         enddo
      endif

      call move(ss(129),ss0,128)
      call move(ss,ss0(129),128)

      return
      end
