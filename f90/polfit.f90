subroutine polfit(csx,csy,iping,i0,dphi,pol,delta)

  complex csx(-1000:1000),csy(-1000:1000)
  complex w,w2,w3,z,z45,z135,zr,zl
  real px(-1000:1000),py(-1000:1000)
  data rad/57.2957795/
  save xi,q,u,v
  abs2(z)=real(z)*real(z) + aimag(z)*aimag(z)

  if(iping.eq.1) then
     xi=0.
     q=0.
     u=0.
     v=0.
  endif

  do i=-1000,1000
     px(i)=abs2(csx(i))
     py(i)=abs2(csy(i))
  enddo
  call pctile(px,2001,50,s0x)
  call pctile(py,2001,50,s0y)

  w=cmplx(cos(dphi/rad),sin(dphi/rad))
  w2=cmplx(cos((dphi+90.0)/rad),sin((dphi+90.0)/rad))
  w3=cmplx(cos((dphi-90.0)/rad),sin((dphi-90.0)/rad))

  nwh=1
  ia=i0-nwh
  ib=i0+nwh
  do i=ia,ib
     sqx=abs2(csx(i)) - s0x
     sqy=abs2(csy(i)) - s0y
     xi=xi + sqx + sqy
     q=q + sqx - sqy
     z45 =(csx(i)+w*csy(i))
     z135=(csx(i)-w*csy(i))
     u=u + 0.5*(abs2(z45) - abs2(z135))
     zr=(csx(i)+w2*csy(i))
     zl=(csx(i)+w3*csy(i))
     v=v + 0.5*(abs2(zr) - abs2(zl))
  enddo

  dl=sqrt(q*q + u*u)/xi
  dc=v/xi
  pol=0.5*atan2(u,q)*rad
  if(pol.lt.0.0) pol=pol+180.0
  delta=atan2(v,-u)*rad

  write(*,2010) 1.0,q/xi,u/xi,v/xi,dl,dc,pol,delta,1000.0*s0x,1000.0*s0y,i0
2010 format(6f7.2,2f7.1,2f8.2,i3)

  return
end subroutine polfit
