      subroutine spec162(c2,jz)

      parameter(NX=500,NY=160)
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

#ifdef CVF
      open(16,file='pixmap.dat',form='binary',status='unknown',err=1)
#else
      open(16,file='pixmap.dat',access='stream',status='unknown',err=1)
#endif
      read(16,end=1) a
      go to 2
 1    call zero(a,NX*NY/2)

 2    nmove=nsteps+1
      do j=1,NY                 !Move waterfall left
         do i=1,NX-nmove
            a(i,j)=a(i+nmove,j)
         enddo
!         a(NX-nmove+1,j)=255
         a(NX-nmove+1,j)=0
      enddo

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

      brightness=0.
      contrast=0.
      gamma=1.3 + 0.01*contrast
!      gain=40*sqrt(nstep(nspeed)/5.0) * 5.0**(0.01*contrast)
      gain=40 * 5.0**(0.01*contrast)
      offset=-90.
      fac=20.0/nadd

      do k=1,kz
         j=k-kz+NX
         do i=-80,-1
            x=fac*s(k,i+nfft)
            if(x.gt.0.0) n=gain*log10(1.0*x) + offset
            n=min(252,max(0,n))
            a(j,i+81)=n
         enddo
         do i=0,79
            x=fac*s(k,i)
            if(x.gt.0.0) n=gain*log10(1.0*x) + offset
            n=min(252,max(0,n))
            a(j,i+81)=n
         enddo
      enddo

      rewind 16
      write(16) a
      close(16)

      return
      end
