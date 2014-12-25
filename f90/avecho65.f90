subroutine avecho65(cc,dop,t0,f1a)

  parameter (NZ=520000,NZH=NZ/2,NTX=27*8192)
  parameter (NFFT=256*1024)
  complex cc(2,NZ)
  complex cx(0:NFFT-1),cy(0:NFFT-1)
  complex csx(-1000:1000),csy(-1000:1000)
  real*4 sx(-1000:1000),sy(-1000:1000)
  logical first
  data fsample/96000.0/,first/.true./
  save first,sx,sy

  if(first) then
     sx=0.
     sy=0.
     first=.false.
  endif

  cx(0:NZH-1)=cc(1,1:NZH)
  cy(0:NZH-1)=cc(2,1:NZH)

  call txtone(cx,tx,f1x)
  call txtone(cy,ty,f1y)
  t0=(tx+ty)/2.0
  f1a=(f1x+f1y)/2.0
  techo=2.44
  i0=nint((t0+techo)*fsample)

!###
!  i0=nint(t0*fsample)
!###
  cx(0:NTX-1)=cc(1,i0:i0+NTX-1)
  cx(NTX:)=0.
  cy(0:NTX-1)=cc(2,i0:i0+NTX-1)
  cy(NTX:)=0.
  fdop=f1a+dop

  call cspec(cx,fdop,csx)
  call cspec(cy,fdop,csy)

  df=fsample/NFFT
  rewind 25
  do i=-1000,1000
     f=i*df
     xx=real(csx(i))**2 + aimag(csx(i))**2
     yy=real(csy(i))**2 + aimag(csy(i))**2
     sx(i)=sx(i) + xx
     sy(i)=sy(i) + yy
     write(26,3001) f,xx,yy
     write(25,3001) f,sx(i),sy(i)
3001 format(f10.3,2e12.3)
  enddo
  flush(25)

  return
end subroutine avecho65
