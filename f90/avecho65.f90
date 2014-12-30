subroutine avecho65(cc,dop,nn,i00,dphi,t0,f1a,dl,dc,pol,delta,red,blue)

  parameter (NZ=520000,NZH=NZ/2,NTX=27*8192)
  parameter (NFFT=256*1024)
  complex cc(2,NZ)
  complex cx(0:NFFT-1),cy(0:NFFT-1)
  complex csx(-1000:1000),csy(-1000:1000)
  complex z
  real*4 sx(-1000:1000),sy(-1000:1000)
  real blue(2000),red(2000)
  data fsample/96000.0/
  save sx,sy
  abs2(z)=real(z)*real(z) + aimag(z)*aimag(z)

  print*,"B",nn
  if(nn.eq.0) then
     sx=0.
     sy=0.
  endif

  nn=nn+1
  cx(0:NZH-1)=cc(1,1:NZH)
  cy(0:NZH-1)=cc(2,1:NZH)

  call txtone(cx,tx,f1x)
  call txtone(cy,ty,f1y)
  t0=(tx+ty)/2.0
  f1a=(f1x+f1y)/2.0
  techo=2.44
  istart=nint((t0+techo)*fsample)
  cx(0:NTX-1)=cc(1,istart:istart+NTX-1)
  cx(NTX:)=0.
  cy(0:NTX-1)=cc(2,istart:istart+NTX-1)
  cy(NTX:)=0.
  fdop=f1a+dop

  call cspec(cx,fdop,csx)
  call cspec(cy,fdop,csy)

  smax=0.
  do i=-200,200
     sx(i)=sx(i) + abs2(csx(i))
     sy(i)=sy(i) + abs2(csy(i))
     if(sx(i).gt.smax .or. sy(i).gt.smax) then
        smax=max(sx(i),sy(i))
        i0=i
     endif
  enddo

  i0=i00
  call polfit(csx,csy,nn,i0,dphi,dl,dc,pol,delta,red,blue)

  return
end subroutine avecho65
