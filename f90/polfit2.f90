subroutine polfit2(csx,csy,uth,nn,nadd,done,dphi,dl,dc,pol,delta,red,blue)

  parameter (NFFT=256*1024)
  complex csx(-1000:1000),csy(-1000:1000)
  complex cpx(-1000:1000,100),cpy(-1000:1000,100)
  complex w,z
  real px(-1000:1000),py(-1000:1000)
  real blue(2000),red(2000)
  logical done
  character linx*25,liny*25,mark*6
  data rad/57.2957795/,fsample/96000.0/,nplot/0/
  data mark/' .-+X$'/,p0/70.0/,dp/0.0/
  save xi,q,u,v,sum0x,sum0y,nplot,p0,dp
  abs2(z)=real(z)*real(z) + aimag(z)*aimag(z)

  if(nn.eq.1) then
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
  i0=0
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

!  write(*,2010) nn,1.0,q/xi,u/xi,v/xi,dl,dc,pol,delta,    &
!       1000.0*s0x,1000.0*s0y,i0
!2010 format(i2,6f7.2,2f7.1,2f8.2,i3)

  cpx(-1000:1000,nn)=csx
  cpy(-1000:1000,nn)=csy

  if(.not.done) return

  fx=1.0/sqrt(sum0x/nn)
  fy=1.0/sqrt(sum0y/nn)

  df=fsample/NFFT
  a1=fx*cos(pol/rad)
  b1=fy*sin(pol/rad)
  a2=fx*cos((pol+90.0)/rad)
  b2=fy*sin((pol+90.0)/rad)
  w=cmplx(cos(dphi/rad),sin(dphi/rad))

!  rewind 25
  fs=1.0/(nn*sqrt(2.0))
  do i=-1000,999
     s1=0.
     s0=0.
     do j=1,nn
        s1=s1 + abs2(a1*cpx(i,j) + b1*w*cpy(i,j))    !Matched polarization
        s0=s0 + abs2(a2*cpx(i,j) + b2*w*cpy(i,j))    !Orthogonal polarization
        if(nn.gt.20) stop
     enddo
     f=i*df
     red(i+1001)=fs*s1
     blue(i+1001)=fs*s0
     write(25,3001) f,fs*s1,fs*s0
3001 format(f10.3,2e12.3)
  enddo
  nplot=nplot+1

  do i=-12,12
     j=i+13
     n=min(max(1,nint(red(1001-i)-0.5)),6)
     linx(j:j)=mark(n:n)
     n=min(max(1,nint(blue(1001-i)-0.5)),6)
     liny(j:j)=mark(n:n)
  enddo

  p=pol
  if((p-p0).lt.-90.0) dp=dp+180.0
  if((p-p0).ge.90.0) dp=dp-180.0
  pdp=p+dp
  npol=pdp
  np9=9*npol-166
  p0=p

  if(uth.gt.33.83 .and. uth.lt.34.44) pdp=pdp+180
  write(26,1020) uth,npol,np9,linx,liny
1020 format(f9.3,2i6,2x,'|',a25,'|',a25,'|')

  return
end subroutine polfit2
