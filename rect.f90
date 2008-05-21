subroutine rect(c4,message,dfx2,width,pmax)

  parameter (NFFT1=65536)
  parameter (MAXSYM=176)
  character*22 message
  character*12 call1,arg
  character*4 grid
  complex c4(45000)
  complex cr(45000)
  complex c(0:65535)
  complex*16 w,ws
  complex c0
  real*8 t,dt,f,f0,dfgen,dphi,twopi,tsymbol
  real ps(-32768:32768)
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

!  rewind 51
!  rewind 53
  dt=1.0/375
  nsps=256
  nsym=162
  nz=nsps*nsym
  twopi=8.d0*atan(1.d0)

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
  k=0
  w=1.0
  do j=1,nsym
!     f=dftone*(npr3(j)+2*symbol(j)-1.5)
     f=dftone*(npr3(j)-1.5)
     dphi=twopi*dt*f
     ws=dcmplx(cos(dphi),-sin(dphi))
     do i=1,nsps
        w=w*ws
        k=k+1
        cr(k)=w*c4(k)
     enddo
  enddo

  c(0:nz-1)=cr
  c(nz:)=0.
  call four2a(c,NFFT1,1,-1,1)
  nadd=8
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
  do i=-100,100
     ps(i)=ps(i)-ave
     if(ps(i).gt.pmax) then
        pmax=ps(i)
        ipk=i
     endif
     if(abs(i).le.5) sum=sum+ps(i)
     freq=i*df2
     write(53,1011) freq,ps(i)
1011 format(2f12.3)
  enddo
  width=df2*sum/pmax
  dfx2=df2*ipk
  pmax=db(pmax)

!###
  nfft=2048
  ndat=5*256
  do j=2,161
     k=(j-2)*256
     c(0:ndat-1)=cr(k+1:k+ndat)
     c(ndat:nfft-1)=0.
     call four2a(c,nfft,1,-1,1)
     nh=nfft/2
     df3=375.0/nfft
     smax=0.
     do i=-20,20
        k1=i
        if(k1.lt.0) k1=k1+nfft
!        k2=i+nfft/128
!        if(k2.lt.0) k2=k2+nfft
!        s=real(c(k1))**2 + aimag(c(k1))**2 + real(c(k2))**2 + aimag(c(k2))**2
        s=real(c(k1))**2 + aimag(c(k1))**2 
        if(s.gt.smax) then
           ipk=i
           if(ipk.gt.8) ipk=ipk-16
           smax=s
        endif
     enddo
     fpk=ipk*df3
     write(54,3201) j,ipk,fpk,0.000015*smax
3201 format(i3,i5,2f10.3)
  enddo
  write(54,3201) 163,ipk,-3.0,0.0
  write(54,3201) 0,ipk,-3.0,0.0
!###



  k=0
  w=1.0
  dphi=twopi*dt*dfx2
  ws=dcmplx(cos(dphi),-sin(dphi))
  do i=1,nsym
     c0=0.
     do n=1,nsps
        k=k+1
        w=w*ws
!        c0=c0 + w*cr(k)
        c0=c0 + cr(k)
     enddo
     amp0=sqrt(real(c0)**2 + aimag(c0)**2)
     pha0=atan2(aimag(c0),real(c0))
     write(51,1010) i,amp0,pha0,c0
1010 format(i3,4f10.3)
     c00=-c0
  enddo

900  return
end subroutine rect
