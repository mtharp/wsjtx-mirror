subroutine polfit(csx,csy,iping,i0,dphi,dl,dc,pol,delta,red,blue)

  parameter (NFFT=256*1024)
  complex csx(-1000:1000),csy(-1000:1000)
  complex cpx(-1000:1000,20),cpy(-1000:1000,20)
  complex w,z
  real px(-1000:1000),py(-1000:1000)
  real blue(2000),red(2000)
  data rad/57.2957795/,fsample/96000.0/
  save xi,q,u,v,sum0x,sum0y
  abs2(z)=real(z)*real(z) + aimag(z)*aimag(z)

  if(iping.eq.1) then
     xi=0.
     q=0.
     u=0.
     v=0.
     sum0x=0.
     sum0y=0.
  endif

  do i=-1000,1000
     px(i)=abs2(csx(i))
     py(i)=abs2(csy(i))
  enddo
  call pctile(px,2001,49,s0x)
  call pctile(py,2001,49,s0y)
  sum0x=sum0x + s0x
  sum0y=sum0y + s0y

  w=cmplx(cos(dphi/rad),sin(dphi/rad))
  nwh=1
  ia=i0-nwh
  ib=i0+nwh
  do i=ia,ib
     sqx=abs2(csx(i)) - s0x
     sqy=abs2(csy(i)) - s0y
     xi=xi + sqx + sqy
     q=q + sqx - sqy
     u=u + 2.0*real(csx(i)*conjg(w*csy(i)))
     v=v + 2.0*aimag(csx(i)*conjg(w*csy(i)))
  enddo

  dl=sqrt(q*q + u*u)/xi
  dc=v/xi
  pol=0.5*atan2(u,q)*rad
  if(pol.lt.0.0) pol=pol+180.0
  delta=atan2(v,-u)*rad

!  write(*,2010) iping,1.0,q/xi,u/xi,v/xi,dl,dc,pol,delta,    &
!       1000.0*s0x,1000.0*s0y,i0
!2010 format(i2,6f7.2,2f7.1,2f8.2,i3)

  cpx(-1000:1000,iping)=csx
  cpy(-1000:1000,iping)=csy

!  if(iping.lt.20) return

  fx=1.0/sqrt(sum0x/iping)
  fy=1.0/sqrt(sum0y/iping)

  df=fsample/NFFT
  a1=fx*cos(pol/rad)
  b1=fy*sin(pol/rad)
  a2=fx*cos((pol+90.0)/rad)
  b2=fy*sin((pol+90.0)/rad)
  w=cmplx(cos(dphi/rad),sin(dphi/rad))

!  rewind 25
  fs=1.0/(iping*sqrt(2.0))
  do i=-1000,1000
     s1=0.
     s0=0.
     do j=1,iping
        s1=s1 + abs2(a1*cpx(i,j) + b1*w*cpy(i,j))    !Matched polarization
        s0=s0 + abs2(a2*cpx(i,j) + b2*w*cpy(i,j))    !Orthogonal polarization
     enddo
     f=i*df
!     write(25,3001) f,fs*s1,fs*s0
!3001 format(f10.3,2e12.3)
     if(i.lt.1000) then
        red(i+1001)=fs*s1
        blue(i+1001)=fs*s0
     endif
  enddo

  return
end subroutine polfit
