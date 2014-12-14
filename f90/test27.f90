program test27

  parameter (NTX=27648)             !4*27*256
  parameter (NRX=33792)             !33*1024
  complex ctx(NTX)
  complex crx(NRX)
  complex z
  character arg*8
  real ccf(0:6000)
  real*8 dt,pha,dpha,twopi,f,df
  integer ic27(27)
  data ic27/1,3,7,15,2,5,11,23,18,8,17,6,13,27,26,24,20,12,25,22,   &
       16,4,9,19,10,21,14/

  nargs=iargc()
  if(nargs.ne.3) then
     print*,'Usage: test27 <n27> <nblk> <snrdb>'
     go to 999
  endif
  call getarg(1,arg)
  read(arg,*) n27
  call getarg(2,arg)
  read(arg,*) nblk
  call getarg(3,arg)
  read(arg,*) snrdb

  twopi=8*atan(1.d0)
  dt=1.d0/12000.d0
  nsps=NTX/(27*n27)                         !Samples per symbol
  tsym=nsps*dt                              !Symbol suration (s)
  df=12000.d0/nsps                          !Tone spacing (Hz)
  pha=0.d0
  k=0
  do nn=1,n27
     do j=1,27
        f=1500.d0 + (ic27(j)-14)*df
        dpha=twopi*f*dt
        do i=1,nsps
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

  nadd=NTX/nblk
  nlag=4
  sum=0.
  nsum=0
  lagmax=6000/nlag

  do lag=0,lagmax
     s=0.
     do j=1,nblk
        z=0.
        do i=1,nadd
           z=z + conjg(ctx(i)) * crx(i+lag*nlag)
        enddo
        s=s + abs(z)
     enddo
     ccf(lag)=s
     t=dt*(nlag*lag-500)
     if(abs(t).gt.0.01) then
        nsum=nsum+1
        sum=sum+s
     endif
  enddo
  ave=sum/nsum
  ccf(1:lagmax)=ccf(1:lagmax) - ave

  sq=0.
  smax=0.
  do lag=0,lagmax
     t=dt*(nlag*lag-500)
     if(abs(t).gt.0.01) sq=sq + (ccf(lag)-1.0)**2
     if(ccf(lag).gt.smax) smax=ccf(lag)
  enddo
  rms=sqrt(sq/(nsum-1))
  snr=smax/rms
  ccf(0:lagmax)=ccf(0:lagmax)/rms

  do lag=0,lagmax
     t=dt*(nlag*lag-500)     
     write(13,1010) t,ccf(lag)
1010 format(f12.6,3f12.1)
  enddo

  print*,lagmax,sum,sq,ave,rms

  write(*,1000) n27,nsps,tsym,df,27*df,snr
1000 format('n27:',i2,'   nsps:',i5,'   tsym:',f6.3,'   df:',f7.3,  &
          '   BW:',f7.1,'   S/N:',f6.1)

999 end program test27
