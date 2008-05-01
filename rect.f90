subroutine rect(c2,dtx,dfx,message,dfx2,width,pmax)

  parameter (NFFT1=65536)
  parameter (MAXSYM=176)
  character*22 message
  character*12 call1,arg
  character*4 grid
  complex c2(45000)
  complex c3(45000)
  complex cr(45000)
  complex c(0:65535)
  complex w
  complex c0
  real*8 t,dt,phi,f,f0,dfgen,dphi,pi,twopi,tsymbol
  real ps(-511:512)
  logical lbad1,lbad2
  integer npr3(162)
  integer softsym(162)
  integer*1 data0(11),data1(11)
  integer*1 symbol(MAXSYM)
  data npr3/                                   &
      1,1,0,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,1,0, &
      0,1,0,1,1,1,1,0,0,0,0,0,0,0,1,0,0,1,0,1, &
      0,0,0,0,0,0,1,0,1,1,0,0,1,1,0,1,0,0,0,1, &
      1,0,1,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,0,1, &
      0,0,1,0,1,1,0,0,0,1,1,0,1,0,1,0,0,0,1,0, &
      0,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,0,0,1,1, &
      0,1,0,0,0,1,1,1,0,0,0,0,0,1,0,1,0,0,1,1, &
      0,0,0,0,0,0,0,1,1,0,1,0,1,1,0,0,0,1,1,0, &
      0,0/
  dt=1.0/375
  nsps=256
  nsym=162
  nz=nsps*nsym
  twopi=8.d0*atan(1.d0)

  i1=nint((dtx+2.0)/dt)           !Start index for synced symbols
  if(i1.ge.1) then
     i2=i1 + nz - 1
     c3(1:nz)=c2(i1:i2)
  else if(i1.eq.0) then
     c3(1)=0
     c3(2:nz)=c2(nz-1)
  else
     c3(:-i1+1)=0
     i2=nz+i1
     c3(-i1:)=c2(:i2)
  endif

  i1=index(message,' ')
  call1=message(1:i1-1)
  grid=message(i1+1:i1+4)
  read(message(i1+6:),*,err=900) ndbm
  call packcall(call1,n1,lbad1)
  call packgrid(grid,ng,lbad2)
  n2=128*ng + (ndbm+64)
  call pack50(n1,n2,data0)             !Pack 8 bits per byte, add tail
  nbytes=(50+31+7)/8
  call encode232(data0,nbytes,symbol,MAXSYM)  !Convolutional encoding
  call inter_mept(symbol,1)                   !Apply interleaving

  dftone=12000.d0/8192.d0                     !1.4649 Hz
  phi=0.d0
  k=0
  do j=1,nsym
     f=dfx + dftone*(npr3(j)+2*symbol(j)-1.5)
     dphi=twopi*dt*f
     do i=1,nsps
        phi=phi+dphi
        w=cmplx(cos(phi),-sin(phi))
        k=k+1
        cr(k)=w*c3(k)
     enddo
  enddo

  c(0:nz-1)=cr
  c(nz:)=0.
  call four2a(c,NFFT1,1,-1,1)
  nadd=64
  nh2=NFFT1/(2*nadd)
  k=nh2*nadd - 1
  df2=nadd*375.0/NFFT1
  do i=-nh2+1,nh2
     s=0.
     do n=1,nadd
        k=k+1
        s=s + real(c(k))**2 + aimag(c(k))**2
     enddo
     ps(i)=1.e-6*s
     if(k.eq.NFFT1-1) then
        k=k-NFFT1
     endif
  enddo

  sum=0.
  do i=6,10
     sum=sum + ps(i) + ps(-i)
  enddo
  ave=sum/10.

  sum=0.
  pmax=0.
  do i=-10,10
     ps(i)=ps(i)-ave
     if(ps(i).gt.pmax) then
        pmax=ps(i)
        ipk=i
     endif
     if(abs(i).le.3) sum=sum+ps(i)
     freq=i*df2
!     write(53,1010) freq,ps(i)
!1010 format(2f12.3)
  enddo
  width=df2*sum/pmax
  dfx2=df2*ipk
  pmax=db(pmax)

  c0=0.
  k=0
  do i=1,nsym
     do n=1,nsps
        k=k+1
        c0=c0 + cr(k)
     enddo
!     amp0=sqrt(real(c0)**2 + aimag(c0)**2)
     pha0=atan2(aimag(c0),real(c0))
!     write(51,1010) i,pha0
!1010 format(i3,f10.3)
  enddo

900  return
end subroutine rect
