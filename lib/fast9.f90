program fast9

  parameter (NMAX=15*12000)
  parameter (NFFT=120,NH=NFFT/2,NQ=NFFT/4,JZ=NMAX/(NH/4))
  integer*2 id2(NMAX)

  integer ii(16)                       !Locations of sync symbols
  data ii/ 1,2,5,10,16,23,33,35,51,52,55,60,66,73,83,85/
  integer ii4(16)

  real s1(JZ,NQ)
  real s2(340,NQ)
  real ss2(0:8,85)
  real s(NQ)
  real ccf(0:340-1,10)
  real x(NFFT)
  complex c(0:NH)
  equivalence (x,c)

!  open(10,file='150730_191115.wav',access='stream',status='old')   !E
  open(10,file='150730_191345.wav',access='stream',status='old')   !H
  read(10) id2(1:22)                     !Skip 44 header bytes
  npts=NMAX
  nsps=NH
  read(10) id2(1:npts)                   !Read the raw data

  print*,NMAX,NFFT,NH,JZ,npts,nsps

  s=0
  s2=0

  do j=1,jz
     ia=(j-1)*nsps/4
     ib=ia+nsps-1
     if(ib.gt.npts) exit
     x(1:NH)=id2(ia:ib)
     x(NH+1:)=0.
     call four2a(x,NFFT,1,-1,0)           !r2c
     k=mod(j-1,340)+1
     do i=1,NQ
        t=1.e-10*(real(c(i))**2 + aimag(c(i))**2)
        s1(j,i)=t
        s2(k,i)=s2(k,i)+t
        s(i)=s(i)+t
     enddo
  enddo

  df=12000.0/NFFT
  do i=1,NQ
     write(13,3001) i*df,s(i)
3001 format(f10.3,e12.3)
  enddo

  ii4=4*ii-3
  ccf=0.
  ccfbest=0.
  do k=5,9
     do lag=0,339
        t=0.
        do i=1,16
           j=ii4(i)+lag
           if(j.gt.340) j=j-340
           t=t + s2(j,k)
        enddo
        ccf(lag,k)=t
        if(t.gt.ccfbest) then
           ccfbest=t
           lagpk=lag
           kpk=k
        endif
        if(k.eq.7) write(14,3002) lag,ccf(lag,7)
3002    format(i6,f10.3)
     enddo
  enddo

  ipk=7
  print*,kpk,lagpk,ccfbest

  do i=0,8
     j4=lagpk-4
     i2=2*i + ipk
     do j=1,85
        j4=j4+4
        if(j4.gt.340) j4=j4-340
        ss2(i,j)=s2(j4,i2)
     enddo
  enddo

  do j=1,85
     write(15,3003) j,ss2(0:8,j)
3003 format(i2,9f8.2)
  enddo

end program fast9

