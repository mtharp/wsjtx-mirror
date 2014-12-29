subroutine avecho65(cc,dop,iping,t0,f1a)

  parameter (NZ=520000,NZH=NZ/2,NTX=27*8192)
  parameter (NFFT=256*1024)
  complex cc(2,NZ)
  complex cx(0:NFFT-1),cy(0:NFFT-1)
  complex csx(-1000:1000),csy(-1000:1000)
  complex cpx(-1000:1000,20),cpy(-1000:1000,20)
  complex w,z
  real*4 sx(-1000:1000),sy(-1000:1000)
  logical first
  data fsample/96000.0/,first/.true./,rad/57.2957795/
  save first,sx,sy
  abs2(z)=real(z)*real(z) + aimag(z)*aimag(z)

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
  istart=nint((t0+techo)*fsample)
  cx(0:NTX-1)=cc(1,istart:istart+NTX-1)
  cx(NTX:)=0.
  cy(0:NTX-1)=cc(2,istart:istart+NTX-1)
  cy(NTX:)=0.
  fdop=f1a+dop

  call cspec(cx,fdop,csx)
  call cspec(cy,fdop,csy)

  smax=0.
  do i=-1000,1000
     xx=real(csx(i))**2 + aimag(csx(i))**2
     yy=real(csy(i))**2 + aimag(csy(i))**2
     sx(i)=sx(i) + xx
     sy(i)=sy(i) + yy
     if(sx(i).gt.smax .or. sy(i).gt.smax) then
        smax=max(sx(i),sy(i))
        i0=i
     endif
  enddo

  i0=4
  dphi=88.0
  call polfit(csx,csy,iping,i0,dphi,pol,delta)

  cpx(-1000:1000,iping)=csx
  cpy(-1000:1000,iping)=csy

  if(iping.lt.20) return
  df=fsample/NFFT
  a1=cos(pol/rad)
  b1=sin(pol/rad)
  a2=cos((pol+90.0)/rad)
  b2=sin((pol+90.0)/rad)
  w=cmplx(cos(dphi/rad),sin(dphi/rad))
  do i=-1000,1000
     smatch=0.
     sorthog=0.
     do j=1,20
        smatch =smatch  + abs2(a1*cpx(i,j) + b1*w*cpy(i,j))
        sorthog=sorthog + abs2(a2*cpx(i,j) + b2*w*cpy(i,j))
     enddo
     f=i*df
     write(25,3001) f,sx(i),sy(i),smatch,sorthog
3001 format(f10.3,4e12.3)
  enddo

  return
end subroutine avecho65
