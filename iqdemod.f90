subroutine iqdemod(kwave,jz)

  integer*2 kwave(jz)
  real*8 twopi,dt,f0,pha,dpha

  twopi=8.d0*atan(1.d0)
  dt=1.d0/48000.d0
  f0=8700.d0                 + 60
  dpha=twopi*f0*dt
  pha=0.d0

  npts=jz/2
  do i=1,npts
     y=kwave(2*i-1)                             !Reversed?
     x=kwave(2*i)
     pha=pha+dpha
     r=cmplx(x,y)*cmplx(cos(pha),-sin(pha))
     if(r.lt.-32767.0) r=-32767.0
     if(r.gt. 32767.0) r= 32767.0
     kwave(i)=nint(r)
  enddo

  return
end subroutine iqdemod
