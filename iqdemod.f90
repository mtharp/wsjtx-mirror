subroutine iqdemod(kwave,jz,nfiq,iqrx)

  integer*2 kwave(jz)
  real*8 twopi,dt,f0,pha,dpha

  twopi=8.d0*atan(1.d0)
  dt=1.d0/48000.d0
  f0=nfiq
  dpha=twopi*f0*dt
  pha=0.d0
  do i=1,jz/2
     if(iqrx.eq.0) then
        x=kwave(2*i)
        y=kwave(2*i-1)
     else
        x=kwave(2*i-1)
        y=kwave(2*i)
     endif
     pha=pha+dpha
     r=cmplx(x,y)*cmplx(cos(pha),-sin(pha))
     if(r.lt.-32767.0) r=-32767.0
     if(r.gt. 32767.0) r= 32767.0
     kwave(i)=nint(r)                        !kwave is now real, not complex
  enddo

  return
end subroutine iqdemod
