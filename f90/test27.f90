program test27

  parameter (NTX=27648)             !4*27*256
  parameter (NRX=33792)             !33*1024
  complex ctx(NTX)
  complex crx(NRX)
  complex z
  real rx(2*NRX)
  real f1                           !Generated audio frequency
  real*8 dt,pha,dpha,twopi,f,df
  integer ic27(27)
  data ic27/1,3,7,15,2,5,11,23,18,8,17,6,13,27,26,24,20,12,25,22,   &
       16,4,9,19,10,21,14/
  equivalence (rx,crx)

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

  call random_number(rx)
  crx(501:500+NTX)=crx(501:500+NTX) + 10.0*ctx

  do lag=0,1000,10
     z=0.
     do i=1,NTX
        z=z + conjg(ctx(i))*crx(i+lag)
     enddo
     s=abs(z)
     write(*,1010) dt*lag,s,z
     write(13,1010) dt*lag,s,z
1010 format(f12.6,3f12.1)
  enddo

  return
end program test27
