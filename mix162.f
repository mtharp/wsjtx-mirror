      subroutine mix162(id,npts,c2,jz)

C  Mix 1500 Hz +/- 100 Hz to baseband, and downsample by 1/32

      parameter (NFFT1=2*1024*1024)
      parameter (NFFT2=NFFT1/32)
      parameter (NH2=NFFT2/2)
      integer*2 id(npts)
      real x(NFFT1)
      real ps(-128:128)
      real*8 df
      complex c(0:NFFT1)
      complex c2(0:65535)
      equivalence (x,c)

C  Load data into real array x; pad with zeros up to nfft.
      fac=1.e-4
      do i=1,npts
         x(i)=fac*id(i)
      enddo
      call zero(x(npts+1),NFFT1-npts)

C  Do the real-to-complex FFT
      call xfft(x,NFFT1)

      df=12000.d0/NFFT1
      df2=256.0*df
      i0=nint(1500.d0/df)
      ia=i0-NH2 + 1
      ib=i0+NH2

      k=-129
      do i=ia-128,ib,256
         k=k+1
         sq=0.
         do n=0,255
            f1=abs((i+n)*df - 1500.0)
            if(f1.gt.100.0) c(i+n)=c(i+n)*((87.5-(f1-100.0))/87.5)**2
            sq=sq + real(c(i+n))**2 + aimag(c(i+n))**2
         enddo
         ps(k)=1.e-6*sq
      enddo

      do i=0,NFFT2-1
         j=i0 + i
         if(i.gt.NH2) j=j-NFFT2
         c2(i)=c(j)
      enddo

      call four2a(c2,NFFT2,1,1,1)        !Return to time domain

      fac=1.e-5
      jz=npts/32
      do i=0,jz-1
         c2(i)=fac*c2(i)
      enddo

      return
      end
