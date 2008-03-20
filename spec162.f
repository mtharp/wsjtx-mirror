      subroutine spec162(c2,jz)

      parameter(NX=116,NY=160,NTOT=NX*NY)
      complex c2(65536)
      complex c(0:255)
      real s(120,0:255)
      real w(0:255)
      integer*2 a(NX,NY)

      nfft=256
      df=375.0/nfft
      twopi=6.2831853
      pi=0.5*twopi
      do i=0,nfft-1
         w(i)=sin(i*pi/nfft)
      enddo

      nadd=9
      call zero(s,120*256)
      istep=nfft/2
      nsteps=(jz-nfft)/(nadd*istep)
      i0=-istep+1
      k=0
      do n=1,nsteps
         k=k+1
         do m=1,nadd
            i0=i0+istep
            do i=0,nfft-1
               c(i)=w(i)*c2(i0+i)
            enddo
            call four2a(c,nfft,1,-1,1)
            do i=0,nfft-1
               s(k,i)=s(k,i) + real(c(i))**2 + imag(c(i))**2
            enddo
         enddo
      enddo
      kz=k

!###
      brightness=0.
      contrast=0.
      gamma=1.3 + 0.01*contrast
!      gain=40*sqrt(nstep(nspeed)/5.0) * 5.0**(0.01*contrast)
      gain=40*5.0**(0.01*contrast)
      offset=brightness/2 + 10
      fac=20.0/nadd

      do k=1,kz
         do i=-80,-1
            x=fac*s(k,i+nfft)
            if(x.gt.0.0) n=gain*log10(1.0*x) + offset
            n=min(252,max(0,n))
            a(k,i+81)=n
         enddo
         do i=0,79
            x=fac*s(k,i)
            if(x.gt.0.0) n=gain*log10(1.0*x) + offset
            n=min(252,max(0,n))
            a(k,i+81)=n
         enddo
      enddo

#ifdef CVF
      open(16,file='pixmap.dat',form='binary',status='unknown')
#else
      open(16,file='pixmap.dat',access='stream',status='unknown')
#endif
      write(16) kz,NY,((a(k,i),k=1,kz),i=1,NY)
      close(16)

      return
      end
