subroutine wav12(d2,d1,npts,nbitsam2)
!subroutine getfile(fname,len)

  parameter (NZ11=60*11025,NZ12=60*12000)
  parameter (NFFT1=64*11025,NFFT2=64*12000)
  integer*1 d1(NZ11)
  integer*1 d1a(NZ11)
  integer*1 i1
  integer*2 i2
  integer*2 d2(NZ12)
  real x(NFFT2)
  complex cx(0:NFFT2/2)
  integer*2 nbitsam2
  equivalence (x,cx),(i1,i2)

  jz=min(NZ11,npts)
  if(nbitsam2.eq.8) then
     jz=min(NZ11,2*npts)
     d1a(1:jz)=d1(1:jz)
     do i=1,jz
        i2=0
        i1=d1a(i)
        d2(i)=10*(i2-128)
     enddo
  endif

  x(1:jz)=d2(1:jz)
  x(jz+1:)=0.0
  call four2a(x,nfft1,1,-1,0)                    !Forwarxd FFT, r2c
  cx(nfft1/2:)=0.0
  call four2a(cx,nfft2,1,1,-1)                   !Inverse FFT, c2r

  npts=jz*12000.0/11025.0
  fac=1.e-6
  if(nbitsam2.eq.16) fac=3.e-8
  x=fac*x
  d2(1:npts)=nint(x(1:npts))
  if(npts.lt.NZ12) d2(npts+1:NZ12)=0

  return
end subroutine wav12
