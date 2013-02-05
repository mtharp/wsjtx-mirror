program jt4metrics

  implicit real*8 (a-h,o-z)
  parameter (NMAX=100)
  character*12 arg
  integer hn(0:NMAX)                      !Noise histogram
  integer hs(0:NMAX)                      !(Noise + Signal) histogram
  real pn(0:NMAX)
  real ps(0:NMAX)

  nargs=iargc()
  if(nargs.ne.3) then
     print*,'Usage: jt4metrics nadd snr mult'
     go to 999
  endif

  call getarg(1,arg)
  read(arg,*) nadd
  call getarg(2,arg)
  read(arg,*) snrdb
  sig=10.0**(0.05*snrdb) * (1.0/nadd)**0.25
  call getarg(3,arg)
  read(arg,*) mult

  hn=0
  hs=0
  sq0=0.
  sq00=0.
  mult0=100000
  nerr=0

  do iter1=1,mult
     do iter2=1,mult0
        s0=0.
        s1=0.
        do n=1,nadd
           x=0.707107*gran()
           y=0.707107*gran()
           s0=s0 + x**2 + y**2
           x=0.707107*gran()
           y=0.707107*gran()
           s1=s1 + (x+sig)**2 + y**2
        enddo
        s0=s0/nadd
        s1=s1/nadd
        sq0=sq0 + s0
        sq00=sq00 + min(s0,s1)
        i0=(NMAX/10)*s0
        if(i0.gt.NMAX) i0=NMAX
        i1=(NMAX/10)*s1
        if(i1.gt.NMAX) i1=NMAX
        hn(i0)=hn(i0)+1
        hs(i1)=hs(i1)+1
        if(s1.lt.s0) nerr=nerr+1
     enddo
  enddo
  xiters=float(mult)*mult0
  avg0=sq0/xiters
  avg00=sq00/xiters
  ber=nerr/xiters
  write(*,1000) avg0,avg00,ber
1000 format('Avg noise:',f8.3,'   Est noise:',f8.3,'   BER:',f8.3)

  do i=0,NMAX
     pn(i)=hn(i)/xiters
     ps(i)=hs(i)/xiters
     write(13,1010) 0.01*i,pn(i),ps(i)
1010 format(f8.2,2f15.12)
  enddo

999 end program jt4metrics
