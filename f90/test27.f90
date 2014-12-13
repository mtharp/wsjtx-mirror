program test27

  parameter (NTX=27648)             !4*27*256
  parameter (NRX=33792)             !33*1024
  complex ctx(NTX)
  complex crx(NRX)
  complex z
  character arg*8
  real*8 dt,pha,dpha,twopi,f,df
  integer ic27(27)
  data ic27/1,3,7,15,2,5,11,23,18,8,17,6,13,27,26,24,20,12,25,22,   &
       16,4,9,19,10,21,14/

  nargs=iargc()
  if(nargs.ne.2) then
     print*,'Usage: test27 <n1> <snrdb>'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) n1
  call getarg(2,arg)
  read(arg,*) snrdb

  twopi=8*atan(1.d0)
  dt=1.d0/12000.d0
  df=12000.d0/1024.d0
  ncostas=4

  pha=0.d0
  k=0
  do ngroup=1,ncostas
     do j=1,27
        f=1500.d0 + (ic27(j)-14)*df
        dpha=twopi*f*dt
        do i=1,256
           pha=pha+dpha
           k=k+1
           ctx(k)=cmplx(cos(pha),sin(pha))
        enddo
     enddo
  enddo

  do i=1,NRX
     x=0.707*gran()
     y=0.707*gran()
     crx(i)=cmplx(x,y)
  enddo

  fac=10.0**(0.05*snrdb)
  crx(501:500+NTX)=crx(501:500+NTX) + fac*ctx

  n2=NTX/n1
  nlag=10
  
  do lag=0,6000/nlag
     s=0.
     do j=1,n1
        z=0.
        do i=1,n2
           z=z + conjg(ctx(i)) * crx(i+lag*nlag)
        enddo
        s=s + abs(z)
     enddo
!     write(*,1010) dt*lag,s
     write(13,1010) dt*(nlag*lag-500),s
1010 format(f12.6,3f12.1)
  enddo

999 end program test27
