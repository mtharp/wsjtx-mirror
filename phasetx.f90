subroutine phasetx(id2,npts,fac,txbal,txpha)

  integer*2 id2(2,npts)
  complex z

  pha=txpha/57.2957795
  xbal=10.0**(0.005*txbal)
  if(xbal.gt.1.0) then
     b1=1.0
     b2=1.0/xbal
  else
     b1=xbal
     b2=1.0
  endif
  do i=1,npts
     x=id2(1,i)
     y=id2(2,i)
     phi=atan2(y,x)
     xx=30000.0*cos(phi)
     yy=30000.0*sin(phi+pha)
     z=fac*cmplx(xx,yy)
     id2(1,i)=b1*real(z)
     id2(2,i)=b2*aimag(z)
  enddo

  return
end subroutine phasetx
