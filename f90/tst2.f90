program tst2

  parameter (NZ=260000)
  integer*2 id2(NZ)
  real x(131072)
  complex z
  complex w(512)
  complex c(0:65536)
  equivalence (x,c)

  open(10,file='save/141222_190836.eco',status='old',access='stream')

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
     read(10,end=999) id2
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
        write(13,1010) t,abs(z),fac*abs(z)
1010    format(3f10.3)
     enddo

     x=id2(1:131072)
     nfft=131072
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
