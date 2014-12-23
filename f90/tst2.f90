program tst2

  parameter (NZ=260000)
  integer*2 id2(NZ)
  real x(131072)
  complex z
  complex w(512)
  complex c(0:65536)
  equivalence (x,c)

!  open(10,file='save/141222_212036.eco',status='old',access='stream')
  open(10,file='e:/141223_152106.eco',status='old',access='stream')

  nadd=512
  nh=nadd/2

  do i=1,nadd
     phi=i*6.283185307*1500.0/48000.0
     w(i)=cmplx(cos(phi),-sin(phi))
  enddo

  fac=0.
  nblks=NZ/nadd
  n1=nblks/25

  do iping=1,1
     read(10,end=999) ndop,nfrit,nsum,nclearave,nqual,f1,rms,snrdb,dfreq,  &
          width,id2
  enddo

  do iping=1,1
     read(10,end=999) ndop,nfrit,nsum,nclearave,nqual,f1,rms,snrdb,dfreq,  &
          width,id2
     k0=0
     s0=0.
     sq=0.
     k=0
       do n=1,nblks
        z=0.
        do i=1,nadd
           k=k+1
           z=z + id2(k)*w(i)
        enddo
        z=z/nadd
        t=(n*nadd)/48000.0
        if(n.lt.n1) sq=sq + abs(z)
        if(n.eq.n1) fac=1.0/(sq/n1)
        s=fac*abs(z)
        write(13,1010) t,abs(z),s
1010    format(3f10.3)
        if(s.gt.10.0 .and. s0.gt.10.0 .and. k0.eq.0) then
           k0=k
           ss0=s
        endif
        s0=s
     enddo

     write(*,1000) iping,ndop,nfrit,f1,fac,ss0,k0/48000.0
1000 format(i5,2i8,f10.1,3f10.3)

     nfft=131072
!     ia=1
     ia=int(2.7*48000)
     ib=int(ia+2.3*48000)
     n=ib-ia+1
     x(1:n)=id2(ia:ib)
     x(n+1:)=0.
     call four2a(x,nfft,1,-1,0)
     df=48000.0/nfft
     iz=int(3000.0/df)
     do i=1,iz
        s=real(c(i))**2 + aimag(c(i))**2
        write(14,1020) i*df,s
1020    format(f10.3,e12.3)
     enddo

  enddo

999 end program tst2
